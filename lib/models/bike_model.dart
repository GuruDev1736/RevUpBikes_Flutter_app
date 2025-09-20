class BikeModel {
  final String id;
  final String name;
  final String type;
  final String category;
  final double pricePerDay;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String description;
  final List<String> features;
  final bool isAvailable;
  final String location;

  BikeModel({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.pricePerDay,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.description,
    required this.features,
    this.isAvailable = true,
    required this.location,
  });

  factory BikeModel.fromJson(Map<String, dynamic> json) {
    return BikeModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      category: json['category'],
      pricePerDay: (json['price_per_day'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : [],
      isAvailable: json['is_available'] ?? true,
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'category': category,
      'price_per_day': pricePerDay,
      'rating': rating,
      'review_count': reviewCount,
      'image_url': imageUrl,
      'description': description,
      'features': features,
      'is_available': isAvailable,
      'location': location,
    };
  }

  static List<BikeModel> sampleBikes = [
    BikeModel(
      id: '1',
      name: 'Honda Activa 6G',
      type: 'Scooter',
      category: 'Scooter',
      pricePerDay: 399.0,
      rating: 4.5,
      reviewCount: 250,
      imageUrl: 'assets/images/activa.png',
      description:
          'Perfect for city rides with excellent fuel efficiency and comfortable seating.',
      features: [
        '110cc Engine',
        'LED Headlight',
        'Digital Console',
        'Under Seat Storage',
      ],
      location: 'Mumbai',
    ),
    BikeModel(
      id: '2',
      name: 'Royal Enfield Classic 350',
      type: 'Cruiser',
      category: 'Sports Bike',
      pricePerDay: 899.0,
      rating: 4.7,
      reviewCount: 189,
      imageUrl: 'assets/images/classic350.png',
      description:
          'Classic styling meets modern engineering for the perfect touring experience.',
      features: [
        '350cc Engine',
        'Dual Channel ABS',
        'Electric Start',
        'Chrome Finish',
      ],
      location: 'Pune',
    ),
    BikeModel(
      id: '3',
      name: 'Hero Splendor Plus',
      type: 'Commuter',
      category: 'Mountain Bike',
      pricePerDay: 299.0,
      rating: 4.3,
      reviewCount: 342,
      imageUrl: 'assets/images/splendor.png',
      description:
          'Reliable and fuel-efficient bike perfect for daily commuting.',
      features: [
        '97.2cc Engine',
        'i3S Technology',
        'LED DRL',
        'Kick & Electric Start',
      ],
      location: 'Bangalore',
    ),
    BikeModel(
      id: '4',
      name: 'KTM Duke 200',
      type: 'Naked',
      category: 'Sports Bike',
      pricePerDay: 1199.0,
      rating: 4.6,
      reviewCount: 156,
      imageUrl: 'assets/images/duke200.png',
      description:
          'Sharp handling and aggressive styling for the thrill seekers.',
      features: ['199.5cc Engine', 'ABS', 'WP Suspension', 'TFT Display'],
      location: 'Delhi',
    ),
    BikeModel(
      id: '5',
      name: 'TVS Apache RTR 160',
      type: 'Sport',
      category: 'Sports Bike',
      pricePerDay: 699.0,
      rating: 4.4,
      reviewCount: 203,
      imageUrl: 'assets/images/apache160.png',
      description:
          'Racing-inspired design with excellent performance and handling.',
      features: [
        '159.7cc Engine',
        'Racing Throttle',
        'LED Tail Light',
        'Disc Brakes',
      ],
      location: 'Chennai',
    ),
    BikeModel(
      id: '6',
      name: 'Bajaj Pulsar NS200',
      type: 'Naked',
      category: 'Sports Bike',
      pricePerDay: 799.0,
      rating: 4.5,
      reviewCount: 178,
      imageUrl: 'assets/images/pulsar200.png',
      description:
          'Powerful performance with distinctive streetfighter styling.',
      features: [
        '199.5cc Engine',
        'Liquid Cooling',
        'Perimeter Frame',
        'LED Headlamp',
      ],
      location: 'Hyderabad',
    ),
    // Additional bikes for better distribution
    BikeModel(
      id: '7',
      name: 'Yamaha FZ-S V3',
      type: 'Naked',
      category: 'Sports Bike',
      pricePerDay: 649.0,
      rating: 4.4,
      reviewCount: 124,
      imageUrl: 'assets/images/fz.png',
      description:
          'Stylish street bike with excellent build quality and performance.',
      features: [
        '149cc Engine',
        'Bluetooth Connectivity',
        'LED Headlamp',
        'Single Channel ABS',
      ],
      location: 'Kolkata',
    ),
    BikeModel(
      id: '8',
      name: 'Honda CB Shine',
      type: 'Commuter',
      category: 'Commuter',
      pricePerDay: 349.0,
      rating: 4.2,
      reviewCount: 298,
      imageUrl: 'assets/images/shine.png',
      description:
          'Smooth and refined commuter bike for comfortable daily rides.',
      features: [
        '124cc Engine',
        'HET Technology',
        'Tubeless Tyres',
        'Long Seat',
      ],
      location: 'Goa',
    ),
    BikeModel(
      id: '9',
      name: 'Suzuki Access 125',
      type: 'Scooter',
      category: 'Scooter',
      pricePerDay: 449.0,
      rating: 4.3,
      reviewCount: 167,
      imageUrl: 'assets/images/access125.png',
      description: 'Premium scooter with great fuel efficiency and comfort.',
      features: [
        '124cc Engine',
        'LED Headlamp',
        'Mobile Charging Socket',
        'Large Under Seat Storage',
      ],
      location: 'Mumbai',
    ),
  ];

  static List<String> categories = [
    'All',
    'Scooter',
    'Sports Bike',
    'Mountain Bike',
    'Cruiser',
    'Commuter',
  ];
}
