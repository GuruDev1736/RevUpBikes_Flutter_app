import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomTabBar extends StatelessWidget {
  final TabController tabController;
  final List<CustomTabItem> tabs;
  final double height;
  final EdgeInsets? padding;
  final Color backgroundColor;
  final Color indicatorColor;
  final List<Color>? indicatorGradientColors;
  final Color labelColor;
  final Color unselectedLabelColor;
  final double labelFontSize;
  final double unselectedLabelFontSize;

  const CustomTabBar({
    super.key,
    required this.tabController,
    required this.tabs,
    this.height = 65,
    this.padding,
    this.backgroundColor = const Color(0xFFF0F0F0),
    this.indicatorColor = AppColors.primary,
    this.indicatorGradientColors,
    this.labelColor = Colors.white,
    this.unselectedLabelColor = const Color(0xFF6B6B6B),
    this.labelFontSize = 17,
    this.unselectedLabelFontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradientColors =
        indicatorGradientColors ?? [AppColors.primary, const Color(0xFFD32F2F)];

    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: effectiveGradientColors,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: indicatorColor.withOpacity(0.4),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        labelColor: labelColor,
        unselectedLabelColor: unselectedLabelColor,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: labelFontSize,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: unselectedLabelFontSize,
          letterSpacing: 0.3,
        ),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        splashFactory: NoSplash.splashFactory,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        indicatorPadding: EdgeInsets.zero,
        indicatorWeight: 0,
        tabs: tabs
            .map(
              (tab) => Tab(
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(tab.icon, size: 20),
                      const SizedBox(width: 8),
                      Text(tab.text),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class CustomTabItem {
  final String text;
  final IconData icon;

  const CustomTabItem({required this.text, required this.icon});
}
