import 'package:flutter/material.dart';

class AuthFooter extends StatelessWidget {
  final String dividerText;
  final String footerText;
  final EdgeInsets? padding;
  final TextStyle? dividerTextStyle;
  final TextStyle? footerTextStyle;
  final Color? dividerColor;

  const AuthFooter({
    super.key,
    this.dividerText = 'Secure & Trusted',
    this.footerText =
        'By continuing, you agree to our Terms of Service and Privacy Policy',
    this.padding,
    this.dividerTextStyle,
    this.footerTextStyle,
    this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 40);
    final effectiveDividerColor = dividerColor ?? Colors.grey[300];
    final effectiveDividerTextStyle =
        dividerTextStyle ??
        TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
    final effectiveFooterTextStyle =
        footerTextStyle ??
        TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4);

    return Padding(
      padding: effectivePadding,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Divider(color: effectiveDividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(dividerText, style: effectiveDividerTextStyle),
              ),
              Expanded(child: Divider(color: effectiveDividerColor)),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            footerText,
            textAlign: TextAlign.center,
            style: effectiveFooterTextStyle,
          ),
        ],
      ),
    );
  }
}
