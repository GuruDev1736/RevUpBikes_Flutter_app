class BikeModel {
  final String id;
  final String name;
  final String type;
  final String category;
  final double pricePerHour;
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
    required this.pricePerHour,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.description,
    required this.features,
    this.isAvailable = true,
    required this.location,
  });

  static List<BikeModel> sampleBikes = [
    BikeModel(
      id: '1',
      name: 'Honda Activa 6G',
      type: 'Scooter',
      category: 'Scooter',
      pricePerHour: 45.0,
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
      location: 'Mumbai Central',
    ),
    BikeModel(
      id: '2',
      name: 'Royal Enfield Classic 350',
      type: 'Cruiser',
      category: 'Sports Bike',
      pricePerHour: 120.0,
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
      location: 'Pune Station',
    ),
    BikeModel(
      id: '3',
      name: 'Hero Splendor Plus',
      type: 'Commuter',
      category: 'Mountain Bike',
      pricePerHour: 35.0,
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
      location: 'Delhi NCR',
    ),
    BikeModel(
      id: '4',
      name: 'KTM Duke 200',
      type: 'Naked',
      category: 'Sports Bike',
      pricePerHour: 150.0,
      rating: 4.6,
      reviewCount: 156,
      imageUrl: 'assets/images/duke200.png',
      description:
          'Sharp handling and aggressive styling for the thrill seekers.',
      features: ['199.5cc Engine', 'ABS', 'WP Suspension', 'TFT Display'],
      location: 'Bangalore Hub',
    ),
    BikeModel(
      id: '5',
      name: 'TVS Apache RTR 160',
      type: 'Sport',
      category: 'Sports Bike',
      pricePerHour: 80.0,
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
      location: 'Chennai Port',
    ),
    BikeModel(
      id: '6',
      name: 'Bajaj Pulsar NS200',
      type: 'Naked',
      category: 'Sports Bike',
      pricePerHour: 95.0,
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
      location: 'Hyderabad Central',
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
