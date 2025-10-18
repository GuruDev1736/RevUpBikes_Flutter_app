import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/bike_model.dart';
import 'invoice_viewer_screen.dart';
import 'home_screen.dart';
import 'my_rides_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final BikeModel bike;
  final int duration;
  final double totalCost;
  final String? paymentId;
  final String? orderId;
  final Map<String, dynamic>? bookingData;

  const BookingConfirmationScreen({
    super.key,
    required this.bike,
    required this.duration,
    required this.totalCost,
    this.paymentId,
    this.orderId,
    this.bookingData,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get bookingId {
    // Try to get booking ID from API response first
    if (widget.bookingData != null) {
      final id =
          widget.bookingData!['bookingId'] ??
          widget.bookingData!['id'] ??
          widget.bookingData!['booking_id'];
      if (id != null) return id.toString();
    }

    // Fallback to generated ID
    return 'RU${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  String? get invoiceUrl {
    // Extract invoice URL from booking response
    if (widget.bookingData != null) {
      // Debug: Print all available keys in booking data
      print('Booking data keys: ${widget.bookingData!.keys.toList()}');
      print('Booking data: ${widget.bookingData}');
      
      final url = widget.bookingData!['invoiceUrl'] ?? 
                  widget.bookingData!['invoice_url'] ??
                  widget.bookingData!['invoicePdfUrl'] ??
                  widget.bookingData!['invoice_pdf_url'];
      
      print('Extracted invoice URL: $url');
      return url;
    }
    return null;
  }

  String _formatBookingDate(String dateTimeString) {
    try {
      // Parse the date string (expected format: "2025-10-15 09:00")
      final parts = dateTimeString.split(' ');
      if (parts.length >= 2) {
        final datePart = parts[0]; // "2025-10-15"
        final timePart = parts[1]; // "09:00"

        final dateParts = datePart.split('-');
        if (dateParts.length == 3) {
          final year = dateParts[0];
          final month = dateParts[1];
          final day = dateParts[2];

          // Convert to more readable format
          final monthNames = [
            '',
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

          final monthNum = int.tryParse(month) ?? 1;
          final monthName = monthNum <= 12 ? monthNames[monthNum] : month;

          return '$day $monthName $year, $timePart';
        }
      }

      return dateTimeString; // Return original if parsing fails
    } catch (e) {
      return dateTimeString; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Top spacing
              const SizedBox(height: 40), // Reduced from 60
              // Success Animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30), // Reduced from 40
              // Success Text
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'Booking Confirmed!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.paymentId != null
                              ? 'Your bike is booked and payment confirmed!'
                              : 'Your bike is booked successfully!',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30), // Reduced from 40
              // Booking Details Card
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.grey.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Booking Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 16), // Reduced from 20
                          // Bike Info
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.grey.withOpacity(0.2),
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: widget.bike.getImageWidget(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.bike.bikeName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.bike.category,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20), // Reduced from 24
                          // Booking Info
                          _buildDetailRow(
                            'Duration',
                            widget.duration == 1
                                ? '1 Day'
                                : '${widget.duration} Days',
                            Icons.access_time,
                          ),
                          const SizedBox(height: 12),
                          if (widget.bookingData != null) ...[
                            if (widget.bookingData!['startDateTime'] != null)
                              _buildDetailRow(
                                'Start Date',
                                _formatBookingDate(
                                  widget.bookingData!['startDateTime'],
                                ),
                                Icons.event_available,
                              ),
                            const SizedBox(height: 12),
                            if (widget.bookingData!['endDateTime'] != null)
                              _buildDetailRow(
                                'End Date',
                                _formatBookingDate(
                                  widget.bookingData!['endDateTime'],
                                ),
                                Icons.event_busy,
                              ),
                            const SizedBox(height: 12),
                          ],
                          const SizedBox(height: 12), // Reduced from 16
                          _buildDetailRow(
                            'Pickup Location',
                            widget.bike.place.placeName,
                            Icons.location_on,
                          ),
                          const SizedBox(height: 12), // Reduced from 16
                          _buildDetailRow(
                            'Booking ID',
                            bookingId,
                            Icons.confirmation_number,
                          ),
                          if (widget.paymentId != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Payment ID',
                              widget.paymentId!,
                              Icons.payment,
                            ),
                          ],

                          const SizedBox(height: 20), // Reduced from 24
                          // Total Cost
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  '₹${widget.totalCost.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 40,
              ), // Added fixed spacing instead of Spacer
              // Action Buttons
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Generate Invoice Button
                        Container(
                          width: double.infinity,
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
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InvoiceViewerScreen(
                                    bookingId: bookingId,
                                    bikeName: widget.bike.bikeName,
                                    invoiceUrl: invoiceUrl, // Pass the invoice URL from API response
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.receipt_long,
                              color: AppColors.white,
                            ),
                            label: const Text(
                              'Generate Invoice',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Track Booking Button
                        Container(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Navigate to My Rides screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyRidesScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.location_searching,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              'Track Booking',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Go to Home Button
                        Container(
                          width: double.infinity,
                          height: 55,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            icon: const Icon(
                              Icons.home,
                              color: AppColors.textSecondary,
                            ),
                            label: const Text(
                              'Go to Home',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
