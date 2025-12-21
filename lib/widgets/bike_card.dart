import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/bike_model.dart';
import '../screens/bike_details_screen.dart';
import '../screens/auth_screen.dart';
import '../utils/city_image_provider.dart';
import '../services/api_services.dart';

class BikeCard extends StatefulWidget {
  final BikeModel bike;
  final bool hasActiveBooking;

  const BikeCard({
    super.key,
    required this.bike,
    this.hasActiveBooking = false,
  });

  @override
  State<BikeCard> createState() => _BikeCardState();
}

class _BikeCardState extends State<BikeCard> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }

  Future<void> _handleRentNow() async {
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!isLoggedIn && mounted) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text(
            'You need to login to rent a bike. Would you like to login now?',
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
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
        _checkLoginStatus();
      }
    } else if (widget.hasActiveBooking && mounted) {
      // Show alert that user has active booking
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Active Booking'),
            ],
          ),
          content: const Text(
            'You already have an active booking. You can view details but cannot make a new booking.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      // Still navigate to details page but booking will be disabled there
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BikeDetailsScreen(bike: widget.bike),
        ),
      );
    } else if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BikeDetailsScreen(bike: widget.bike),
        ),
      );
    }
  }

  Widget _buildPriceItem(String price, String period) {
    return Column(
      children: [
        Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          period,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoggedIn && !widget.hasActiveBooking
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BikeDetailsScreen(bike: widget.bike),
                ),
              );
            }
          : null,
      child: Opacity(
        opacity: widget.hasActiveBooking ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bike Image
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: _buildBikeImage(),
                ),
              ),

              // Bike Info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Type
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.bike.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.bike.type,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.bike.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Quantity
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory_2,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Quantity:',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.bike.quantity}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // All Prices
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPriceItem(
                            '₹${widget.bike.pricePerDay.toInt()}',
                            '/day',
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: AppColors.grey.withOpacity(0.3),
                          ),
                          _buildPriceItem(
                            '₹${(widget.bike.pricePerWeek / 1000).toStringAsFixed(1)}k',
                            '/week',
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: AppColors.grey.withOpacity(0.3),
                          ),
                          _buildPriceItem(
                            '₹${(widget.bike.pricePerMonth / 1000).toStringAsFixed(1)}k',
                            '/mon',
                          ),
                        ],
                      ),
                    ),

                    if (_isLoggedIn) ...[
                      const SizedBox(height: 16),
                      // Rent Now Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: widget.hasActiveBooking
                              ? null
                              : _handleRentNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.hasActiveBooking
                                ? AppColors.grey
                                : AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: widget.hasActiveBooking ? 0 : 2,
                            disabledBackgroundColor: AppColors.grey,
                          ),
                          child: Text(
                            widget.hasActiveBooking
                                ? 'Booking Disabled'
                                : 'Rent Now',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  Widget _buildBikeImage() {
    // Use the bike image from API first, then fallback to predefined images
    String? imageUrl = widget.bike.bikeImage.isNotEmpty
        ? widget.bike.bikeImage
        : (CityImageProvider.getBikeImageUrl(widget.bike.name) ??
              CityImageProvider.getBikeImageByType(widget.bike.type));

    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Check if it's a network URL or local asset
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppColors.lightGrey.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
            );
          },
        );
      } else {
        // Handle local asset images
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage();
          },
        );
      }
    } else {
      return _buildFallbackImage();
    }
  }

  Widget _buildFallbackImage() {
    return Container(
      color: AppColors.lightGrey.withOpacity(0.3),
      child: Center(
        child: Icon(
          Icons.directions_bike,
          size: 80,
          color: AppColors.primary.withOpacity(0.7),
        ),
      ),
    );
  }
}
