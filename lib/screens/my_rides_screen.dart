import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_services.dart';
import 'booking_detail_screen.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _tabController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _tabAnimation;

  int _selectedTab = 0; // 0: Current, 1: History, 2: Upcoming
  List<dynamic> _allBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _tabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _tabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _tabController, curve: Curves.easeInOut));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _tabController.forward();

    // Load bookings after animations start
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userData = await AuthService.getUserData();
      final userId = userData?['CONTENT']["userId"];

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to view your rides'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await AuthService.getAllBookingsByUserId(userId);

      if (response['STS'] == '200') {
        setState(() {
          _allBookings = response['CONTENT'] ?? [];
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['MSG'] ?? 'Failed to load bookings'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading bookings: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildAnimatedHeader(),

            // Tab selector
            _buildAnimatedTabs(),

            // Content based on selected tab
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Header with back button
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'My Rides',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Filter or settings
                      },
                      icon: const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Stats row
                SlideTransition(
                  position: _slideAnimation,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Rides',
                          value: _getTotalRides().toString(),
                          icon: Icons.directions_bike,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'This Month',
                          value: _getThisMonthRides().toString(),
                          icon: Icons.calendar_today,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Hours',
                          value: _getTotalHours().toString(),
                          icon: Icons.access_time,
                          color: Colors.white,
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
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTabs() {
    return AnimatedBuilder(
      animation: _tabAnimation,
      builder: (context, child) {
        return ScaleTransition(
          scale: _tabAnimation,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(child: _buildTabButton('Current', 0)),
                Expanded(child: _buildTabButton('History', 1)),
                Expanded(child: _buildTabButton('Upcoming', 2)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading your rides...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    switch (_selectedTab) {
      case 0:
        return _buildCurrentRides();
      case 1:
        return _buildRideHistory();
      case 2:
        return _buildUpcomingRides();
      default:
        return _buildCurrentRides();
    }
  }

  Widget _buildCurrentRides() {
    final currentRides = _getCurrentRides();

    if (currentRides.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadBookings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: _buildEmptyState(
              icon: Icons.directions_bike,
              title: 'No Active Rides',
              subtitle: 'You don\'t have any active rides right now',
              buttonText: 'Find a Bike',
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _loadBookings,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: currentRides.length,
              itemBuilder: (context, index) {
                final ride = currentRides[index];

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: _buildCurrentRideCard(ride),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRideHistory() {
    final historyRides = _getHistoryRides();

    if (historyRides.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadBookings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: _buildEmptyState(
              icon: Icons.history,
              title: 'No Ride History',
              subtitle: 'Your completed rides will appear here',
              buttonText: 'Start Your First Ride',
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _loadBookings,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: historyRides.length,
              itemBuilder: (context, index) {
                final ride = historyRides[index];

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: _buildHistoryRideCard(ride),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingRides() {
    final upcomingRides = _getUpcomingRides();

    if (upcomingRides.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadBookings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: _buildEmptyState(
              icon: Icons.event,
              title: 'No Upcoming Rides',
              subtitle: 'Book a bike to see your upcoming rides',
              buttonText: 'Book a Ride',
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _loadBookings,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: upcomingRides.length,
              itemBuilder: (context, index) {
                final ride = upcomingRides[index];

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: _buildUpcomingRideCard(ride),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentRideCard(RideModel ride) {
    return GestureDetector(
      onTap: () => _showBookingDetails(ride, ride.bookingData ?? {}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Text(
                ride.status.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Bike image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildBikeImage(ride),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Ride info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.bikeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Started: ${ride.startTime}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Duration: ${ride.duration}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ), // Close Container (child of GestureDetector)
    ); // Close GestureDetector
  }

  Widget _buildHistoryRideCard(RideModel ride) {
    return GestureDetector(
      onTap: () => _showBookingDetails(ride, ride.bookingData ?? {}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Bike image
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildBikeImage(ride),
                ),
              ),

              const SizedBox(width: 16),

              // Ride info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.bikeName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ride.date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Duration: ${ride.duration}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Price
              Text(
                '₹${ride.totalCost}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ), // Close Container (child of GestureDetector)
    ); // Close GestureDetector
  }

  Widget _buildUpcomingRideCard(RideModel ride) {
    return GestureDetector(
      onTap: () => _showBookingDetails(ride, ride.bookingData ?? {}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: const Text(
                'UPCOMING',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Bike image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildBikeImage(ride),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Ride info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.bikeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Date: ${ride.date}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Time: ${ride.startTime}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cancel button - only show for CONFIRMED bookings
                  if (ride.status.toUpperCase() == 'CONFIRMED')
                    TextButton(
                      onPressed: () {
                        _showCancelBookingDialog(ride);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ), // Close Container (child of GestureDetector)
    ); // Close GestureDetector
  }

  void _showBookingDetails(RideModel ride, dynamic bookingData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailScreen(bookingData: bookingData),
      ),
    );
  }

  void _showCancelBookingDialog(RideModel ride) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async {
            reasonController.dispose();
            return true;
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Cancel Booking'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to cancel your booking for ${ride.bikeName}?',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cancellation Reason:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Please provide a reason for cancellation...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  reasonController.dispose();
                  Navigator.pop(dialogContext);
                },
                child: const Text('Keep Booking'),
              ),
              ElevatedButton(
                onPressed: () {
                  final reason = reasonController.text.trim();

                  if (reason.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please provide a cancellation reason'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  reasonController.dispose();
                  Navigator.pop(dialogContext);
                  _cancelBooking(ride.id, reason);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancel Booking'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cancelBooking(String bookingId, String reason) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Cancelling booking...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      final response = await AuthService.cancelBooking(bookingId, reason);

      // Close loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (response['STS'] == '200') {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Reload bookings to refresh the list
        await _loadBookings();
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['MSG'] ?? 'Failed to cancel booking'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling booking: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Stats calculation methods
  int _getTotalRides() {
    if (_isLoading || _allBookings.isEmpty) return 0;
    // Count all bookings except CANCELLED
    return _allBookings.where((booking) {
      final status = booking['bookingStatus']?.toString().toUpperCase() ?? '';
      return status != 'CANCELLED';
    }).length;
  }

  int _getThisMonthRides() {
    if (_isLoading || _allBookings.isEmpty) return 0;
    final now = DateTime.now();

    // Count bookings from current month (not cancelled)
    return _allBookings.where((booking) {
      final status = booking['bookingStatus']?.toString().toUpperCase() ?? '';
      if (status == 'CANCELLED') return false;

      final startDateStr = booking['startDateTime']?.toString() ?? '';
      if (startDateStr.isEmpty) return false;

      try {
        DateTime startDate;
        if (startDateStr.contains(' ')) {
          final parts = startDateStr.split(' ');
          final dateParts = parts[0].split('-');
          startDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          );
        } else {
          startDate = DateTime.parse(startDateStr);
        }

        return startDate.year == now.year && startDate.month == now.month;
      } catch (e) {
        return false;
      }
    }).length;
  }

  int _getTotalHours() {
    if (_isLoading || _allBookings.isEmpty) return 0;

    // Sum up all totalHours from non-cancelled bookings
    int totalHours = 0;
    for (var booking in _allBookings) {
      final status = booking['bookingStatus']?.toString().toUpperCase() ?? '';
      if (status == 'CANCELLED') continue;

      final hours = booking['totalHours'];
      if (hours != null) {
        if (hours is int) {
          totalHours += hours;
        } else {
          try {
            totalHours += int.parse(hours.toString());
          } catch (e) {
            // Skip if can't parse
          }
        }
      }
    }

    return totalHours;
  }

  // Helper method to build bike image
  Widget _buildBikeImage(RideModel ride) {
    // Try to get bike image from bookingData
    final bikeData = ride.bookingData?['bike'];
    String? imageUrl;

    if (bikeData != null) {
      imageUrl = bikeData['bikeImage']?.toString();
    }

    // If we have a valid image URL, show it; otherwise show icon
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.directions_bike,
              size: 30,
              color: AppColors.primary.withOpacity(0.7),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          );
        },
      );
    } else {
      // Show default icon
      return Center(
        child: Icon(
          Icons.directions_bike,
          size: 30,
          color: AppColors.primary.withOpacity(0.7),
        ),
      );
    }
  }

  // Real data methods
  // BookingStatus enum: PENDING, CONFIRMED, ACTIVE, COMPLETED, CANCELLED

  List<RideModel> _getCurrentRides() {
    if (_isLoading || _allBookings.isEmpty) return [];

    // Current rides: ACTIVE status only
    return _allBookings
        .where((booking) {
          final status =
              booking['bookingStatus']?.toString().toUpperCase() ?? '';
          return status == 'ACTIVE';
        })
        .map<RideModel>((booking) => _mapBookingToRideModel(booking))
        .toList();
  }

  List<RideModel> _getHistoryRides() {
    if (_isLoading || _allBookings.isEmpty) return [];

    // History rides: COMPLETED and CANCELLED statuses
    return _allBookings
        .where((booking) {
          final status =
              booking['bookingStatus']?.toString().toUpperCase() ?? '';
          return status == 'COMPLETED' || status == 'CANCELLED';
        })
        .map<RideModel>((booking) => _mapBookingToRideModel(booking))
        .toList();
  }

  List<RideModel> _getUpcomingRides() {
    if (_isLoading || _allBookings.isEmpty) return [];

    // Upcoming rides: PENDING and CONFIRMED statuses
    return _allBookings
        .where((booking) {
          final status =
              booking['bookingStatus']?.toString().toUpperCase() ?? '';
          return status == 'PENDING' || status == 'CONFIRMED';
        })
        .map<RideModel>((booking) => _mapBookingToRideModel(booking))
        .toList();
  }

  RideModel _mapBookingToRideModel(dynamic booking) {
    // Extract bike info from the bike object
    final bikeInfo = booking['bike'] ?? {};
    String bikeName = 'Bike';
    if (bikeInfo is Map) {
      bikeName =
          bikeInfo['bikeName']?.toString() ??
          bikeInfo['bikeModel']?.toString() ??
          'Bike';
    }

    // Parse dates and times (API format: "2025-10-16 16:21")
    final startDateTimeStr = booking['startDateTime']?.toString() ?? '';
    final endDateTimeStr = booking['endDateTime']?.toString() ?? '';

    String startTime = '';
    String date = '';
    String duration = '';

    try {
      if (startDateTimeStr.isNotEmpty) {
        // Parse the date-time string (format: "2025-10-16 16:21")
        DateTime startDate;
        if (startDateTimeStr.contains(' ')) {
          // Custom parsing for "yyyy-MM-dd HH:mm" format
          final parts = startDateTimeStr.split(' ');
          final dateParts = parts[0].split('-');
          final timeParts = parts[1].split(':');
          startDate = DateTime(
            int.parse(dateParts[0]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[2]), // day
            int.parse(timeParts[0]), // hour
            int.parse(timeParts[1]), // minute
          );
        } else {
          startDate = DateTime.parse(startDateTimeStr);
        }

        // Format time (e.g., "4:21 PM")
        final hour = startDate.hour > 12
            ? startDate.hour - 12
            : (startDate.hour == 0 ? 12 : startDate.hour);
        final minute = startDate.minute.toString().padLeft(2, '0');
        final period = startDate.hour >= 12 ? 'PM' : 'AM';
        startTime = '$hour:$minute $period';

        // Check if it's today
        final now = DateTime.now();
        if (startDate.year == now.year &&
            startDate.month == now.month &&
            startDate.day == now.day) {
          date = 'Today';
        } else {
          // Format date (e.g., "Oct 16, 2025")
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
          date =
              '${months[startDate.month - 1]} ${startDate.day}, ${startDate.year}';
        }

        // Use totalDays and totalHours from API if available
        final totalDays = booking['totalDays'];
        final totalHours = booking['totalHours'];

        if (totalDays != null && totalDays > 0) {
          duration = '$totalDays day${totalDays > 1 ? 's' : ''}';
        } else if (totalHours != null && totalHours > 0) {
          if (totalHours >= 24) {
            final days = totalHours ~/ 24;
            final hours = totalHours % 24;
            if (hours > 0) {
              duration = '$days day${days > 1 ? 's' : ''} ${hours}h';
            } else {
              duration = '$days day${days > 1 ? 's' : ''}';
            }
          } else {
            duration = '${totalHours}h';
          }
        } else if (endDateTimeStr.isNotEmpty) {
          // Calculate duration from dates
          try {
            DateTime endDate;
            if (endDateTimeStr.contains(' ')) {
              final parts = endDateTimeStr.split(' ');
              final dateParts = parts[0].split('-');
              final timeParts = parts[1].split(':');
              endDate = DateTime(
                int.parse(dateParts[0]),
                int.parse(dateParts[1]),
                int.parse(dateParts[2]),
                int.parse(timeParts[0]),
                int.parse(timeParts[1]),
              );
            } else {
              endDate = DateTime.parse(endDateTimeStr);
            }

            final diff = endDate.difference(startDate);
            final days = diff.inDays;
            final hours = diff.inHours % 24;

            if (days > 0) {
              if (hours > 0) {
                duration = '$days day${days > 1 ? 's' : ''} ${hours}h';
              } else {
                duration = '$days day${days > 1 ? 's' : ''}';
              }
            } else if (diff.inHours > 0) {
              duration = '${diff.inHours}h';
            } else {
              duration = '${diff.inMinutes}m';
            }
          } catch (e) {
            // If end date parsing fails, leave duration empty
          }
        }
      }
    } catch (e) {
      // If date parsing fails, use raw values
      startTime = startDateTimeStr;
      date = startDateTimeStr;
    }

    return RideModel(
      id: booking['id']?.toString() ?? '',
      bikeName: bikeName,
      startTime: startTime,
      duration: duration,
      status: booking['bookingStatus']?.toString() ?? '',
      date: date,
      totalCost: _parseCost(booking['totalAmount']),
      rating: _parseRating(booking['rating']),
      bookingData: booking, // Include full booking data
    );
  }

  int _parseCost(dynamic cost) {
    if (cost == null) return 0;
    if (cost is int) return cost;
    if (cost is double) return cost.toInt();
    try {
      return int.parse(cost.toString());
    } catch (e) {
      return 0;
    }
  }

  double _parseRating(dynamic rating) {
    if (rating == null) return 0.0;
    if (rating is double) return rating;
    if (rating is int) return rating.toDouble();
    try {
      return double.parse(rating.toString());
    } catch (e) {
      return 0.0;
    }
  }
}

// Ride model for the rides screen
class RideModel {
  final String id;
  final String bikeName;
  final String startTime;
  final String duration;
  final String status;
  final String date;
  final int totalCost;
  final double rating;
  final dynamic bookingData; // Full booking data from API

  RideModel({
    required this.id,
    required this.bikeName,
    required this.startTime,
    required this.duration,
    required this.status,
    required this.date,
    required this.totalCost,
    required this.rating,
    this.bookingData,
  });
}
