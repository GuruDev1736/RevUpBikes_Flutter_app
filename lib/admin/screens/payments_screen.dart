import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../widgets/admin_drawer.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String _selectedFilter = 'All';
  String _selectedPeriod = 'This Month';

  final List<String> _filters = [
    'All',
    'Successful',
    'Failed',
    'Pending',
    'Refunded',
  ];

  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'Last Month',
    'This Year',
  ];

  final List<Map<String, dynamic>> _payments = [
    {
      'id': 'PAY001',
      'userId': 'U123',
      'userName': 'John Smith',
      'userEmail': 'john.smith@email.com',
      'amount': 60.00,
      'status': 'Successful',
      'paymentMethod': 'Credit Card',
      'cardLast4': '4532',
      'transactionDate': DateTime.now().subtract(const Duration(hours: 2)),
      'bookingId': 'BK001',
      'bikeName': 'Thunder Pro',
      'duration': '4 hours',
    },
    {
      'id': 'PAY002',
      'userId': 'U124',
      'userName': 'Emma Davis',
      'userEmail': 'emma.davis@email.com',
      'amount': 80.00,
      'status': 'Successful',
      'paymentMethod': 'Digital Wallet',
      'cardLast4': 'PayPal',
      'transactionDate': DateTime.now().subtract(const Duration(hours: 6)),
      'bookingId': 'BK002',
      'bikeName': 'Electric Bolt',
      'duration': '4 hours',
    },
    {
      'id': 'PAY003',
      'userId': 'U125',
      'userName': 'Michael Chen',
      'userEmail': 'michael.chen@email.com',
      'amount': 34.00,
      'status': 'Failed',
      'paymentMethod': 'Credit Card',
      'cardLast4': '8765',
      'transactionDate': DateTime.now().subtract(const Duration(hours: 8)),
      'bookingId': 'BK003',
      'bikeName': 'City Cruiser',
      'duration': '4 hours',
    },
    {
      'id': 'PAY004',
      'userId': 'U126',
      'userName': 'Sarah Johnson',
      'userEmail': 'sarah.johnson@email.com',
      'amount': 30.00,
      'status': 'Successful',
      'paymentMethod': 'Debit Card',
      'cardLast4': '2198',
      'transactionDate': DateTime.now().subtract(const Duration(days: 1)),
      'bookingId': 'BK004',
      'bikeName': 'Green Machine',
      'duration': '3 hours',
    },
    {
      'id': 'PAY005',
      'userId': 'U127',
      'userName': 'David Wilson',
      'userEmail': 'david.wilson@email.com',
      'amount': 48.00,
      'status': 'Pending',
      'paymentMethod': 'Bank Transfer',
      'cardLast4': 'Transfer',
      'transactionDate': DateTime.now().subtract(const Duration(hours: 4)),
      'bookingId': 'BK005',
      'bikeName': 'Speed Demon',
      'duration': '4 hours',
    },
    {
      'id': 'PAY006',
      'userId': 'U128',
      'userName': 'Lisa Williams',
      'userEmail': 'lisa.williams@email.com',
      'amount': 25.00,
      'status': 'Refunded',
      'paymentMethod': 'Credit Card',
      'cardLast4': '9876',
      'transactionDate': DateTime.now().subtract(const Duration(days: 2)),
      'bookingId': 'BK006',
      'bikeName': 'City Cruiser',
      'duration': '2.5 hours',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text(
          'Payment Management',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _showComingSoon('Export Payments'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Revenue Summary
          _buildRevenueSummary(),

          // Period and Filter Controls
          _buildControls(),

          // Payment Statistics
          _buildPaymentStats(),

          // Payment List
          Expanded(child: _buildPaymentList()),
        ],
      ),
    );
  }

  Widget _buildRevenueSummary() {
    final totalRevenue = _payments
        .where((payment) => payment['status'] == 'Successful')
        .fold(0.0, (sum, payment) => sum + payment['amount']);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Revenue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${totalRevenue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+18.5% from last month',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Period Selection
          Row(
            children: [
              const Text(
                'Period: ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _periods.map((period) {
                      final isSelected = _selectedPeriod == period;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(period),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedPeriod = period;
                            });
                          },
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Status Filter
          Row(
            children: [
              const Text(
                'Status: ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStats() {
    final successful = _payments
        .where((p) => p['status'] == 'Successful')
        .length;
    final failed = _payments.where((p) => p['status'] == 'Failed').length;
    final pending = _payments.where((p) => p['status'] == 'Pending').length;
    final refunded = _payments.where((p) => p['status'] == 'Refunded').length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Successful',
              successful.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Failed',
              failed.toString(),
              Icons.error,
              Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Pending',
              pending.toString(),
              Icons.schedule,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Refunded',
              refunded.toString(),
              Icons.undo,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList() {
    final filteredPayments = _getFilteredPayments();

    if (filteredPayments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No payments found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPayments.length,
      itemBuilder: (context, index) {
        return _buildPaymentCard(filteredPayments[index]);
      },
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final status = payment['status'] as String;
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment['userName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Payment ID: ${payment['id']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${payment['amount'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, payment),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 20),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    if (status == 'Successful')
                      const PopupMenuItem(
                        value: 'refund',
                        child: Row(
                          children: [
                            Icon(Icons.undo, size: 20, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Process Refund'),
                          ],
                        ),
                      ),
                    if (status == 'Failed')
                      const PopupMenuItem(
                        value: 'retry',
                        child: Row(
                          children: [
                            Icon(Icons.refresh, size: 20, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Retry Payment'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'receipt',
                      child: Row(
                        children: [
                          Icon(Icons.receipt, size: 20),
                          SizedBox(width: 8),
                          Text('Download Receipt'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Booking Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_bike,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment['bikeName'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Duration: ${payment['duration']} • Booking: ${payment['bookingId']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Payment Method and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getPaymentMethodIcon(payment['paymentMethod']),
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${payment['paymentMethod']} •••• ${payment['cardLast4']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Text(
                  _formatDateTime(payment['transactionDate']),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredPayments() {
    if (_selectedFilter == 'All') {
      return _payments;
    }
    return _payments
        .where((payment) => payment['status'] == _selectedFilter)
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Successful':
        return Colors.green;
      case 'Failed':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      case 'Refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Successful':
        return Icons.check_circle;
      case 'Failed':
        return Icons.error;
      case 'Pending':
        return Icons.schedule;
      case 'Refunded':
        return Icons.undo;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'credit card':
      case 'debit card':
        return Icons.credit_card;
      case 'digital wallet':
        return Icons.account_balance_wallet;
      case 'bank transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action, Map<String, dynamic> payment) {
    switch (action) {
      case 'details':
        _showPaymentDetails(payment);
        break;
      case 'refund':
        _showRefundConfirmation(payment);
        break;
      case 'retry':
        _showComingSoon('Retry Payment');
        break;
      case 'receipt':
        _showComingSoon('Download Receipt');
        break;
    }
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Details',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Payment ID', payment['id']),
              _buildDetailRow(
                'User',
                '${payment['userName']} (${payment['userEmail']})',
              ),
              _buildDetailRow(
                'Amount',
                '\$${payment['amount'].toStringAsFixed(2)}',
              ),
              _buildDetailRow('Status', payment['status']),
              _buildDetailRow('Payment Method', payment['paymentMethod']),
              _buildDetailRow('Card/Account', '•••• ${payment['cardLast4']}'),
              _buildDetailRow('Booking ID', payment['bookingId']),
              _buildDetailRow('Bike', payment['bikeName']),
              _buildDetailRow('Duration', payment['duration']),
              _buildDetailRow(
                'Transaction Date',
                _formatDateTime(payment['transactionDate']),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showRefundConfirmation(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to process a refund for:'),
            const SizedBox(height: 8),
            Text('• User: ${payment['userName']}'),
            Text('• Amount: \$${payment['amount'].toStringAsFixed(2)}'),
            Text('• Booking: ${payment['bookingId']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Process Refund');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Process Refund'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
