import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;
  final Color previousColor;
  final double height;
  final EdgeInsets? margin;
  final double spacing;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor = AppColors.primary,
    this.inactiveColor = Colors.grey,
    this.previousColor = AppColors.primary,
    this.height = 4,
    this.margin,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 25),
      child: Row(
        children: List.generate(totalSteps, (index) {
          Color stepColor;
          if (index < currentStep) {
            // Previous steps
            stepColor = previousColor.withOpacity(0.3);
          } else if (index == currentStep) {
            // Current active step
            stepColor = activeColor;
          } else {
            // Future steps
            stepColor = inactiveColor.withOpacity(0.3);
          }

          return Expanded(
            child: Container(
              height: height,
              margin: EdgeInsets.only(
                right: index < totalSteps - 1 ? spacing : 0,
              ),
              decoration: BoxDecoration(
                color: stepColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
