import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/bike_model.dart';
import '../services/database_helper.dart';
import 'bike_details_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Bookmarked bikes from database
  List<BikeModel> _bookmarkedBikes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _startAnimations();
    
    // Load bookmarks from database
    _loadBookmarks();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookmarks = await DatabaseHelper.instance.getAllBookmarks();
      setState(() {
        _bookmarkedBikes = bookmarks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading bookmarks: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _removeBookmark(int bikeId) async {
    // Store the bike for undo functionality
    final bikeToRemove = _bookmarkedBikes.firstWhere((bike) => bike.id == bikeId);
    
    // Remove from database
    await DatabaseHelper.instance.removeBookmark(bikeId);
    
    // Remove from UI
    setState(() {
      _bookmarkedBikes.removeWhere((bike) => bike.id == bikeId);
    });

    // Show snackbar with undo option
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed from bookmarks'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.white,
            onPressed: () async {
              // Restore to database
              await DatabaseHelper.instance.addBookmark(bikeToRemove);
              // Reload bookmarks
              _loadBookmarks();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildAnimatedHeader(),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _bookmarkedBikes.isEmpty
                      ? _buildEmptyState()
                      : _buildBookmarksList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Header with back button
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'My Bookmarks',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Clear all bookmarks with confirmation
                        _showClearAllDialog();
                      },
                      icon: const Icon(
                        Icons.delete_sweep,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Bookmark stats
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bookmark,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_bookmarkedBikes.length} Saved Bikes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bookmark_outline,
                    size: 60,
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Bookmarks Yet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Start exploring bikes and save your favorites here',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Explore Bikes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookmarksList() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _bookmarkedBikes.length,
            itemBuilder: (context, index) {
              final bike = _bookmarkedBikes[index];

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves
                    .easeOutCubic, // Changed from easeOutBack to avoid overshoot
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value.clamp(
                        0.0,
                        1.0,
                      ), // Clamp opacity to valid range
                      child: _buildBookmarkCard(bike),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBookmarkCard(BikeModel bike) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BikeDetailsScreen(bike: bike),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Bike image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: bike.bikeImage.isNotEmpty
                        ? (bike.bikeImage.startsWith('http')
                              ? Image.network(
                                  bike.bikeImage,
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.directions_bike,
                                        size: 40,
                                        color: AppColors.primary.withOpacity(
                                          0.7,
                                        ),
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        );
                                      },
                                )
                              : Image.asset(
                                  bike.bikeImage,
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.directions_bike,
                                        size: 40,
                                        color: AppColors.primary.withOpacity(
                                          0.7,
                                        ),
                                      ),
                                    );
                                  },
                                ))
                        : Center(
                            child: Icon(
                              Icons.directions_bike,
                              size: 40,
                              color: AppColors.primary.withOpacity(0.7),
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Bike info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              bike.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          if (!bike.isAvailable)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Unavailable',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        bike.type,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            bike.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            '${bike.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Text(
                            '₹${bike.pricePerDay.toInt()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const Text(
                            '/day',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Remove bookmark button
                IconButton(
                  onPressed: () => _removeBookmark(bike.id),
                  icon: const Icon(
                    Icons.bookmark,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    if (_bookmarkedBikes.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Clear All Bookmarks'),
          content: const Text(
            'Are you sure you want to remove all bookmarked bikes?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                // Clear from database
                await DatabaseHelper.instance.clearAllBookmarks();
                
                // Clear from UI
                setState(() {
                  _bookmarkedBikes.clear();
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('All bookmarks cleared'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}
