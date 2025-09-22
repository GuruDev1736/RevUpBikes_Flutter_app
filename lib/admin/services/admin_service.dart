import '../models/dashboard_stats.dart';

class AdminService {
  // Note: All methods now return mock data since APIs are not ready
  // This provides a complete demo experience without backend dependencies

  /// Get dashboard statistics - Returns mock data
  static Future<DashboardStats> getDashboardStats() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockDashboardStats();
  }

  /// Get admin alerts - Returns mock data
  static Future<List<AdminAlert>> getAlerts() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 600));
    return _getMockAlerts();
  }

  /// Get all bikes - Returns mock data
  static Future<List<BikeData>> getAllBikes() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 700));
    return _getMockBikes();
  }

  /// Get all bookings - Returns mock data
  static Future<List<BookingData>> getAllBookings({String? status}) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 650));
    final allBookings = _getMockBookings();

    if (status != null) {
      return allBookings.where((booking) => booking.status == status).toList();
    }
    return allBookings;
  }

  /// Add new bike - Returns success (mock)
  static Future<bool> addBike(Map<String, dynamic> bikeData) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 900));
    // Always return success for demo
    print('Mock: Added bike - ${bikeData['name']}');
    return true;
  }

  /// Get all users - Returns mock data
  static Future<List<UserData>> getAllUsers() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 700));
    return _getMockUsers();
  }

  /// Mock data for dashboard statistics
  static DashboardStats _getMockDashboardStats() {
    return DashboardStats(
      totalBikes: 156,
      activeRentals: 34,
      upcomingBookings: 18,
      revenue: 45280.50,
      bikeTrend: '+12%',
      rentalTrend: '+8%',
      bookingTrend: '+15%',
      revenueTrend: '+22%',
    );
  }

  /// Mock data for admin alerts
  static List<AdminAlert> _getMockAlerts() {
    return [
      AdminAlert(
        id: '1',
        type: 'overdue',
        title: 'Overdue Rental Alert',
        message:
            'Mountain Bike "Thunder Pro" is 3 hours overdue from Alex Johnson',
        severity: 'high',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      AdminAlert(
        id: '2',
        type: 'maintenance',
        title: 'Maintenance Required',
        message: '5 bikes are due for scheduled maintenance this week',
        severity: 'medium',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      AdminAlert(
        id: '3',
        type: 'low_availability',
        title: 'Low Bike Availability',
        message: 'Only 3 electric bikes available in Downtown area',
        severity: 'medium',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: false,
      ),
      AdminAlert(
        id: '5',
        type: 'payment',
        title: 'Payment Issue',
        message: 'Failed payment for booking #BK2024-0892 from Sarah Wilson',
        severity: 'high',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        isRead: true,
      ),
    ];
  }

  /// Mock data for bikes
  static List<BikeData> _getMockBikes() {
    return [
      BikeData(
        id: 'B001',
        name: 'Thunder Pro',
        model: 'Mountain Explorer',
        status: 'rented',
        location: 'Central Park Station',
        pricePerHour: 15.00,
        imageUrl: 'https://example.com/bikes/thunder-pro.jpg',
        lastMaintenance: DateTime.now().subtract(const Duration(days: 15)),
      ),
      BikeData(
        id: 'B002',
        name: 'City Cruiser',
        model: 'Urban Rider',
        status: 'available',
        location: 'Downtown Hub',
        pricePerHour: 8.50,
        imageUrl: 'https://example.com/bikes/city-cruiser.jpg',
        lastMaintenance: DateTime.now().subtract(const Duration(days: 8)),
      ),
      BikeData(
        id: 'B003',
        name: 'Electric Bolt',
        model: 'E-Power 3000',
        status: 'available',
        location: 'Tech District',
        pricePerHour: 20.00,
        imageUrl: 'https://example.com/bikes/electric-bolt.jpg',
        lastMaintenance: DateTime.now().subtract(const Duration(days: 3)),
      ),
      BikeData(
        id: 'B004',
        name: 'Speed Demon',
        model: 'Road Master',
        status: 'maintenance',
        location: 'Service Center',
        pricePerHour: 12.00,
        imageUrl: 'https://example.com/bikes/speed-demon.jpg',
        lastMaintenance: DateTime.now().subtract(const Duration(days: 30)),
      ),
      BikeData(
        id: 'B005',
        name: 'Green Machine',
        model: 'Eco Rider',
        status: 'available',
        location: 'University Campus',
        pricePerHour: 10.00,
        imageUrl: 'https://example.com/bikes/green-machine.jpg',
        lastMaintenance: DateTime.now().subtract(const Duration(days: 12)),
      ),
    ];
  }

  /// Mock data for bookings
  static List<BookingData> _getMockBookings() {
    return [
      BookingData(
        id: 'BK001',
        userId: 'U123',
        userName: 'John Smith',
        userEmail: 'john.smith@email.com',
        bikeId: 'B001',
        bikeName: 'Thunder Pro',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 6)),
        status: 'active',
        totalAmount: 60.00,
        bookingDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      BookingData(
        id: 'BK002',
        userId: 'U124',
        userName: 'Emma Davis',
        userEmail: 'emma.davis@email.com',
        bikeId: 'B003',
        bikeName: 'Electric Bolt',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        status: 'active',
        totalAmount: 80.00,
        bookingDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      BookingData(
        id: 'BK003',
        userId: 'U125',
        userName: 'Michael Chen',
        userEmail: 'michael.chen@email.com',
        bikeId: 'B002',
        bikeName: 'City Cruiser',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
        status: 'active',
        totalAmount: 34.00,
        bookingDate: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      BookingData(
        id: 'BK004',
        userId: 'U126',
        userName: 'Sarah Johnson',
        userEmail: 'sarah.johnson@email.com',
        bikeId: 'B005',
        bikeName: 'Green Machine',
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().subtract(const Duration(days: 1, hours: -3)),
        status: 'completed',
        totalAmount: 30.00,
        bookingDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      BookingData(
        id: 'BK005',
        userId: 'U127',
        userName: 'David Wilson',
        userEmail: 'david.wilson@email.com',
        bikeId: 'B004',
        bikeName: 'Speed Demon',
        startTime: DateTime.now().add(const Duration(hours: 6)),
        endTime: DateTime.now().add(const Duration(hours: 10)),
        status: 'active',
        totalAmount: 48.00,
        bookingDate: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }

  /// Mock data for users
  static List<UserData> _getMockUsers() {
    return [
      UserData(
        id: 'user_1',
        name: 'John Smith',
        email: 'john.smith@email.com',
        phone: '+1 (555) 123-4567',
        status: 'Active',
        joinedDate: DateTime(2023, 8, 15),
        totalBookings: 23,
        totalSpent: 456.78,
      ),
      UserData(
        id: 'user_2',
        name: 'Sarah Johnson',
        email: 'sarah.j@email.com',
        phone: '+1 (555) 234-5678',
        status: 'Premium',
        joinedDate: DateTime(2023, 6, 22),
        totalBookings: 45,
        totalSpent: 892.50,
      ),
      UserData(
        id: 'user_3',
        name: 'Mike Chen',
        email: 'mike.chen@email.com',
        phone: '+1 (555) 345-6789',
        status: 'Active',
        joinedDate: DateTime(2024, 1, 10),
        totalBookings: 12,
        totalSpent: 234.90,
      ),
      UserData(
        id: 'user_4',
        name: 'Emily Davis',
        email: 'emily.davis@email.com',
        phone: '+1 (555) 456-7890',
        status: 'Inactive',
        joinedDate: DateTime(2023, 11, 5),
        totalBookings: 8,
        totalSpent: 167.25,
      ),
      UserData(
        id: 'user_5',
        name: 'David Rodriguez',
        email: 'david.r@email.com',
        phone: '+1 (555) 567-8901',
        status: 'Active',
        joinedDate: DateTime(2024, 2, 18),
        totalBookings: 19,
        totalSpent: 378.40,
      ),
      UserData(
        id: 'user_6',
        name: 'Lisa Williams',
        email: 'lisa.williams@email.com',
        phone: '+1 (555) 678-9012',
        status: 'Premium',
        joinedDate: DateTime(2023, 9, 30),
        totalBookings: 67,
        totalSpent: 1245.80,
      ),
      UserData(
        id: 'user_7',
        name: 'Alex Thompson',
        email: 'alex.t@email.com',
        phone: '+1 (555) 789-0123',
        status: 'Active',
        joinedDate: DateTime(2024, 3, 12),
        totalBookings: 5,
        totalSpent: 89.50,
      ),
      UserData(
        id: 'user_8',
        name: 'Jessica Brown',
        email: 'jessica.brown@email.com',
        phone: '+1 (555) 890-1234',
        status: 'Inactive',
        joinedDate: DateTime(2023, 5, 8),
        totalBookings: 15,
        totalSpent: 298.75,
      ),
      UserData(
        id: 'user_9',
        name: 'Ryan Miller',
        email: 'ryan.miller@email.com',
        phone: '+1 (555) 901-2345',
        status: 'Active',
        joinedDate: DateTime(2024, 1, 25),
        totalBookings: 31,
        totalSpent: 623.20,
      ),
      UserData(
        id: 'user_10',
        name: 'Amanda Garcia',
        email: 'amanda.garcia@email.com',
        phone: '+1 (555) 012-3456',
        status: 'Premium',
        joinedDate: DateTime(2023, 7, 14),
        totalBookings: 52,
        totalSpent: 987.65,
      ),
    ];
  }
}

// User data model class
class UserData {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String status;
  final DateTime joinedDate;
  final int totalBookings;
  final double totalSpent;

  const UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.joinedDate,
    required this.totalBookings,
    required this.totalSpent,
  });
}
