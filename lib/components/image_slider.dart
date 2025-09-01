import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ImageSlider extends StatefulWidget {
  final List<SliderItem> items;
  final double height;
  final Duration autoPlayDuration;
  final bool autoPlay;

  const ImageSlider({
    super.key,
    required this.items,
    this.height = 180,
    this.autoPlayDuration = const Duration(seconds: 4),
    this.autoPlay = true,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.autoPlayDuration, (timer) {
      if (_currentIndex < widget.items.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        children: [
          // Page view for images
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              return _buildSliderItem(widget.items[index]);
            },
          ),

          // Indicators
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.items.length,
                (index) => _buildIndicator(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem(SliderItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: item.gradient ?? AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background pattern or image placeholder
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: item.gradient ?? AppColors.primaryGradient,
                ),
                child: CustomPaint(painter: PatternPainter()),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.icon != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon!, color: Colors.white, size: 24),
                    ),
                  if (item.icon != null) const SizedBox(height: 12),
                  Flexible(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: Text(
                      item.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.buttonText != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item.buttonText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentIndex == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentIndex == index
            ? Colors.white
            : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class SliderItem {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? buttonText;
  final LinearGradient? gradient;

  SliderItem({
    required this.title,
    required this.subtitle,
    this.icon,
    this.buttonText,
    this.gradient,
  });
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw subtle pattern circles
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2 + (i * 30)),
        15 - (i * 3),
        paint,
      );
    }

    // Draw bike icon pattern
    final iconPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.7),
        radius: 25,
      ),
    );
    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.65, size.height * 0.7),
        radius: 20,
      ),
    );

    canvas.drawPath(path, iconPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Extension to add default slider items
extension SliderDefaults on ImageSlider {
  static List<SliderItem> get defaultItems => [
    SliderItem(
      title: 'Explore the City',
      subtitle: 'Discover new places with our premium bikes',
      icon: Icons.explore,
      buttonText: 'Start Riding',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
      ),
    ),
    SliderItem(
      title: 'Go Electric',
      subtitle: 'Eco-friendly rides for a better tomorrow',
      icon: Icons.electric_bolt,
      buttonText: 'Try Electric',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF43A047), Color(0xFF388E3C)],
      ),
    ),
    SliderItem(
      title: 'Adventure Awaits',
      subtitle: 'Mountain bikes for thrilling experiences',
      icon: Icons.terrain,
      buttonText: 'Book Now',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
      ),
    ),
    SliderItem(
      title: 'Special Offers',
      subtitle: 'Up to 50% off on weekend rides',
      icon: Icons.local_offer,
      buttonText: 'View Offers',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8E24AA), Color(0xFF7B1FA2)],
      ),
    ),
  ];
}
