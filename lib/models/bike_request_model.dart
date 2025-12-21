class BikeRequestModel {
  final int id;
  final String requestNote;
  final String status; // PENDING, APPROVED, REJECT
  final BikeRequestBike bike;
  final BikeRequestUser user;
  final List<dynamic> createdAt;
  final List<dynamic> updatedAt;

  BikeRequestModel({
    required this.id,
    required this.requestNote,
    required this.status,
    required this.bike,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BikeRequestModel.fromJson(Map<String, dynamic> json) {
    return BikeRequestModel(
      id: _toInt(json['id']),
      requestNote: json['requestNote']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      bike: BikeRequestBike.fromJson(json['bike'] ?? {}),
      user: BikeRequestUser.fromJson(json['user'] ?? {}),
      createdAt: json['createdAt'] is List ? json['createdAt'] : [],
      updatedAt: json['updatedAt'] is List ? json['updatedAt'] : [],
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String get formattedCreatedDate {
    if (createdAt.isEmpty || createdAt.length < 3) return 'N/A';
    return '${createdAt[2]}/${createdAt[1]}/${createdAt[0]}';
  }

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'APPROVE':
        return 'Approved';
      case 'REJECT':
        return 'Rejected';
      default:
        return status;
    }
  }
}

class BikeRequestBike {
  final int id;
  final String bikeName;
  final String bikeModel;
  final String brand;
  final String bikeImage;
  final String description;
  final double pricePerHour;
  final double pricePerDay;
  final double pricePerWeek;
  final double pricePerMonth;
  final int quantity;
  final BikeRequestPlace place;
  final String category;
  final int engineCapacity;
  final String fuelType;
  final String transmission;
  final String status;
  final String registrationNumber;

  BikeRequestBike({
    required this.id,
    required this.bikeName,
    required this.bikeModel,
    required this.brand,
    required this.bikeImage,
    required this.description,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.pricePerWeek,
    required this.pricePerMonth,
    required this.quantity,
    required this.place,
    required this.category,
    required this.engineCapacity,
    required this.fuelType,
    required this.transmission,
    required this.status,
    required this.registrationNumber,
  });

  factory BikeRequestBike.fromJson(Map<String, dynamic> json) {
    return BikeRequestBike(
      id: _toInt(json['id']),
      bikeName: json['bikeName']?.toString() ?? '',
      bikeModel: json['bikeModel']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      bikeImage: json['bikeImage']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      pricePerHour: _toDouble(json['pricePerHour']),
      pricePerDay: _toDouble(json['pricePerDay']),
      pricePerWeek: _toDouble(json['pricePerWeek']),
      pricePerMonth: _toDouble(json['pricePerMonth']),
      quantity: _toInt(json['quantity']),
      place: json['place'] != null
          ? BikeRequestPlace.fromJson(json['place'])
          : BikeRequestPlace.empty(),
      category: json['category']?.toString() ?? '',
      engineCapacity: _toInt(json['engineCapacity']),
      fuelType: json['fuelType']?.toString() ?? '',
      transmission: json['transmission']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      registrationNumber: json['registrationNumber']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class BikeRequestPlace {
  final int id;
  final String placeName;
  final String placeDescription;
  final String placeImage;
  final String placeLocation;
  final bool isActive;
  final int createdAt;

  BikeRequestPlace({
    required this.id,
    required this.placeName,
    required this.placeDescription,
    required this.placeImage,
    required this.placeLocation,
    required this.isActive,
    required this.createdAt,
  });

  factory BikeRequestPlace.fromJson(Map<String, dynamic> json) {
    return BikeRequestPlace(
      id: _toInt(json['id']),
      placeName: json['placeName']?.toString() ?? '',
      placeDescription: json['placeDescription']?.toString() ?? '',
      placeImage: json['placeImage']?.toString() ?? '',
      placeLocation: json['placeLocation']?.toString() ?? '',
      isActive: json['isActive'] == true,
      createdAt: _toInt(json['createdAt']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory BikeRequestPlace.empty() {
    return BikeRequestPlace(
      id: 0,
      placeName: 'Unknown',
      placeDescription: '',
      placeImage: '',
      placeLocation: '',
      isActive: false,
      createdAt: 0,
    );
  }
}

class BikeRequestUser {
  final int id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String profilePicture;

  BikeRequestUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.profilePicture,
  });

  factory BikeRequestUser.fromJson(Map<String, dynamic> json) {
    return BikeRequestUser(
      id: _toInt(json['id']),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profilePicture: json['profilePicture']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String get fullName => '$firstName $lastName';
}
