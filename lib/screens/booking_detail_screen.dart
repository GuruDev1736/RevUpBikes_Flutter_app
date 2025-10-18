import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'invoice_viewer_screen.dart';

class BookingDetailScreen extends StatelessWidget {
  final dynamic bookingData;

  const BookingDetailScreen({
    super.key,
    required this.bookingData,
  });

  @override
  Widget build(BuildContext context) {
    final bike = bookingData['bike'] ?? {};
    final status = bookingData['bookingStatus']?.toString() ?? 'N/A';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Gradient
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: const Text(
                'Booking Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 50,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50), // Space for title
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking Info Card
                  _buildSectionCard(
                    title: 'Booking Information',
                    icon: Icons.confirmation_number,
                    children: [
                      _buildInfoRow(
                        'Booking ID',
                        '#${bookingData['id']?.toString() ?? 'N/A'}',
                        Icons.numbers,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Booking Status',
                        status,
                        Icons.info_outline,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Start Date & Time',
                        _formatDateTime(bookingData['startDateTime']),
                        Icons.event,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'End Date & Time',
                        _formatDateTime(bookingData['endDateTime']),
                        Icons.event_available,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Total Duration',
                        '${bookingData['totalDays'] ?? 0} days (${bookingData['totalHours'] ?? 0} hours)',
                        Icons.timer,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bike Details Card
                  _buildSectionCard(
                    title: 'Bike Details',
                    icon: Icons.directions_bike,
                    children: [
                      _buildInfoRow(
                        'Bike Name',
                        bike['bikeName']?.toString() ?? 'N/A',
                        Icons.two_wheeler,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Model',
                        bike['bikeModel']?.toString() ?? 'N/A',
                        Icons.category,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Brand',
                        bike['brand']?.toString() ?? 'N/A',
                        Icons.branding_watermark,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Category',
                        bike['category']?.toString() ?? 'N/A',
                        Icons.label,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Registration Number',
                        bike['registrationNumber']?.toString() ?? 'N/A',
                        Icons.confirmation_number_outlined,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Fuel Type',
                        bike['fuelType']?.toString() ?? 'N/A',
                        Icons.local_gas_station,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Transmission',
                        bike['transmission']?.toString() ?? 'N/A',
                        Icons.settings,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Payment Details Card
                  _buildSectionCard(
                    title: 'Payment Details',
                    icon: Icons.payment,
                    children: [
                      _buildInfoRow(
                        'Payment ID',
                        bookingData['paymentId']?.toString() ?? 'N/A',
                        Icons.receipt,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Payment Status',
                        bookingData['paymentStatus']?.toString() ?? 'N/A',
                        Icons.account_balance_wallet,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Total Amount',
                        '₹${bookingData['totalAmount']?.toString() ?? '0'}',
                        Icons.currency_rupee,
                        valueStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Location Details Card
                  if (bike['place'] != null) ...[
                    _buildSectionCard(
                      title: 'Pickup Location',
                      icon: Icons.location_on,
                      children: [
                        _buildInfoRow(
                          'Place Name',
                          bike['place']['placeName']?.toString() ?? 'N/A',
                          Icons.place,
                        ),
                        const Divider(height: 20),
                        _buildInfoRow(
                          'Location',
                          bike['place']['placeLocation']?.toString() ?? 'N/A',
                          Icons.location_city,
                        ),
                        const Divider(height: 20),
                        _buildInfoRow(
                          'Description',
                          bike['place']['placeDescription']?.toString() ?? 'N/A',
                          Icons.description,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Documents Card
                  _buildSectionCard(
                    title: 'Documents',
                    icon: Icons.folder_outlined,
                    children: [
                      if (bookingData['aadharcardUrl'] != null)
                        _buildDocumentRow(
                          context,
                          'Aadhar Card',
                          bookingData['aadharcardUrl'].toString(),
                          Icons.credit_card,
                        ),
                      if (bookingData['aadharcardUrl'] != null &&
                          bookingData['drivingLicenseUrl'] != null)
                        const Divider(height: 20),
                      if (bookingData['drivingLicenseUrl'] != null)
                        _buildDocumentRow(
                          context,
                          'Driving License',
                          bookingData['drivingLicenseUrl'].toString(),
                          Icons.badge,
                        ),
                    ],
                  ),

                  // Cancellation Reason (if cancelled)
                  if (bookingData['cancellationReason'] != null) ...[
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Cancellation Details',
                      icon: Icons.cancel,
                      children: [
                        _buildInfoRow(
                          'Cancellation Reason',
                          bookingData['cancellationReason'].toString(),
                          Icons.comment,
                          valueColor: Colors.red,
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Invoice Button
                  if (bookingData['invoiceUrl'] != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvoiceViewerScreen(
                                bookingId: bookingData['id']?.toString() ?? '',
                                bikeName: bike['bikeName']?.toString() ?? 'Bike',
                                invoiceUrl: bookingData['invoiceUrl'].toString(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf, size: 24),
                        label: const Text(
                          'View Invoice',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: valueStyle ??
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppColors.text,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentRow(BuildContext context, String label, String url, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Uploaded',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20,
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showDocumentViewer(context, label, url),
          icon: const Icon(Icons.visibility),
          color: AppColors.primary,
          iconSize: 22,
          tooltip: 'View Document',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  void _showDocumentViewer(BuildContext context, String title, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            // Document Image
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.image, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  // Image
                  Flexible(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 400,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 400,
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 60,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';
    
    try {
      final dateTimeStr = dateTime.toString();
      if (dateTimeStr.contains(' ')) {
        final parts = dateTimeStr.split(' ');
        final dateParts = parts[0].split('-');
        final timeParts = parts[1].split(':');
        
        final dt = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
        
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final date = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
        
        final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final minute = dt.minute.toString().padLeft(2, '0');
        final period = dt.hour >= 12 ? 'PM' : 'AM';
        final time = '$hour:$minute $period';
        
        return '$date at $time';
      }
      return dateTimeStr;
    } catch (e) {
      return dateTime.toString();
    }
  }
}
