import 'package:flutter/material.dart';
import 'place_model.dart';

class BikeModel {
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
  final Place place;
  final String category;
  final int engineCapacity;
  final String fuelType;
  final String transmission;
  final String status;
  final String registrationNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Legacy fields for backward compatibility
  String get name => bikeName;
  String get type => category;
  String get imageUrl => bikeImage;
  String get location => place.placeName;
  bool get isAvailable => status == 'AVAILABLE';
  double get rating => 4.5; // Default rating since API doesn't provide it
  int get reviewCount => 0; // Default review count
  List<String> get features => [
    '$engineCapacity cc Engine',
    fuelType,
    transmission,
    'Registration: $registrationNumber',
  ];

  BikeModel({
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
    required this.place,
    required this.category,
    required this.engineCapacity,
    required this.fuelType,
    required this.transmission,
    required this.status,
    required this.registrationNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BikeModel.fromJson(Map<String, dynamic> json) {
    return BikeModel(
      id: json['id'],
      bikeName: json['bikeName'] ?? '',
      bikeModel: json['bikeModel'] ?? '',
      brand: json['brand'] ?? '',
      bikeImage: json['bikeImage'] ?? '',
      description: json['description'] ?? '',
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0.0,
      pricePerWeek: (json['pricePerWeek'] as num?)?.toDouble() ?? 0.0,
      pricePerMonth: (json['pricePerMonth'] as num?)?.toDouble() ?? 0.0,
      place: Place.fromJson(json['place'] ?? {}),
      category: json['category'] ?? '',
      engineCapacity: json['engineCapacity'] ?? 0,
      fuelType: json['fuelType'] ?? '',
      transmission: json['transmission'] ?? '',
      status: json['status'] ?? 'UNAVAILABLE',
      registrationNumber: json['registrationNumber'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bikeName': bikeName,
      'bikeModel': bikeModel,
      'brand': brand,
      'bikeImage': bikeImage,
      'description': description,
      'pricePerHour': pricePerHour,
      'pricePerDay': pricePerDay,
      'pricePerWeek': pricePerWeek,
      'pricePerMonth': pricePerMonth,
      'place': place.toJson(),
      'category': category,
      'engineCapacity': engineCapacity,
      'fuelType': fuelType,
      'transmission': transmission,
      'status': status,
      'registrationNumber': registrationNumber,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Sample bikes - will be replaced by API data
  static List<BikeModel> sampleBikes = [];

  static List<String> categories = [
    'All',
    'Adventure',
    'Cruiser',
    'Sports',
    'Commuter',
    'Scooter',
  ];

  /// Get the proper image widget for this bike
  Widget getImageWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? fallback,
  }) {
    if (bikeImage.isNotEmpty) {
      if (bikeImage.startsWith('http')) {
        return Image.network(
          bikeImage,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return fallback ?? _defaultFallback(width, height);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: width,
              height: height,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        );
      } else {
        return Image.asset(
          bikeImage,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return fallback ?? _defaultFallback(width, height);
          },
        );
      }
    }
    return fallback ?? _defaultFallback(width, height);
  }

  Widget _defaultFallback(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF5F5F5),
      child: const Icon(Icons.directions_bike, color: Color(0xFF666666)),
    );
  }
}
