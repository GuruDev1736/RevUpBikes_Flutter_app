import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Color backgroundColor;

  const AuthCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMargin =
        margin ?? const EdgeInsets.symmetric(horizontal: 20);
    final effectivePadding = padding ?? const EdgeInsets.all(30);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(30);
    final effectiveBoxShadow =
        boxShadow ??
        [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ];

    return Container(
      margin: effectiveMargin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: effectiveBorderRadius,
        boxShadow: effectiveBoxShadow,
      ),
      child: Padding(padding: effectivePadding, child: child),
    );
  }
}
