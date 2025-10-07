import 'package:flutter/material.dart';

class BannerModel {
  final int id;
  final String bannerTitle;
  final String bannerDescription;
  final String bannerImage;
  final String navigationLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerModel({
    required this.id,
    required this.bannerTitle,
    required this.bannerDescription,
    required this.bannerImage,
    required this.navigationLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      bannerTitle: json['bannerTitle'] ?? '',
      bannerDescription: json['bannerDescription'] ?? '',
      bannerImage: json['bannerImage'] ?? '',
      navigationLink: json['navigationLink'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bannerTitle': bannerTitle,
      'bannerDescription': bannerDescription,
      'bannerImage': bannerImage,
      'navigationLink': navigationLink,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Helper method to create widget for banner image
  Widget getImageWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (bannerImage.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image, color: Colors.grey, size: 50),
      );
    }

    // Check if it's a network image (URL)
    if (bannerImage.startsWith('http://') ||
        bannerImage.startsWith('https://')) {
      return Image.network(
        bannerImage,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
          );
        },
      );
    }

    // If it's not a URL, treat it as an asset
    return Image.asset(
      bannerImage,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
        );
      },
    );
  }

  @override
  String toString() {
    return 'BannerModel(id: $id, title: $bannerTitle, image: $bannerImage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BannerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
