class Place {
  final int id;
  final String placeName;
  final String placeDescription;
  final String placeImage;
  final String placeLocation;
  final DateTime createdAt;

  Place({
    required this.id,
    required this.placeName,
    required this.placeDescription,
    required this.placeImage,
    required this.placeLocation,
    required this.createdAt,
  });

  /// Create Place from JSON
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] ?? 0,
      placeName: json['placeName'] ?? '',
      placeDescription: json['placeDescription'] ?? '',
      placeImage: json['placeImage'] ?? '',
      placeLocation: json['placeLocation'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] ?? 0,
      ),
    );
  }

  /// Convert Place to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeName': placeName,
      'placeDescription': placeDescription,
      'placeImage': placeImage,
      'placeLocation': placeLocation,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Create a copy of Place with updated fields
  Place copyWith({
    int? id,
    String? placeName,
    String? placeDescription,
    String? placeImage,
    String? placeLocation,
    DateTime? createdAt,
  }) {
    return Place(
      id: id ?? this.id,
      placeName: placeName ?? this.placeName,
      placeDescription: placeDescription ?? this.placeDescription,
      placeImage: placeImage ?? this.placeImage,
      placeLocation: placeLocation ?? this.placeLocation,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Place(id: $id, placeName: $placeName, placeDescription: $placeDescription, placeImage: $placeImage, placeLocation: $placeLocation, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Place && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}