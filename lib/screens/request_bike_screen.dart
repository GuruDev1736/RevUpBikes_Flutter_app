import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/bike_model.dart';
import '../models/place_model.dart';
import '../services/api_services.dart';

class RequestBikeScreen extends StatefulWidget {
  const RequestBikeScreen({super.key});

  @override
  State<RequestBikeScreen> createState() => _RequestBikeScreenState();
}

class _RequestBikeScreenState extends State<RequestBikeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<BikeModel> _allBikes = [];
  List<BikeModel> _filteredBikes = [];
  List<Place> _allPlaces = [];
  Place? _selectedPlace;
  bool _isLoadingBikes = false;
  bool _isLoadingPlaces = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBikes();
    _loadPlaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBikes() async {
    setState(() {
      _isLoadingBikes = true;
      _errorMessage = null;
    });

    try {
      final response = await AuthService.getAllBikes();

      if (response['STS'] == '200' && response['CONTENT'] != null) {
        final List<dynamic> bikesJson = response['CONTENT'];
        final List<BikeModel> bikes = bikesJson
            .map((json) => BikeModel.fromJson(json))
            .toList();

        if (mounted) {
          setState(() {
            _allBikes = bikes;
            _filteredBikes = bikes;
            _isLoadingBikes = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load bikes';
            _isLoadingBikes = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
          _isLoadingBikes = false;
        });
      }
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

        if (mounted) {
          setState(() {
            _allPlaces = places;
            _isLoadingPlaces = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingPlaces = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPlaces = false;
        });
      }
    }
  }

  void _filterBikes() {
    setState(() {
      _filteredBikes = _allBikes.where((bike) {
        bool matchesSearch =
            bike.bikeName.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            bike.brand.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
        bool matchesPlace =
            _selectedPlace == null || bike.place.id == _selectedPlace!.id;
        return matchesSearch && matchesPlace;
      }).toList();
    });
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
                color: AppColors.grey.withValues(alpha: 0.3),
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
                              ? AppColors.primary.withValues(alpha: 0.1)
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

  Future<void> _requestBike(BikeModel bike) async {
    // Show dialog to enter request note
    final noteController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Bike'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${bike.bikeName} - ${bike.brand}'),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Request Note',
                hintText: 'Why do you need this bike?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Get user ID from stored data
        final userData = await AuthService.getUserData();
        final userId = userData?['CONTENT']?['userId'];

        if (userId == null) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not found. Please login again'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        // Call API to submit bike request
        final response = await AuthService.createBikeRequest(
          userId: userId,
          bikeId: bike.id,
          requestNote: noteController.text.trim(),
        );

        Navigator.pop(context); // Close loading

        if (response['STS'] == '200') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['MSG'] ?? 'Request submitted successfully!',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['MSG'] ?? 'Failed to submit request'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    noteController.dispose();
  }

  void _showBikeDetails(BikeModel bike) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bike Image
              if (bike.bikeImage.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    bike.bikeImage,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: AppColors.grey.withValues(alpha: 0.3),
                        child: const Icon(
                          Icons.two_wheeler,
                          size: 64,
                          color: AppColors.grey,
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bike Name
                    Text(
                      bike.bikeName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Brand
                    Row(
                      children: [
                        const Icon(
                          Icons.business,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          bike.brand,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            bike.place.placeName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        bike.category,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Description Section
                    if (bike.description.isNotEmpty) ...[
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bike.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Specifications Section
                    const Text(
                      'Specifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSpecRow('Model', bike.bikeModel),
                    _buildSpecRow('Engine', '${bike.engineCapacity} cc'),
                    _buildSpecRow('Fuel Type', bike.fuelType),
                    _buildSpecRow('Transmission', bike.transmission),
                    _buildSpecRow('Registration', bike.registrationNumber),
                    _buildSpecRow('Status', bike.status),
                    const SizedBox(height: 20),
                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Request a Bike'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _filterBikes(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    hintText: 'Search bikes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterBikes();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showPlaceFilter,
                    icon: const Icon(Icons.filter_list),
                    label: Text(
                      _selectedPlace != null
                          ? 'Location: ${_selectedPlace!.placeName}'
                          : 'Filter by Location',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.white),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bikes list
          Expanded(child: _buildBikesList()),
        ],
      ),
    );
  }

  Widget _buildBikesList() {
    if (_isLoadingBikes) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadBikes,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredBikes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.grey.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Bikes Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try adjusting your search or filters',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredBikes.length,
      itemBuilder: (context, index) {
        final bike = _filteredBikes[index];
        return _buildBikeCard(bike);
      },
    );
  }

  Widget _buildBikeCard(BikeModel bike) {
    return GestureDetector(
      onTap: () => _showBikeDetails(bike),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bike Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: bike.bikeImage.isNotEmpty
                  ? Image.network(
                      bike.bikeImage,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.1),
                                AppColors.primary.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.two_wheeler,
                              size: 64,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.primary.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.two_wheeler,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),
            // Bike Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bike.bikeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${bike.brand} - ${bike.bikeModel}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        bike.place.placeName,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.category, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(bike.category, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Prices
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPriceItem(
                          '₹${bike.pricePerDay.toInt()}',
                          'Per Day',
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: AppColors.white.withValues(alpha: 0.3),
                        ),
                        _buildPriceItem(
                          '₹${bike.pricePerWeek.toInt()}',
                          'Per Week',
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: AppColors.white.withValues(alpha: 0.3),
                        ),
                        _buildPriceItem(
                          '₹${bike.pricePerMonth.toInt()}',
                          'Per Month',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Request Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _requestBike(bike),
                      icon: const Icon(Icons.send),
                      label: const Text('Request This Bike'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(String price, String label) {
    return Column(
      children: [
        Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
