import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PlacesCategory extends StatefulWidget {
  final List<PlaceCategory> places;
  final Function(String) onPlaceSelected;
  final String? selectedPlace;

  const PlacesCategory({
    super.key,
    required this.places,
    required this.onPlaceSelected,
    this.selectedPlace,
  });

  @override
  State<PlacesCategory> createState() => _PlacesCategoryState();
}

class _PlacesCategoryState extends State<PlacesCategory> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Popular Places',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to all places screen
                    // TODO: Implement navigation to places screen
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Places horizontal list
          SizedBox(
            height: 140, // Increased height for better image display
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: widget.places.length,
              itemBuilder: (context, index) {
                final place = widget.places[index];
                final isSelected = widget.selectedPlace == place.name;

                return GestureDetector(
                  onTap: () => widget.onPlaceSelected(place.name),
                  child: _buildPlaceCard(place, isSelected),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(PlaceCategory place, bool isSelected) {
    return Container(
      width: 160, // Increased width for better image display
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background image or gradient
            _buildBackgroundImage(place),

            // Content overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                ),
              ),
            ),

            // Place info
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${place.bikeCount} bikes available',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Place icon
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(place.icon, color: Colors.white, size: 20),
              ),
            ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(PlaceCategory place) {
    if (place.imageUrl != null && place.imageUrl!.isNotEmpty) {
      // Try to load network image first
      return Image.network(
        place.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to gradient if network image fails
          return Container(
            decoration: BoxDecoration(
              gradient: place.gradient ?? _getDefaultGradient(place.name),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              gradient: place.gradient ?? _getDefaultGradient(place.name),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: Colors.white.withOpacity(0.8),
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    } else {
      // Use gradient as default
      return Container(
        decoration: BoxDecoration(
          gradient: place.gradient ?? _getDefaultGradient(place.name),
        ),
      );
    }
  }

  LinearGradient _getDefaultGradient(String placeName) {
    // Generate different gradients based on city name
    switch (placeName.toLowerCase()) {
      case 'mumbai':
        return const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'pune':
        return const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'bangalore':
        return const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'delhi':
        return const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFF880E4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'chennai':
        return const LinearGradient(
          colors: [Color(0xFF00BCD4), Color(0xFF006064)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'hyderabad':
        return const LinearGradient(
          colors: [Color(0xFFFF7043), Color(0xFFBF360C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'kolkata':
        return const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF4A148C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'goa':
        return const LinearGradient(
          colors: [Color(0xFFFFB74D), Color(0xFFFF8F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF4A148C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}

class PlaceCategory {
  final String name;
  final int bikeCount;
  final IconData icon;
  final LinearGradient? gradient;
  final String? imageUrl;

  PlaceCategory({
    required this.name,
    required this.bikeCount,
    required this.icon,
    this.gradient,
    this.imageUrl,
  });

  // Static method for sample data with attractive city images
  static List<PlaceCategory> get samplePlaces => [
    PlaceCategory(
      name: 'Mumbai',
      bikeCount: 45,
      icon: Icons.location_city,
      imageUrl:
          'https://images.unsplash.com/photo-1570168007204-dfb528c6958f?w=400&h=300&fit=crop',
    ),
    PlaceCategory(
      name: 'Pune',
      bikeCount: 32,
      icon: Icons.business,
      imageUrl:
          'https://images.unsplash.com/photo-1605640840605-14ac1855827b?w=400&h=300&fit=crop',
    ),
    PlaceCategory(
      name: 'Bangalore',
      bikeCount: 38,
      icon: Icons.computer,
      imageUrl:
          'https://images.unsplash.com/photo-1596176530529-78163a4f7af2?w=400&h=300&fit=crop',
    ),
    PlaceCategory(
      name: 'Delhi',
      bikeCount: 42,
      icon: Icons.account_balance,
      imageUrl:
          'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=400&h=300&fit=crop',
    ),
    PlaceCategory(
      name: 'Chennai',
      bikeCount: 28,
      icon: Icons.directions_boat,
      imageUrl:
          'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=400&h=300&fit=crop',
    ),
    PlaceCategory(
      name: 'Hyderabad',
      bikeCount: 25,
      icon: Icons.business_center,
      imageUrl:
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
    ),
    PlaceCategory(
      name: 'Kolkata',
      bikeCount: 22,
      icon: Icons.temple_hindu,
      imageUrl:
          'https://images.unsplash.com/photo-1558431382-27ca3c1c1ee5?w=400&h=300&fit=crop',
    ),
    PlaceCategory(
      name: 'Goa',
      bikeCount: 18,
      icon: Icons.beach_access,
      imageUrl:
          'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=400&h=300&fit=crop',
    ),
  ];
}
