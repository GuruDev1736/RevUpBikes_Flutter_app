import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData logoIcon;
  final List<Color>? gradientColors;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double logoSize;
  final double titleFontSize;
  final double subtitleFontSize;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoIcon = Icons.directions_bike_rounded,
    this.gradientColors,
    this.padding,
    this.borderRadius,
    this.logoSize = 60,
    this.titleFontSize = 36,
    this.subtitleFontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradientColors =
        gradientColors ?? [AppColors.primary, const Color(0xFFD32F2F)];
    final effectivePadding =
        padding ?? const EdgeInsets.fromLTRB(20, 40, 20, 50);
    final effectiveBorderRadius =
        borderRadius ??
        const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        );

    return Container(
      width: double.infinity,
      padding: effectivePadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: effectiveGradientColors,
        ),
        borderRadius: effectiveBorderRadius,
      ),
      child: Column(
        children: [
          // Enhanced Logo Container
          Container(
            width: 130,
            height: 130,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 0,
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/app_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to icon if image not found
                return Icon(logoIcon, color: AppColors.primary, size: logoSize);
              },
            ),
          ),
          const SizedBox(height: 25),

          // App Title with better typography
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
