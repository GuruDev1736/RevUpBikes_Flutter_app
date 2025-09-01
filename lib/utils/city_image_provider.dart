class CityImageProvider {
  // Network URLs for city images from Unsplash
  static const Map<String, String> cityImages = {
    'mumbai':
        'https://images.unsplash.com/photo-1570168007204-dfb528c6958f?w=400&h=300&fit=crop',
    'pune':
        'https://images.unsplash.com/photo-1605640840605-14ac1855827b?w=400&h=300&fit=crop',
    'bangalore':
        'https://images.unsplash.com/photo-1596176530529-78163a4f7af2?w=400&h=300&fit=crop',
    'delhi':
        'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=400&h=300&fit=crop',
    'chennai':
        'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=400&h=300&fit=crop',
    'hyderabad':
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
    'kolkata':
        'https://images.unsplash.com/photo-1558431382-27ca3c1c1ee5?w=400&h=300&fit=crop',
    'goa':
        'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=400&h=300&fit=crop',
  };

  // Alternative high-quality images
  static const Map<String, String> alternativeCityImages = {
    'mumbai':
        'https://images.unsplash.com/photo-1595658658481-d53834559d47?w=400&h=300&fit=crop',
    'pune':
        'https://images.unsplash.com/photo-1578139736394-1d9ba378b1ee?w=400&h=300&fit=crop',
    'bangalore':
        'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400&h=300&fit=crop',
    'delhi':
        'https://images.unsplash.com/photo-1580279399775-d8d2f7c83e79?w=400&h=300&fit=crop',
    'chennai':
        'https://images.unsplash.com/photo-1608553161750-1da0e9e83af4?w=400&h=300&fit=crop',
    'hyderabad':
        'https://images.unsplash.com/photo-1612013473422-7cd2e2d64d3e?w=400&h=300&fit=crop',
    'kolkata':
        'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=400&h=300&fit=crop',
    'goa':
        'https://images.unsplash.com/photo-1599056719925-85ea5736c81e?w=400&h=300&fit=crop',
  };

  static String? getImageUrl(String cityName) {
    return cityImages[cityName.toLowerCase()];
  }

  static String? getAlternativeImageUrl(String cityName) {
    return alternativeCityImages[cityName.toLowerCase()];
  }

  // Banner images for promotional content
  static const Map<String, String> bannerImages = {
    'explore_city':
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=400&fit=crop',
    'electric_bike':
        'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=800&h=400&fit=crop',
    'adventure':
        'https://images.unsplash.com/photo-1544191696-15693072b5d5?w=800&h=400&fit=crop',
    'mountain_biking':
        'https://images.unsplash.com/photo-1544966503-7cc5ac882d5d?w=800&h=400&fit=crop',
    'city_cycling':
        'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=800&h=400&fit=crop',
    'special_offers':
        'https://images.unsplash.com/photo-1502744688674-c619d1586c9e?w=800&h=400&fit=crop',
    'weekend_rides':
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=400&fit=crop',
    'eco_friendly':
        'https://images.unsplash.com/photo-1516738901171-8eb4fc13bd20?w=800&h=400&fit=crop',
  };

  static String? getBannerImageUrl(String bannerType) {
    return bannerImages[bannerType.toLowerCase()];
  }

  // Local asset paths (for offline use)
  static String getLocalAssetPath(String cityName) {
    return 'assets/images/cities/${cityName.toLowerCase()}.jpg';
  }

  // Bike images for different types and models
  static const Map<String, String> bikeImages = {
    // Scooters
    'honda_activa_6g':
        'https://media.istockphoto.com/id/1818435415/photo/scooter-blue-isolated-on-white-background.jpg?s=2048x2048&w=is&k=20&c=0PeO_WWenbAnPy0ZWzkvhXfPC49DCnaMyFeAFvalMSM=',
    'suzuki_access_125':
        'https://media.istockphoto.com/id/152990973/photo/scooter.jpg?s=1024x1024&w=is&k=20&c=C9B5g0KAVxxxJwqJ8Cm4DwxP7cIn4GX85z1I2218hPk=',

    // Sports Bikes
    'royal_enfield_classic_350':
        'https://media.istockphoto.com/id/1139816853/photo/the-royal-enfield-motorcycle-famous-motorbike-in-india.jpg?s=1024x1024&w=is&k=20&c=VO_8qNNPkitz53fHaWJLBViThyIwcS9pKexz55PgpU8=',
    'ktm_duke_200':
        'https://media.istockphoto.com/id/1803173142/photo/duke-200-motorbike.jpg?s=1024x1024&w=is&k=20&c=ZfXP0egMpgQgsAgCvDml_faR1cNiU6ANJF6gU4-j5Gw=',
    'tvs_apache_rtr_160':
        'https://media.istockphoto.com/id/485164129/photo/side-profile-of-motorbike-silhouette.jpg?s=1024x1024&w=is&k=20&c=j0iBJNVZct-CVdOWpOSwopwTP8WqdPI7DLyRUlTL044=',
    'bajaj_pulsar_ns200':
        'https://media.istockphoto.com/id/458345749/photo/red-motorbike.jpg?s=1024x1024&w=is&k=20&c=eIFYPwH6jYihiqPTMsk5RChIYw34NVqM037JYiloaHg=',
    'yamaha_fz_s_v3':
        'https://media.istockphoto.com/id/1133532249/photo/yamaha-fz-see-2-0.jpg?s=1024x1024&w=is&k=20&c=ByMIVKcAJ8b5-KTBqmkVaMGz5xkC3_1NJynaNnwft08=',

    // Commuter bikes
    'hero_splendor_plus':
        'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=500&h=300&fit=crop',
    'honda_cb_shine':
        'https://images.unsplash.com/photo-1609630875171-b1321377ee65?w=500&h=300&fit=crop',

    // Generic bike types
    'scooter':
        'https://images.unsplash.com/photo-1563298723-dcfebaa392e3?w=500&h=300&fit=crop',
    'sports_bike':
        'https://images.unsplash.com/photo-1593443027776-e63b19b4b5b0?w=500&h=300&fit=crop',
    'naked':
        'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=500&h=300&fit=crop',
    'cruiser':
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&h=300&fit=crop',
    'commuter':
        'https://images.unsplash.com/photo-1609630875171-b1321377ee65?w=500&h=300&fit=crop',
    'mountain_bike':
        'https://images.unsplash.com/photo-1544966503-7cc5ac882d5d?w=500&h=300&fit=crop',
    'sport':
        'https://images.unsplash.com/photo-1593443027776-e63b19b4b5b0?w=500&h=300&fit=crop',
  };

  static String? getBikeImageUrl(String bikeName) {
    // Convert bike name to key format
    String key = bikeName.toLowerCase().replaceAll(' ', '_');
    return bikeImages[key];
  }

  static String? getBikeImageByType(String bikeType) {
    String key = bikeType.toLowerCase().replaceAll(' ', '_');
    return bikeImages[key];
  }

  static String getBikeAssetPath(String bikeName) {
    return 'assets/images/bikes/${bikeName.toLowerCase().replaceAll(' ', '_')}.jpg';
  }
}
