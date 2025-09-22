class DashboardStats {
  final int totalBikes;
  final int activeRentals;
  final int upcomingBookings;
  final double revenue;
  final String bikeTrend;
  final String rentalTrend;
  final String bookingTrend;
  final String revenueTrend;

  DashboardStats({
    required this.totalBikes,
    required this.activeRentals,
    required this.upcomingBookings,
    required this.revenue,
    required this.bikeTrend,
    required this.rentalTrend,
    required this.bookingTrend,
    required this.revenueTrend,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalBikes: json['totalBikes'] ?? 0,
      activeRentals: json['activeRentals'] ?? 0,
      upcomingBookings: json['upcomingBookings'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      bikeTrend: json['bikeTrend'] ?? '+0%',
      rentalTrend: json['rentalTrend'] ?? '+0%',
      bookingTrend: json['bookingTrend'] ?? '+0%',
      revenueTrend: json['revenueTrend'] ?? '+0%',
    );
  }
}

class AdminAlert {
  final String id;
  final String type;
  final String title;
  final String message;
  final String severity; // 'high', 'medium', 'low'
  final DateTime timestamp;
  final bool isRead;

  AdminAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    required this.isRead,
  });

  factory AdminAlert.fromJson(Map<String, dynamic> json) {
    return AdminAlert(
      id: json['id'] ?? '',
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      severity: json['severity'] ?? 'low',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}

class BikeData {
  final String id;
  final String name;
  final String model;
  final String status; // 'available', 'rented', 'maintenance'
  final String location;
  final double pricePerHour;
  final String imageUrl;
  final DateTime lastMaintenance;

  BikeData({
    required this.id,
    required this.name,
    required this.model,
    required this.status,
    required this.location,
    required this.pricePerHour,
    required this.imageUrl,
    required this.lastMaintenance,
  });

  factory BikeData.fromJson(Map<String, dynamic> json) {
    return BikeData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      model: json['model'] ?? '',
      status: json['status'] ?? 'available',
      location: json['location'] ?? '',
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      lastMaintenance:
          DateTime.tryParse(json['lastMaintenance'] ?? '') ?? DateTime.now(),
    );
  }
}

class BookingData {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String bikeId;
  final String bikeName;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'active', 'completed', 'cancelled'
  final double totalAmount;
  final DateTime bookingDate;

  BookingData({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.bikeId,
    required this.bikeName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalAmount,
    required this.bookingDate,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      bikeId: json['bikeId'] ?? '',
      bikeName: json['bikeName'] ?? '',
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'active',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      bookingDate:
          DateTime.tryParse(json['bookingDate'] ?? '') ?? DateTime.now(),
    );
  }
}
