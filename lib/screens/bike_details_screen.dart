import 'package:flutter/material.dart';
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
import 'booking_confirmation_screen.dart';

class BikeDetailsScreen extends StatefulWidget {
  final BikeModel bike;

  const BikeDetailsScreen({super.key, required this.bike});

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

  // Calculate number of days between selected dates
  int get _calculatedDays {
    if (_fromDateTime == null || _toDateTime == null) return 1;
    final difference = _toDateTime!.difference(_fromDateTime!);
    return difference.inDays > 0 ? difference.inDays : 1;
  }

  // Calculate total cost based on selected dates
  double get _totalCost {
    return widget.bike.pricePerDay * _calculatedDays;
  }

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
  }

  @override
  void dispose() {
    _razorpay.clear();
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

      // Create booking using the API
      final bookingResult = await AuthService.createBooking(
        widget.bike.id.toString(),
        userId,
        _formatDateTimeForAPI(_fromDateTime!),
        _formatDateTimeForAPI(_toDateTime!),
        response.paymentId ?? '',
        _totalCost,
        _aadharCardUrl ?? '',
        _drivingLicenseUrl ?? '',
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

        // Navigate to booking confirmation after successful booking creation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              bike: widget.bike,
              duration: _calculatedDays,
              totalCost: _totalCost,
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
                  child: const Icon(
                    Icons.favorite_border,
                    color: AppColors.text,
                  ),
                ),
                onPressed: () {
                  // Handle favorite
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
                                'Total Cost:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              Text(
                                '₹${_totalCost.toInt()}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
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

                    // Document Upload Section
                    _buildDocumentUpload(),

                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
                  ? 'Book Now for ₹${_totalCost.toInt()}'
                  : widget.bike.isAvailable
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

  void _handleBooking() {
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
      final amountInPaise = (_totalCost * 100).toInt();

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
              child: _buildDateTimeCard(
                title: 'To',
                subtitle: _toDateTime == null
                    ? 'Select date & time'
                    : _formatDateTime(_toDateTime!),
                icon: Icons.access_time_filled,
                onTap: () => _selectDateTime(false),
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

        setState(() {
          if (isFromDate) {
            _fromDateTime = selectedDateTime;
            // Don't automatically set to date, let user choose
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
          permissionStatus = await Permission.photos.request();
        }
      }

      if (permissionStatus != PermissionStatus.granted) {
        String message = source == ImageSource.camera
            ? 'Camera permission is required to take photos'
            : 'Storage permission is required to access gallery';

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
      print('Image picker error: $e'); // Debug print

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

  bool _canProceedWithBooking() {
    return _aadharCardUrl != null &&
        _drivingLicenseUrl != null &&
        _fromDateTime != null &&
        _toDateTime != null &&
        widget.bike.isAvailable &&
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
