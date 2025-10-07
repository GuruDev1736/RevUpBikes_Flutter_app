import 'dart:async';
import 'package:flutter/material.dart';
import '../models/banner_model.dart';
import '../utils/app_colors.dart';

class BannerWidget extends StatelessWidget {
  final BannerModel banner;
  final VoidCallback? onTap;
  final double height;
  final EdgeInsetsGeometry margin;

  const BannerWidget({
    Key? key,
    required this.banner,
    this.onTap,
    this.height = 160,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.primary.withOpacity(0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: banner.getImageWidget(fit: BoxFit.cover),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          banner.bannerTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (banner.bannerDescription.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            banner.bannerDescription,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Tap indicator
                if (onTap != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;
  final Function(BannerModel)? onBannerTap;
  final double height;
  final bool autoPlay;
  final Duration autoPlayDuration;

  const BannerCarousel({
    Key? key,
    required this.banners,
    this.onBannerTap,
    this.height = 160,
    this.autoPlay = true,
    this.autoPlayDuration = const Duration(seconds: 4),
  }) : super(key: key);

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  PageController? _pageController;
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    
    if (widget.autoPlay && widget.banners.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController?.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(widget.autoPlayDuration, (timer) {
      if (_pageController?.hasClients == true) {
        _currentPage = (_currentPage + 1) % widget.banners.length;
        _pageController?.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onUserInteraction() {
    if (widget.autoPlay) {
      _stopAutoPlay();
      // Resume auto-play after 3 seconds of no interaction
      Timer(const Duration(seconds: 3), () {
        if (mounted && widget.autoPlay && widget.banners.length > 1) {
          _startAutoPlay();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: GestureDetector(
            onPanDown: (_) => _onUserInteraction(),
            child: PageView.builder(
              itemCount: widget.banners.length,
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                return BannerWidget(
                  banner: banner,
                  height: widget.height,
                  onTap: widget.onBannerTap != null ? () => widget.onBannerTap!(banner) : null,
                );
              },
            ),
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 8),
          _buildPageIndicators(),
        ],
      ],
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.banners.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class BannerList extends StatelessWidget {
  final List<BannerModel> banners;
  final Function(BannerModel)? onBannerTap;
  final double height;

  const BannerList({
    Key? key,
    required this.banners,
    this.onBannerTap,
    this.height = 160,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: banners.map((banner) {
        return BannerWidget(
          banner: banner,
          height: height,
          onTap: onBannerTap != null ? () => onBannerTap!(banner) : null,
        );
      }).toList(),
    );
  }
}
