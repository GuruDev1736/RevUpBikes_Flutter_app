import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../utils/app_colors.dart';
import '../models/bike_model.dart';
import '../services/api_services.dart';
import '../services/database_helper.dart';
import 'booking_confirmation_screen.dart';
import 'auth_screen.dart';
import 'terms_and_conditions_screen.dart';
import 'deposit_terms_screen.dart';

class BikeDetailsScreen extends StatefulWidget {
  final BikeModel bike;
  final bool fromRequest;
  final int? requestId;

  const BikeDetailsScreen({
    super.key,
    required this.bike,
    this.fromRequest = false,
    this.requestId,
  });

  @override
  State<BikeDetailsScreen> createState() => _BikeDetailsScreenState();
}

class _BikeDetailsScreenState extends State<BikeDetailsScreen> {
  // Document upload variables
  File? _aadharCardImage;
  File? _drivingLicenseImage;
  final ImagePicker _picker = ImagePicker();

  // Uploaded file URLs (will be populated after successful upload)
  String? _aadharCardUrl;
  String? _drivingLicenseUrl;

  // Upload loading states
  bool _isUploadingAadhar = false;
  bool _isUploadingLicense = false;

  // Razorpay integration
  late Razorpay _razorpay;
  bool _isProcessingPayment = false;

  // Date and time variables
  DateTime? _fromDateTime;
  DateTime? _toDateTime;

  // Rental period type
  String _rentalPeriod = 'Day'; // Day, Week, or Month

  // Additional user information
  final TextEditingController _alternatePhoneController =
      TextEditingController();
  final TextEditingController _currentAddressController =
      TextEditingController();
  final TextEditingController _permanentAddressController =
      TextEditingController();
  bool _sameAsCurrentAddress = false;

  // Terms and conditions agreement
  bool _acceptedTermsAndConditions = false;
  bool _acceptedDepositTerms = false;

  // Coupon system
  final TextEditingController _couponController = TextEditingController();
  bool _isCouponApplied = false;
  double _couponDiscount = 0.0; // Discount percentage
  String _appliedCouponCode = '';
  bool _isValidatingCoupon = false;

  // Bookmark state
  bool _isBookmarked = false;

  // Active booking check
  bool _hasActiveBooking = false;
  bool _isCheckingActiveBooking = true;

  // Calculate number of days between selected dates
  int get _calculatedDays {
    if (_fromDateTime == null || _toDateTime == null) return 1;
    final difference = _toDateTime!.difference(_fromDateTime!);
    return difference.inDays > 0 ? difference.inDays : 1;
  }

  // Calculate total cost based on selected rental period
  double get _totalCost {
    if (_rentalPeriod == 'Week') {
      return widget.bike.pricePerWeek;
    } else if (_rentalPeriod == 'Month') {
      return widget.bike.pricePerMonth;
    } else {
      // Day pricing - multiply by number of days
      return widget.bike.pricePerDay * _calculatedDays;
    }
  }

  // Calculate final amount after applying coupon discount
  double get _finalAmount {
    if (_isCouponApplied && _couponDiscount > 0) {
      final discount = (_totalCost * _couponDiscount) / 100;
      return _totalCost - discount;
    }
    return _totalCost;
  }

  // Calculate discount amount
  double get _discountAmount {
    if (_isCouponApplied && _couponDiscount > 0) {
      return (_totalCost * _couponDiscount) / 100;
    }
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
    _checkBookmarkStatus();
    _checkActiveBooking();
  }

  Future<void> _checkBookmarkStatus() async {
    final isBookmarked = await DatabaseHelper.instance.isBookmarked(
      widget.bike.id,
    );
    setState(() {
      _isBookmarked = isBookmarked;
    });
  }

  Future<void> _checkActiveBooking() async {
    try {
      final userData = await AuthService.getUserData();
      print('🔍 DEBUG: userData = $userData');

      if (userData != null && userData['CONTENT'] != null) {
        var userId =
            userData['CONTENT']['id']?.toString() ??
            userData['CONTENT']['userId']?.toString() ??
            userData['CONTENT']['ID']?.toString();

        print('🔍 DEBUG: Extracted userId = $userId');

        if (userId != null) {
          final response = await AuthService.checkActiveBooking(userId);
          print('🔍 DEBUG: API Response = $response');

          if (mounted) {
            final hasActive = response['CONTENT'] == true;
            print('🔍 DEBUG: hasActive = $hasActive');
            print('🔍 DEBUG: Setting _hasActiveBooking = $hasActive');

            setState(() {
              _hasActiveBooking = hasActive;
              _isCheckingActiveBooking = false;
            });

            print(
              '🔍 DEBUG: After setState - _hasActiveBooking = $_hasActiveBooking, _isCheckingActiveBooking = $_isCheckingActiveBooking',
            );

            // NOTE: Dialog removed - users will see the warning banner with action buttons instead
          }
        } else {
          if (mounted) {
            setState(() {
              _isCheckingActiveBooking = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isCheckingActiveBooking = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingActiveBooking = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    _alternatePhoneController.dispose();
    _currentAddressController.dispose();
    _permanentAddressController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful! Creating booking...'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Keep processing state true while creating booking
    try {
      // Get user data for booking creation
      final userData = await AuthService.getUserData();
      final userContent = userData?['CONTENT'];
      final userId = userContent?['userId']?.toString() ?? '';

      if (userId.isEmpty) {
        throw Exception('User ID not found');
      }

      // Create booking using the API with final amount after discount
      final bookingResult = await AuthService.createBooking(
        widget.bike.id.toString(),
        userId,
        _formatDateTimeForAPI(_fromDateTime!),
        _formatDateTimeForAPI(_toDateTime!),
        response.paymentId ?? '',
        _finalAmount, // Use final amount after discount
        _aadharCardUrl ?? '',
        _drivingLicenseUrl ?? '',
        _alternatePhoneController.text.trim(),
        _currentAddressController.text.trim(),
        _permanentAddressController.text.trim(),
        _rentalPeriod.toUpperCase(), // Convert Day/Week/Month to DAY/WEEK/MONTH
        _appliedCouponCode, // Send applied coupon code or empty string
      );

      setState(() {
        _isProcessingPayment = false;
      });

      if (bookingResult['STS'] == '200') {
        // Booking created successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking created successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Delete bike request if booking was made from a request
        if (widget.fromRequest && widget.requestId != null) {
          try {
            await AuthService.deleteBikeRequest(widget.requestId!);
            print('✅ Bike request deleted successfully');
          } catch (e) {
            print('⚠️ Failed to delete bike request: $e');
          }
        }

        // Navigate to booking confirmation after successful booking creation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              bike: widget.bike,
              duration: _calculatedDays,
              totalCost:
                  _finalAmount, // Use final amount after discount (same as Razorpay)
              paymentId: response.paymentId,
              orderId: response.orderId,
              bookingData: bookingResult['CONTENT'],
            ),
          ),
        );
      } else {
        // Booking creation failed
        throw Exception(bookingResult['MSG'] ?? 'Failed to create booking');
      }
    } catch (e) {
      setState(() {
        _isProcessingPayment = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking creation failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Show retry dialog or handle booking failure
      _showBookingFailureDialog(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isProcessingPayment = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isProcessingPayment = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showBookingFailureDialog(PaymentSuccessResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Booking Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment was successful, but booking creation failed.'),
            const SizedBox(height: 12),
            Text('Payment ID: ${response.paymentId}'),
            const SizedBox(height: 8),
            const Text('Please contact support for assistance.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              // Retry booking creation
              _handlePaymentSuccess(response);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'Retry Booking',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Convert file to base64 string
  Future<String> _fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  /// Format DateTime to required API format: YYYY-MM-DD HH:mm
  String _formatDateTimeForAPI(DateTime dateTime) {
    String year = dateTime.year.toString();
    String month = dateTime.month.toString().padLeft(2, '0');
    String day = dateTime.day.toString().padLeft(2, '0');
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute';
  }

  /// Get user ID from stored user data
  Future<String?> _getUserId() async {
    final userData = await AuthService.getUserData();
    if (userData != null && userData['CONTENT'] != null) {
      return userData['CONTENT']['userId']?.toString();
    }
    return null;
  }

  /// Upload file and return the URL
  Future<String?> _uploadFileAndGetUrl(File file, String documentType) async {
    try {
      // Get file name
      final fileName = path.basename(file.path);

      // Convert to base64
      final base64Data = await _fileToBase64(file);

      // Get user ID
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      // Upload file
      final result = await AuthService.uploadFile(fileName, base64Data, userId);

      if (result['STS'] == '200' && result['CONTENT'] != null) {
        // Extract URL from response - adjust based on your API response structure
        final fileUrl = result['CONTENT'];
        return fileUrl;
      } else {
        throw Exception(result['MSG'] ?? 'Upload failed');
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Bike Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.text),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: _isBookmarked ? AppColors.primary : AppColors.text,
                  ),
                ),
                onPressed: () async {
                  // Toggle bookmark
                  if (_isBookmarked) {
                    await DatabaseHelper.instance.removeBookmark(
                      widget.bike.id,
                    );
                    setState(() {
                      _isBookmarked = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Removed from bookmarks'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else {
                    await DatabaseHelper.instance.addBookmark(widget.bike);
                    setState(() {
                      _isBookmarked = true;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to bookmarks'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                  // Bike image
                  if (widget.bike.bikeImage.isNotEmpty)
                    widget.bike.bikeImage.startsWith('http')
                        ? Image.network(
                            widget.bike.bikeImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackImage();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppColors.primary,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            widget.bike.bikeImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackImage();
                            },
                          )
                  else
                    _buildFallbackImage(),
                  // Overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bike Name and Type
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.bike.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.bike.type,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.bike.isAvailable
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.bike.isAvailable
                                ? 'Available'
                                : 'Unavailable',
                            style: TextStyle(
                              color: widget.bike.isAvailable
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Location and Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.bike.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Icon(Icons.star, size: 18, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.bike.rating}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${widget.bike.reviewCount} reviews)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Active Booking Warning - Show at top if user has active booking
                    // DEBUG: Print the state values
                    Builder(
                      builder: (context) {
                        print(
                          '🎨 DEBUG: Building banner - _hasActiveBooking = $_hasActiveBooking, _isCheckingActiveBooking = $_isCheckingActiveBooking',
                        );
                        return const SizedBox.shrink();
                      },
                    ),
                    if (_hasActiveBooking &&
                        !_isCheckingActiveBooking &&
                        !widget.fromRequest) ...[
                      // Action Buttons - Placed above banner for better visibility
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Implement request bike functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Request bike feature coming soon!',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.directions_bike, size: 18),
                              label: const Text(
                                'Request Bike',
                                style: TextStyle(fontSize: 14),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: BorderSide(
                                  color: AppColors.error,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/my-rides');
                              },
                              icon: const Icon(Icons.list_alt, size: 18),
                              label: const Text(
                                'Manage Rides',
                                style: TextStyle(fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Warning Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.block, color: AppColors.error, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Booking Not Available',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'You already have an active booking. Please complete or cancel your existing booking before making a new one.',
                                    style: TextStyle(
                                      color: AppColors.error.withOpacity(0.8),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Price Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.bike.pricePerDay.toInt()}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'per day',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Date Selection
                    _buildDateTimeSelection(),

                    const SizedBox(height: 24),

                    // Total Cost
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Duration: ${_calculatedDays} ${_calculatedDays == 1 ? 'Day' : 'Days'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '₹${widget.bike.pricePerDay.toInt()} × ${_calculatedDays}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              Text(
                                '₹${_totalCost.toInt()}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                  decoration: _isCouponApplied
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          if (_isCouponApplied) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Discount ($_couponDiscount%):',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.success,
                                  ),
                                ),
                                Text(
                                  '- ₹${_discountAmount.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  '₹${_finalAmount.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Coupon Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Have a Coupon?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (!_isCouponApplied) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _couponController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter coupon code',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.characters,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _isValidatingCoupon
                                      ? null
                                      : () => _applyCoupon(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 15,
                                    ),
                                  ),
                                  child: _isValidatingCoupon
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Apply',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Coupon "$_appliedCouponCode" applied',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          'You saved ₹${_discountAmount.toInt()}',
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeCoupon(),
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Remove coupon',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.bike.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Features
                    const Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.bike.features.map((feature) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Personal Details Section
                    _buildPersonalDetailsForm(),

                    const SizedBox(height: 24),

                    // Document Upload Section
                    _buildDocumentUpload(),

                    const SizedBox(height: 24),

                    // Terms and Conditions Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Terms and Conditions Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _acceptedTermsAndConditions,
                                activeColor: AppColors.primary,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptedTermsAndConditions =
                                        value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const TermsAndConditionsScreen(),
                                        ),
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.text,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: 'I agree to the ',
                                          ),
                                          TextSpan(
                                            text: 'Terms and Conditions',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          const TextSpan(
                                            text:
                                                ' of RevUp Bikes rental service',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Deposit Terms Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _acceptedDepositTerms,
                                activeColor: AppColors.primary,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptedDepositTerms = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const DepositTermsScreen(),
                                        ),
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.text,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text:
                                                'I understand and agree to the ',
                                          ),
                                          TextSpan(
                                            text: 'Deposit Terms',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          const TextSpan(
                                            text:
                                                ' including security deposit and refund policy',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isCheckingActiveBooking
          ? Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: const Center(child: CircularProgressIndicator()),
            )
          : (_hasActiveBooking && !widget.fromRequest)
          ? null
          : Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _canProceedWithBooking() ? _handleBooking : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    disabledBackgroundColor: AppColors.grey,
                  ),
                  child: Text(
                    _canProceedWithBooking()
                        ? 'Book Now for ₹${_finalAmount.toInt()}'
                        : (widget.bike.isAvailable || widget.fromRequest)
                        ? 'Complete Requirements'
                        : 'Not Available',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _handleBooking() async {
    // Check if user is logged in first
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!isLoggedIn) {
      // Show login dialog or navigate to login screen
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text(
            'You need to login to book a bike. Would you like to login now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Login'),
            ),
          ],
        ),
      );

      if (result == true && mounted) {
        // Navigate to login screen
        final loginResult = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );

        // If login was successful, proceed with booking
        if (loginResult == true) {
          _proceedWithBooking();
        }
      }
      return;
    }

    // User is logged in, proceed with booking
    _proceedWithBooking();
  }

  void _proceedWithBooking() {
    // Validate required fields
    if (!_canProceedWithBooking()) {
      String message = '';
      if (_aadharCardUrl == null || _drivingLicenseUrl == null) {
        message = 'Please upload both Aadhar card and driving license';
      } else if (_fromDateTime == null || _toDateTime == null) {
        message = 'Please select booking dates and times';
      } else if (_isUploadingAadhar || _isUploadingLicense) {
        message = 'Please wait for document upload to complete';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Initiate Razorpay payment
    _initiatePayment();
  }

  Future<void> _initiatePayment() async {
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Get user data for payment
      final userData = await AuthService.getUserData();
      final userContent = userData?['CONTENT'];

      // Calculate amount in paise (multiply by 100 for Razorpay)
      // Use final amount after discount instead of total cost
      final amountInPaise = (_finalAmount * 100).toInt();

      var options = {
        'key': 'rzp_test_RPNxiQLJkGE7GO', // You'll replace this with actual key
        'amount': amountInPaise,
        'name': 'RevUp Bikes',
        'description': 'Bike Rental - ${widget.bike.bikeName}',
        'order_id': '', // Generate from backend if needed
        'timeout': 300, // 5 minutes timeout
        'prefill': {
          'contact': userContent?['phoneNumber'] ?? '',
          'email': userContent?['userName'] ?? '',
          'name': '${userContent?['fullName'] ?? ''}',
        },
        'theme': {
          'color': '#D32F2F', // AppColors.primary equivalent
        },
        'notes': {
          'bike_id': widget.bike.id.toString(),
          'bike_name': widget.bike.bikeName,
          'duration_days': _calculatedDays.toString(),
          'from_date': _fromDateTime != null
              ? _formatDateTimeForAPI(_fromDateTime!)
              : '',
          'to_date': _toDateTime != null
              ? _formatDateTimeForAPI(_toDateTime!)
              : '',
          'aadhar_url': _aadharCardUrl ?? '',
          'license_url': _drivingLicenseUrl ?? '',
          'coupon_code': _appliedCouponCode,
          'discount_percentage': _couponDiscount.toString(),
        },
      };

      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _isProcessingPayment = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initiating payment: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Booking Period',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        // Rental Period Type Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _rentalPeriod,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              items: [
                DropdownMenuItem(
                  value: 'Day',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.today,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text('Per Day - ₹${widget.bike.pricePerDay.toInt()}'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Week',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text('Per Week - ₹${widget.bike.pricePerWeek.toInt()}'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Month',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text('Per Month - ₹${widget.bike.pricePerMonth.toInt()}'),
                    ],
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _rentalPeriod = newValue;
                    // Reset dates when changing rental period
                    _fromDateTime = null;
                    _toDateTime = null;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateTimeCard(
                title: 'From',
                subtitle: _fromDateTime == null
                    ? 'Select date & time'
                    : _formatDateTime(_fromDateTime!),
                icon: Icons.access_time,
                onTap: () => _selectDateTime(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Opacity(
                opacity: (_rentalPeriod == 'Week' || _rentalPeriod == 'Month')
                    ? 0.6
                    : 1.0,
                child: _buildDateTimeCard(
                  title: 'To',
                  subtitle: _toDateTime == null
                      ? 'Select date & time'
                      : _formatDateTime(_toDateTime!),
                  icon: Icons.access_time_filled,
                  onTap: () => _selectDateTime(false),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightGrey),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: subtitle.contains('Select')
                    ? AppColors.textSecondary
                    : AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Personal Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Required',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Alternate Phone Number
        TextField(
          controller: _alternatePhoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Alternate Phone Number',
            hintText: 'Enter alternate contact number',
            prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.white,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Current Address
        TextField(
          controller: _currentAddressController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Current Address',
            hintText: 'Enter your current residential address',
            prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            alignLabelWithHint: true,
          ),
          onChanged: (value) {
            if (_sameAsCurrentAddress) {
              setState(() {
                _permanentAddressController.text = value;
              });
            }
          },
        ),
        const SizedBox(height: 12),

        // Same as Current Address Checkbox
        Row(
          children: [
            Checkbox(
              value: _sameAsCurrentAddress,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _sameAsCurrentAddress = value ?? false;
                  if (_sameAsCurrentAddress) {
                    _permanentAddressController.text =
                        _currentAddressController.text;
                  }
                });
              },
            ),
            const Expanded(
              child: Text(
                'Permanent address is same as current address',
                style: TextStyle(fontSize: 14, color: AppColors.text),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Permanent Address
        TextField(
          controller: _permanentAddressController,
          maxLines: 3,
          enabled: !_sameAsCurrentAddress,
          decoration: InputDecoration(
            labelText: 'Permanent Address',
            hintText: 'Enter your permanent address',
            prefixIcon: const Icon(Icons.home, color: AppColors.primary),
            filled: true,
            fillColor: _sameAsCurrentAddress
                ? AppColors.grey.withOpacity(0.1)
                : AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.grey.withOpacity(0.2)),
            ),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Document Upload',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Required',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Please upload both documents to proceed with booking',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDocumentCard(
                title: 'Aadhar Card',
                subtitle: 'Upload front side',
                icon: Icons.credit_card,
                image: _aadharCardImage,
                onTap: () => _pickDocument(true),
                isUploading: _isUploadingAadhar,
                hasUrl: _aadharCardUrl != null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDocumentCard(
                title: 'Driving License',
                subtitle: 'Upload front side',
                icon: Icons.drive_eta,
                image: _drivingLicenseImage,
                onTap: () => _pickDocument(false),
                isUploading: _isUploadingLicense,
                hasUrl: _drivingLicenseUrl != null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required File? image,
    required VoidCallback onTap,
    bool isUploading = false,
    bool hasUrl = false,
  }) {
    bool hasImage = image != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasUrl
              ? AppColors.success.withOpacity(0.05)
              : isUploading
              ? AppColors.primary.withOpacity(0.05)
              : hasImage
              ? AppColors.lightGrey.withOpacity(0.3)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasUrl
                ? AppColors.success
                : isUploading
                ? AppColors.primary
                : hasImage
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.lightGrey,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUploading)
              Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Uploading...',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else if (hasUrl)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_done, color: AppColors.success, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Uploaded Successfully',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            else if (hasImage)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Selected',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            else
              Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            if (!isUploading) // Don't show title when uploading (already shown in progress)
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasUrl
                      ? AppColors.success
                      : hasImage
                      ? AppColors.primary
                      : AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
            if (!hasImage) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(bool isFromDate) async {
    // For Week and Month periods, only allow selecting the From date
    if (!isFromDate && (_rentalPeriod == 'Week' || _rentalPeriod == 'Month')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'End date is automatically set for ${_rentalPeriod.toLowerCase()} rental',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    // First select date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Then select time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: AppColors.white,
                surface: AppColors.white,
                onSurface: AppColors.text,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Check if the selected date/time is in the past
        final now = DateTime.now();
        if (selectedDateTime.isBefore(now)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a future date and time'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        // If selecting "To" date, ensure it's after "From" date
        if (!isFromDate && _fromDateTime != null) {
          if (selectedDateTime.isBefore(_fromDateTime!)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('End date must be after start date'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return;
          }
        }

        setState(() {
          if (isFromDate) {
            _fromDateTime = selectedDateTime;
            // Auto-calculate end date based on rental period
            if (_rentalPeriod == 'Week') {
              _toDateTime = selectedDateTime.add(const Duration(days: 7));
            } else if (_rentalPeriod == 'Month') {
              _toDateTime = selectedDateTime.add(const Duration(days: 30));
            }
          } else {
            _toDateTime = selectedDateTime;
          }
        });
      }
    }
  }

  Future<void> _pickDocument(bool isAadhar) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Upload ${isAadhar ? 'Aadhar Card' : 'Driving License'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => _getImage(ImageSource.camera, isAadhar),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImageSourceButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => _getImage(ImageSource.gallery, isAadhar),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source, bool isAadhar) async {
    Navigator.pop(context); // Close bottom sheet

    try {
      // Request permissions based on source
      PermissionStatus permissionStatus;
      if (source == ImageSource.camera) {
        permissionStatus = await Permission.camera.request();
      } else {
        // For gallery access, we need storage permission
        if (Platform.isAndroid) {
          // For Android 13+ (API 33+), we need photos permission
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          if (androidInfo.version.sdkInt >= 33) {
            permissionStatus = await Permission.photos.request();
          } else {
            permissionStatus = await Permission.storage.request();
          }
        } else {
          // For iOS, request photos permission
          permissionStatus = await Permission.photos.request();
        }
      }

      // For iOS photo library, 'limited' access is also acceptable
      final bool hasPermission =
          permissionStatus.isGranted ||
          (Platform.isIOS &&
              source == ImageSource.gallery &&
              permissionStatus == PermissionStatus.limited);

      // Debug: Print permission status
      print('🔍 Permission Status: $permissionStatus');
      print('🔍 Source: $source');
      print('🔍 Platform: ${Platform.isIOS ? "iOS" : "Android"}');
      print('🔍 Has Permission: $hasPermission');

      if (!hasPermission) {
        String message;
        if (permissionStatus.isDenied) {
          message = source == ImageSource.camera
              ? 'Camera permission is required to take photos'
              : 'Photo library permission is required to select images';
        } else if (permissionStatus.isPermanentlyDenied) {
          message = source == ImageSource.camera
              ? 'Camera permission is permanently denied. Please enable it in Settings.'
              : 'Photo library permission is permanently denied. Please enable it in Settings.';
        } else {
          message = source == ImageSource.camera
              ? 'Camera permission is required to take photos'
              : 'Photo library permission is required to select images';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Settings',
              textColor: AppColors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        // Verify the file exists and is readable
        final file = File(pickedFile.path);
        if (await file.exists()) {
          setState(() {
            if (isAadhar) {
              _aadharCardImage = file;
              _isUploadingAadhar = true;
            } else {
              _drivingLicenseImage = file;
              _isUploadingLicense = true;
            }
          });

          // Show initial success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${isAadhar ? 'Aadhar card' : 'Driving license'} selected. Uploading...',
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Upload the file and get URL
          final uploadedUrl = await _uploadFileAndGetUrl(
            file,
            isAadhar ? 'aadhar' : 'license',
          );

          setState(() {
            if (isAadhar) {
              _isUploadingAadhar = false;
              if (uploadedUrl != null) {
                _aadharCardUrl = uploadedUrl;
              }
            } else {
              _isUploadingLicense = false;
              if (uploadedUrl != null) {
                _drivingLicenseUrl = uploadedUrl;
              }
            }
          });

          // Show final success/error message
          if (uploadedUrl != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${isAadhar ? 'Aadhar card' : 'Driving license'} uploaded successfully!',
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to upload ${isAadhar ? 'Aadhar card' : 'driving license'}. Please try again.',
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          throw Exception('Selected file could not be accessed');
        }
      }
    } catch (e) {
      print('Image picker error: $e');

      String errorMessage = 'Failed to pick image';
      if (e.toString().contains('MissingPluginException')) {
        errorMessage =
            'Image picker not available. Please restart the app and try again.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please allow camera/storage access.';
      } else {
        errorMessage = 'Failed to pick image: ${e.toString()}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    String month = months[dateTime.month - 1];
    String day = dateTime.day.toString().padLeft(2, '0');
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month, $hour:$minute';
  }

  Future<void> _applyCoupon() async {
    final couponCode = _couponController.text.trim();

    if (couponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a coupon code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isValidatingCoupon = true;
    });

    try {
      final response = await AuthService.validateCoupon(couponCode);

      if (response['STS'] == '200') {
        final content = response['CONTENT'];

        // Check if coupon is active
        if (content['isActive'] == true) {
          final discount = content['couponDiscount'];

          setState(() {
            _isCouponApplied = true;
            _couponDiscount = discount.toDouble();
            _appliedCouponCode = couponCode;
            _isValidatingCoupon = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Coupon applied! You saved ₹${_discountAmount.toInt()}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _isValidatingCoupon = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This coupon is not active'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() {
          _isValidatingCoupon = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['MSG'] ?? 'Invalid coupon code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isValidatingCoupon = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to validate coupon. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeCoupon() {
    setState(() {
      _isCouponApplied = false;
      _couponDiscount = 0.0;
      _appliedCouponCode = '';
      _couponController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coupon removed'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  bool _canProceedWithBooking() {
    return _aadharCardUrl != null &&
        _drivingLicenseUrl != null &&
        _fromDateTime != null &&
        _toDateTime != null &&
        _alternatePhoneController.text.trim().isNotEmpty &&
        _currentAddressController.text.trim().isNotEmpty &&
        _permanentAddressController.text.trim().isNotEmpty &&
        _acceptedTermsAndConditions &&
        _acceptedDepositTerms &&
        (widget.bike.isAvailable || widget.fromRequest) &&
        !_isUploadingAadhar &&
        !_isUploadingLicense &&
        !_isProcessingPayment;
  }

  /// Get the uploaded Aadhar card URL for booking API
  String? get aadharCardUrl => _aadharCardUrl;

  /// Get the uploaded driving license URL for booking API
  String? get drivingLicenseUrl => _drivingLicenseUrl;

  Widget _buildFallbackImage() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.directions_bike,
            size: 120,
            color: AppColors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }
}
