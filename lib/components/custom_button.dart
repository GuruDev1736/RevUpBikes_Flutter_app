import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isOutlined;
  final Color? borderColor;
  final double borderWidth;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 55,
    this.margin,
    this.borderRadius,
    this.gradientColors,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.fontSize = 18,
    this.fontWeight = FontWeight.bold,
    this.isOutlined = false,
    this.borderColor,
    this.borderWidth = 1.5,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? double.infinity;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);
    final effectiveGradientColors =
        gradientColors ?? [AppColors.primary, const Color(0xFFD32F2F)];

    if (isOutlined) {
      return Container(
        width: effectiveWidth,
        height: height,
        margin: margin,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: icon ?? const SizedBox.shrink(),
          label: Text(text),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: borderColor ?? AppColors.primary,
              width: borderWidth,
            ),
            foregroundColor: borderColor ?? AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
          ),
        ),
      );
    }

    return Container(
      width: effectiveWidth,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        gradient: backgroundColor == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: effectiveGradientColors,
              )
            : null,
        color: backgroundColor,
        borderRadius: effectiveBorderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: fontWeight,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
