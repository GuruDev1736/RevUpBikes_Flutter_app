import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/bike_model.dart';
import '../widgets/bike_card.dart';
import '../components/image_slider.dart';
import '../components/places_category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String? _selectedPlace;
  List<BikeModel> _filteredBikes = BikeModel.sampleBikes;
  List<PlaceCategory> _placesData = PlaceCategory.samplePlaces;

  @override
  void initState() {
    super.initState();
    _filteredBikes = BikeModel.sampleBikes;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBikes() {
    setState(() {
      _filteredBikes = BikeModel.sampleBikes.where((bike) {
        bool matchesCategory =
            _selectedCategory == 'All' || bike.category == _selectedCategory;
        bool matchesSearch =
            bike.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            bike.type.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
        bool matchesPlace =
            _selectedPlace == null || bike.location == _selectedPlace;
        return matchesCategory && matchesSearch && matchesPlace;
      }).toList();
    });
  }

  void _onPlaceSelected(String placeName) {
    setState(() {
      // If the same place is selected again, deselect it (clear filter)
      if (_selectedPlace == placeName) {
        _selectedPlace = null;
      } else {
        _selectedPlace = placeName;
      }
    });
    _filterBikes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Top app bar with greeting
                  _buildTopBar(),

                  // Image Slider
                  ImageSlider(
                    items: SliderDefaults.defaultItems,
                    height: 180,
                    autoPlay: true,
                    autoPlayDuration: const Duration(seconds: 4),
                  ),

                  // Search bar
                  _buildSearchBar(),

                  // Places categories
                  PlacesCategory(
                    places: _placesData,
                    onPlaceSelected: _onPlaceSelected,
                    selectedPlace: _selectedPlace,
                  ),

                  // Bike Categories
                  _buildCategories(),
                ],
              ),
            ),
            // Bikes list as sliver
            _buildBikesSliver(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello, Rider! 👋',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find your perfect ride',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.white.withOpacity(0.2),
            child: const Icon(Icons.person, color: AppColors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20), // Reduced top margin
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _filterBikes(),
        decoration: InputDecoration(
          hintText: 'Search for bikes...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header for bike categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.directions_bike, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Bike Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Categories horizontal list
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: BikeModel.categories.length,
              itemBuilder: (context, index) {
                final category = BikeModel.categories[index];
                final isSelected = category == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    _filterBikes();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.grey.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          size: 20,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.text,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'All':
        return Icons.apps;
      case 'Scooter':
        return Icons.electric_scooter;
      case 'Sports Bike':
        return Icons.sports_motorsports;
      case 'Mountain Bike':
        return Icons.terrain;
      case 'Cruiser':
        return Icons.motorcycle;
      case 'Commuter':
        return Icons.commute;
      default:
        return Icons.directions_bike;
    }
  }

  Widget _buildBikesSliver() {
    if (_filteredBikes.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No bikes found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or category',
                style: TextStyle(fontSize: 14, color: AppColors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return BikeCard(bike: _filteredBikes[index]);
        }, childCount: _filteredBikes.length),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bike),
            label: 'My Rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          // Handle navigation
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              // Navigate to my rides
              break;
            case 2:
              // Navigate to bookmarks
              break;
            case 3:
              // Navigate to profile
              break;
          }
        },
      ),
    );
  }
}
