import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../services/admin_service.dart';
import '../models/dashboard_stats.dart';
import '../widgets/widgets.dart';
import '../widgets/admin_drawer.dart';
import 'add_bike_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  DashboardStats? _stats;
  bool _isLoading = true;
  String? _error;
  List<AdminAlert> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await AdminService.getDashboardStats();
      final alerts = await AdminService.getAlerts();

      setState(() {
        _stats = stats;
        _alerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading dashboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadDashboardData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back, Admin!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Here\'s what\'s happening with RevUp Bikes today',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Statistics Cards
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_stats != null) ...[
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          StatsCard(
                            title: 'Total Bikes',
                            value: _stats!.totalBikes.toString(),
                            icon: Icons.directions_bike,
                            color: Colors.blue,
                            trend: _stats!.bikeTrend,
                          ),
                          StatsCard(
                            title: 'Active Rentals',
                            value: _stats!.activeRentals.toString(),
                            icon: Icons.trending_up,
                            color: Colors.green,
                            trend: _stats!.rentalTrend,
                          ),
                          StatsCard(
                            title: 'Upcoming Bookings',
                            value: _stats!.upcomingBookings.toString(),
                            icon: Icons.schedule,
                            color: Colors.orange,
                            trend: _stats!.bookingTrend,
                          ),
                          StatsCard(
                            title: 'Revenue (₹)',
                            value: _stats!.revenue.toStringAsFixed(0),
                            icon: Icons.currency_rupee,
                            color: Colors.purple,
                            trend: _stats!.revenueTrend,
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Alerts Section
                    if (_alerts.isNotEmpty) ...[
                      Row(
                        children: [
                          Text(
                            'Alerts',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _alerts.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._alerts.map((alert) => AlertCard(alert: alert)),
                      const SizedBox(height: 32),
                    ],

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                      children: [
                        QuickActionCard(
                          title: 'Add New Bike',
                          subtitle: 'Register new bikes',
                          icon: Icons.add_circle,
                          color: Colors.blue,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddBikeScreen(),
                              ),
                            );

                            // Refresh data if bike was added successfully
                            if (result == true) {
                              _loadDashboardData();
                            }
                          },
                        ),
                        QuickActionCard(
                          title: 'View Bookings',
                          subtitle: 'Monitor reservations',
                          icon: Icons.book_online,
                          color: Colors.blue,
                          onTap: () {
                            // Navigate to booking management
                          },
                        ),
                        QuickActionCard(
                          title: 'View Reports',
                          subtitle: 'Analytics & insights',
                          icon: Icons.analytics,
                          color: Colors.purple,
                          onTap: () {
                            // Navigate to reports
                          },
                        ),
                        QuickActionCard(
                          title: 'Manage Users',
                          subtitle: 'User accounts & roles',
                          icon: Icons.people,
                          color: Colors.orange,
                          onTap: () {
                            // Navigate to user management
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
