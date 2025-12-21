import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/bike_request_model.dart';
import '../models/bike_model.dart';
import '../models/place_model.dart';
import '../services/api_services.dart';
import 'bike_details_screen.dart';

class ManageBikeRequestsScreen extends StatefulWidget {
  const ManageBikeRequestsScreen({super.key});

  @override
  State<ManageBikeRequestsScreen> createState() =>
      _ManageBikeRequestsScreenState();
}

class _ManageBikeRequestsScreenState extends State<ManageBikeRequestsScreen> {
  List<BikeRequestModel> _bikeRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBikeRequests();
  }

  Future<void> _loadBikeRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userData = await AuthService.getUserData();
      print('User data retrieved: $userData');

      if (userData == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'User not logged in';
            _isLoading = false;
          });
        }
        return;
      }

      // Extract user ID from CONTENT object
      final content = userData['CONTENT'];
      if (content == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'User data is invalid. Please login again.';
            _isLoading = false;
          });
        }
        return;
      }

      final dynamic userIdDynamic = content['userId'];
      print(
        'User ID from data: $userIdDynamic (type: ${userIdDynamic.runtimeType})',
      );

      if (userIdDynamic == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'User ID not found. Please login again.';
            _isLoading = false;
          });
        }
        return;
      }

      // Convert to int safely
      int userId;
      if (userIdDynamic is int) {
        userId = userIdDynamic;
      } else if (userIdDynamic is String) {
        userId = int.tryParse(userIdDynamic) ?? 0;
        if (userId == 0) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Invalid user ID. Please login again.';
              _isLoading = false;
            });
          }
          return;
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Invalid user data. Please login again.';
            _isLoading = false;
          });
        }
        return;
      }

      print('Fetching bike requests for user ID: $userId');
      final response = await AuthService.getUserBikeRequests(userId);
      print('API Response: $response');

      if (response['STS'] == '200' && response['CONTENT'] != null) {
        final List<dynamic> requestsJson = response['CONTENT'];
        final List<BikeRequestModel> requests = requestsJson
            .map((json) => BikeRequestModel.fromJson(json))
            .toList();

        if (mounted) {
          setState(() {
            _bikeRequests = requests;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = response['MSG'] ?? 'Failed to load bike requests';
            _isLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      print('Error loading bike requests: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.warning;
      case 'APPROVE':
        return AppColors.success;
      case 'REJECT':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'APPROVE':
        return Icons.check_circle;
      case 'REJECT':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Bike Requests'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
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
                onPressed: _loadBikeRequests,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_bikeRequests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.library_books_outlined,
                size: 64,
                color: AppColors.grey.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Bike Requests Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You haven\'t made any bike requests yet',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBikeRequests,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bikeRequests.length,
        itemBuilder: (context, index) {
          final request = _bikeRequests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(BikeRequestModel request) {
    final statusColor = _getStatusColor(request.status);
    final statusIcon = _getStatusIcon(request.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bike Image and Status Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: request.bike.bikeImage.isNotEmpty
                    ? Image.network(
                        request.bike.bikeImage,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: AppColors.lightGrey,
                            child: const Icon(
                              Icons.directions_bike,
                              size: 64,
                              color: AppColors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 200,
                        color: AppColors.lightGrey,
                        child: const Icon(
                          Icons.directions_bike,
                          size: 64,
                          color: AppColors.grey,
                        ),
                      ),
              ),
              // Status Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: AppColors.white),
                      const SizedBox(width: 4),
                      Text(
                        request.statusLabel,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bike Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bike Name and Brand
                Text(
                  request.bike.bikeName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${request.bike.brand} - ${request.bike.bikeModel}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                // Request Note
                if (request.requestNote.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.note,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            request.requestNote,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.text,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Bike Info Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.location_on,
                        request.bike.place.placeName,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.category,
                        request.bike.category,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.local_gas_station,
                        request.bike.fuelType,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.settings,
                        request.bike.transmission,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Price Info
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
                        '₹${request.bike.pricePerHour.toInt()}',
                        'Per Hour',
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: AppColors.white.withValues(alpha: 0.3),
                      ),
                      _buildPriceItem(
                        '₹${request.bike.pricePerDay.toInt()}',
                        'Per Day',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Request Date
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Requested on: ${request.formattedCreatedDate}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Book Now button for approved requests
                if (request.status.toUpperCase() == 'APPROVE') ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToBooking(request),
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Book Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
                // Delete button for rejected requests
                if (request.status.toUpperCase() == 'REJECT') ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _deleteRequest(request),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Request'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(
                          color: AppColors.error,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToBooking(BikeRequestModel request) {
    // Convert BikeRequestBike to BikeModel
    final bike = BikeModel(
      id: request.bike.id,
      bikeName: request.bike.bikeName,
      bikeModel: request.bike.bikeModel,
      brand: request.bike.brand,
      pricePerHour: request.bike.pricePerHour,
      pricePerDay: request.bike.pricePerDay,
      pricePerWeek: request.bike.pricePerWeek,
      pricePerMonth: request.bike.pricePerMonth,
      description: request.bike.description,
      bikeImage: request.bike.bikeImage,
      category: request.bike.category,
      engineCapacity: request.bike.engineCapacity,
      fuelType: request.bike.fuelType,
      transmission: request.bike.transmission,
      quantity: request.bike.quantity,
      place: Place(
        id: request.bike.place.id,
        placeName: request.bike.place.placeName,
        placeDescription: request.bike.place.placeDescription,
        placeImage: request.bike.place.placeImage,
        placeLocation: request.bike.place.placeLocation,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          request.bike.place.createdAt,
        ),
      ),
      status: request.bike.status,
      registrationNumber: request.bike.registrationNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BikeDetailsScreen(
          bike: bike,
          fromRequest: true,
          requestId: request.id,
        ),
      ),
    );
  }

  Future<void> _deleteRequest(BikeRequestModel request) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request'),
        content: Text(
          'Are you sure you want to delete your request for ${request.bike.bikeName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await AuthService.deleteBikeRequest(request.id);
      Navigator.pop(context); // Close loading

      if (response['STS'] == '200') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['MSG'] ?? 'Request deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        // Reload the bike requests list
        _loadBikeRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['MSG'] ?? 'Failed to delete request'),
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

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.text),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceItem(String price, String label) {
    return Column(
      children: [
        Text(
          price,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
