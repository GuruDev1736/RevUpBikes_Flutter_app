import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../widgets/admin_drawer.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Due Soon',
    'Overdue',
    'In Progress',
    'Completed',
  ];

  final List<Map<String, dynamic>> _maintenanceItems = [
    {
      'id': 'M001',
      'bikeName': 'Electric Bolt',
      'bikeId': 'B003',
      'type': 'Routine Check',
      'status': 'Due Soon',
      'dueDate': DateTime.now().add(const Duration(days: 3)),
      'lastService': DateTime.now().subtract(const Duration(days: 87)),
      'priority': 'Medium',
      'estimatedCost': 150.0,
      'description':
          'Brake inspection, tire pressure check, battery diagnostic',
    },
    {
      'id': 'M002',
      'bikeName': 'Mountain Pro',
      'bikeId': 'B007',
      'type': 'Brake Repair',
      'status': 'Overdue',
      'dueDate': DateTime.now().subtract(const Duration(days: 5)),
      'lastService': DateTime.now().subtract(const Duration(days: 120)),
      'priority': 'High',
      'estimatedCost': 85.0,
      'description': 'Replace brake pads and adjust cables',
    },
    {
      'id': 'M003',
      'bikeName': 'City Cruiser',
      'bikeId': 'B002',
      'type': 'Chain Replacement',
      'status': 'In Progress',
      'dueDate': DateTime.now(),
      'lastService': DateTime.now().subtract(const Duration(days: 95)),
      'priority': 'Medium',
      'estimatedCost': 45.0,
      'description': 'Chain showing signs of wear, needs replacement',
    },
    {
      'id': 'M004',
      'bikeName': 'Speed Demon',
      'bikeId': 'B004',
      'type': 'Full Service',
      'status': 'Completed',
      'dueDate': DateTime.now().subtract(const Duration(days: 2)),
      'lastService': DateTime.now().subtract(const Duration(days: 2)),
      'priority': 'Low',
      'estimatedCost': 200.0,
      'description': 'Complete overhaul and tune-up',
    },
    {
      'id': 'M005',
      'bikeName': 'Thunder Pro',
      'bikeId': 'B001',
      'type': 'Tire Replacement',
      'status': 'Due Soon',
      'dueDate': DateTime.now().add(const Duration(days: 7)),
      'lastService': DateTime.now().subtract(const Duration(days: 75)),
      'priority': 'Medium',
      'estimatedCost': 120.0,
      'description': 'Front tire showing wear, rear tire needs inspection',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text(
          'Maintenance Management',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddMaintenanceDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Overview
          _buildStatsOverview(),

          // Filter Tabs
          _buildFilterTabs(),

          // Maintenance List
          Expanded(child: _buildMaintenanceList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleMaintenanceDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.schedule, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsOverview() {
    final dueSoon = _maintenanceItems
        .where((item) => item['status'] == 'Due Soon')
        .length;
    final overdue = _maintenanceItems
        .where((item) => item['status'] == 'Overdue')
        .length;
    final inProgress = _maintenanceItems
        .where((item) => item['status'] == 'In Progress')
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Due Soon',
              dueSoon.toString(),
              Icons.schedule,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Overdue',
              overdue.toString(),
              Icons.warning,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'In Progress',
              inProgress.toString(),
              Icons.build,
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Filter: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
    );
  }

  Widget _buildMaintenanceList() {
    final filteredItems = _getFilteredItems();

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build_circle_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No maintenance items found',
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
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return _buildMaintenanceCard(filteredItems[index]);
      },
    );
  }

  Widget _buildMaintenanceCard(Map<String, dynamic> item) {
    final status = item['status'] as String;
    final priority = item['priority'] as String;

    Color statusColor = _getStatusColor(status);
    Color priorityColor = _getPriorityColor(priority);
    IconData statusIcon = _getStatusIcon(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                        item['bikeName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item['type'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        priority.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: priorityColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(value, item),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 20),
                              SizedBox(width: 8),
                              Text('View Details'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        if (status != 'Completed')
                          const PopupMenuItem(
                            value: 'complete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 20,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 8),
                                Text('Mark Complete'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status and Due Date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Due: ${_formatDate(item['dueDate'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              item['description'],
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),

            const SizedBox(height: 16),

            // Bottom Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Cost',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '\$${item['estimatedCost'].toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Last Service',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      _formatDate(item['lastService']),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    if (_selectedFilter == 'All') {
      return _maintenanceItems;
    }
    return _maintenanceItems
        .where((item) => item['status'] == _selectedFilter)
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Due Soon':
        return Colors.orange;
      case 'Overdue':
        return Colors.red;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Due Soon':
        return Icons.schedule;
      case 'Overdue':
        return Icons.warning;
      case 'In Progress':
        return Icons.build;
      case 'Completed':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuAction(String action, Map<String, dynamic> item) {
    switch (action) {
      case 'view':
        _showMaintenanceDetails(item);
        break;
      case 'edit':
        _showComingSoon('Edit Maintenance');
        break;
      case 'complete':
        _showCompleteConfirmation(item);
        break;
      case 'delete':
        _showDeleteConfirmation(item);
        break;
    }
  }

  void _showMaintenanceDetails(Map<String, dynamic> item) {
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
                'Maintenance Details',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Bike', item['bikeName']),
              _buildDetailRow('Type', item['type']),
              _buildDetailRow('Status', item['status']),
              _buildDetailRow('Priority', item['priority']),
              _buildDetailRow('Due Date', _formatDate(item['dueDate'])),
              _buildDetailRow('Last Service', _formatDate(item['lastService'])),
              _buildDetailRow(
                'Estimated Cost',
                '\$${item['estimatedCost'].toStringAsFixed(2)}',
              ),
              _buildDetailRow('Description', item['description']),
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
            width: 100,
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

  void _showCompleteConfirmation(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Maintenance'),
        content: Text(
          'Mark maintenance for "${item['bikeName']}" as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Complete Maintenance');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Maintenance'),
        content: Text(
          'Are you sure you want to delete this maintenance record for "${item['bikeName']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Delete Maintenance');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddMaintenanceDialog() {
    _showComingSoon('Add Maintenance Record');
  }

  void _showScheduleMaintenanceDialog() {
    _showComingSoon('Schedule Maintenance');
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
