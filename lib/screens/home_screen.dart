import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/bike_model.dart';
import '../models/place_model.dart';
import '../models/banner_model.dart';
import '../widgets/bike_card.dart';
import '../widgets/banner_widget.dart';
import '../components/image_slider.dart';
import '../services/api_services.dart';
import 'profile_screen.dart';
import 'bookmark_screen.dart';
import 'my_rides_screen.dart';
import 'auth_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  Place? _selectedPlace;
  List<Place> _allPlaces = [];
  List<BikeModel> _allBikes = [];
  List<BikeModel> _filteredBikes = [];
  List<BannerModel> _banners = [];
  bool _isLoadingBikes = false;
  bool _isLoadingBanners = false;
  bool _isLoadingPlaces = false;
  bool _hasActiveBooking = false;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _loadBanners();
    _loadPlaces();
    _loadBikes();
    _checkActiveBooking();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this screen (but not on first load)
    if (!_isFirstLoad) {
      _refreshData();
    } else {
      _isFirstLoad = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Reload all data
    await Future.wait([
      _loadBanners(),
      _loadPlaces(),
      _loadBikes(),
      _checkActiveBooking(),
    ]);
  }

  Future<void> _loadBanners() async {
    setState(() {
      _isLoadingBanners = true;
    });

    try {
      final response = await AuthService.getAllBanners();

      if (response['STS'] == '200' && response['CONTENT'] != null) {
        final List<dynamic> bannersJson = response['CONTENT'];
        final List<BannerModel> banners = bannersJson
            .map((json) => BannerModel.fromJson(json))
            .toList();

        setState(() {
          _banners = banners;
          _isLoadingBanners = false;
        });
      } else {
        setState(() {
          _banners = [];
          _isLoadingBanners = false;
        });
      }
    } catch (e) {
      setState(() {
        _banners = [];
        _isLoadingBanners = false;
      });
      print('Error loading banners: $e');
    }
  }

  Future<void> _loadPlaces() async {
    setState(() {
      _isLoadingPlaces = true;
    });

    try {
      final response = await AuthService.getAllPlaces();

      if (response['STS'] == '200' && response['CONTENT'] != null) {
        final List<dynamic> placesJson = response['CONTENT'];
        final List<Place> places = placesJson
            .map((json) => Place.fromJson(json))
            .toList();

        setState(() {
          _allPlaces = places;
          _isLoadingPlaces = false;
        });
      } else {
        setState(() {
          _allPlaces = [];
          _isLoadingPlaces = false;
        });
      }
    } catch (e) {
      setState(() {
        _allPlaces = [];
        _isLoadingPlaces = false;
      });
      print('Error loading places: $e');
    }
  }

  Future<void> _checkActiveBooking() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) return;

      final userData = await AuthService.getUserData();
      if (userData != null && userData['CONTENT'] != null) {
        var userId =
            userData['CONTENT']['id']?.toString() ??
            userData['CONTENT']['userId']?.toString() ??
            userData['CONTENT']['ID']?.toString();

        if (userId != null && mounted) {
          final response = await AuthService.checkActiveBooking(userId);
          if (mounted) {
            setState(() {
              _hasActiveBooking = response['CONTENT'] == true;
            });
          }
        }
      }
    } catch (e) {
      // Silently fail, user can still browse
    }
  }

  Future<void> _loadBikes() async {
    setState(() {
      _isLoadingBikes = true;
    });

    try {
      // Always get all bikes and filter locally
      final response = await AuthService.getAllBikes();

      if (response['STS'] == '200' && response['CONTENT'] != null) {
        final List<dynamic> bikesJson = response['CONTENT'];
        final List<BikeModel> bikes = bikesJson
            .map((json) => BikeModel.fromJson(json))
            .toList();

        setState(() {
          _allBikes = bikes;
          _filteredBikes = bikes;
          _isLoadingBikes = false;
        });

        _filterBikes(); // Apply current filters
      } else {
        setState(() {
          _allBikes = [];
          _filteredBikes = [];
          _isLoadingBikes = false;
        });
      }
    } catch (e) {
      setState(() {
        _allBikes = [];
        _filteredBikes = [];
        _isLoadingBikes = false;
      });
      print('Error loading bikes: $e');
    }
  }

  void _filterBikes() {
    setState(() {
      _filteredBikes = _allBikes.where((bike) {
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
            _selectedPlace == null || bike.place.id == _selectedPlace!.id;
        return matchesCategory && matchesSearch && matchesPlace;
      }).toList();
    });
  }

  Future<void> _checkLoginAndNavigate(Widget destination) async {
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!isLoggedIn && mounted) {
      // Show login dialog
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text(
            'You need to login to access this feature. Would you like to login now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Login'),
            ),
          ],
        ),
      );

      if (result == true && mounted) {
        // Navigate to login screen
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );

        // After login, check again if logged in and navigate
        final nowLoggedIn = await AuthService.isLoggedIn();
        if (nowLoggedIn && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      }
    } else if (mounted) {
      // User is logged in, navigate directly
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    }
  }

  void _onBannerTap(BannerModel banner) {
    if (banner.navigationLink.isNotEmpty) {
      _launchUrl(banner.navigationLink);
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      // Add https:// if the URL doesn't have a protocol
      String formattedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        formattedUrl = 'https://$url';
      }

      final Uri uri = Uri.parse(formattedUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $formattedUrl';
      }
    } catch (e) {
      print('Error launching URL: $e');
      // Show a snackbar to inform the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $url'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Top app bar with greeting
                    _buildTopBar(),

                    // Active Booking Warning Banner
                    if (_hasActiveBooking) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.block, color: AppColors.error, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Active Booking in Progress',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'You have an active booking. Complete or cancel it before making a new booking.',
                                    style: TextStyle(
                                      color: AppColors.error.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Banner carousel
                    _buildBannerSection(),

                    // Search bar and place filter
                    _buildSearchAndFilter(),

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
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBannerSection() {
    if (_isLoadingBanners) {
      return Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_banners.isEmpty) {
      // Fallback to default slider if no banners available
      return ImageSlider(
        items: SliderDefaults.defaultItems,
        height: 180,
        autoPlay: true,
        autoPlayDuration: const Duration(seconds: 4),
      );
    }

    return Column(
      children: [
        BannerCarousel(
          banners: _banners,
          height: 180,
          onBannerTap: _onBannerTap,
        ),
        const SizedBox(height: 8),
      ],
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
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
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
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                  ),
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
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Place filter button
          GestureDetector(
            onTap: _showPlaceFilter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedPlace != null
                    ? AppColors.primary
                    : AppColors.white,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: _selectedPlace != null
                        ? AppColors.white
                        : AppColors.primary,
                    size: 22,
                  ),
                  if (_selectedPlace != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      _selectedPlace!.placeName.length > 8
                          ? '${_selectedPlace!.placeName.substring(0, 8)}...'
                          : _selectedPlace!.placeName,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaceFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Filter by Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedPlace != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedPlace = null;
                        });
                        _filterBikes();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoadingPlaces)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
            else if (_allPlaces.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No locations available',
                  style: TextStyle(color: AppColors.grey),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _allPlaces.length,
                  itemBuilder: (context, index) {
                    final place = _allPlaces[index];
                    final isSelected = _selectedPlace?.id == place.id;

                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_city,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.grey,
                        ),
                      ),
                      title: Text(
                        place.placeName,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.text,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedPlace = place;
                        });
                        _filterBikes();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
          ],
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
    if (_isLoadingBikes) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _selectedPlace != null
                    ? 'Loading bikes in ${_selectedPlace!.placeName}...'
                    : 'Loading bikes...',
                style: TextStyle(fontSize: 16, color: AppColors.grey),
              ),
            ],
          ),
        ),
      );
    }

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
                _selectedPlace != null
                    ? 'No bikes found in ${_selectedPlace!.placeName}'
                    : 'No bikes found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedPlace != null
                    ? 'Try selecting a different place'
                    : 'Try adjusting your search or category',
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
          return BikeCard(
            bike: _filteredBikes[index],
            hasActiveBooking: _hasActiveBooking,
          );
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
              // Navigate to my rides (requires login)
              _checkLoginAndNavigate(const MyRidesScreen());
              break;
            case 2:
              // Navigate to bookmarks
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarkScreen()),
              );
              break;
            case 3:
              // Navigate to profile (requires login)
              _checkLoginAndNavigate(const ProfileScreen());
              break;
          }
        },
      ),
    );
  }
}
