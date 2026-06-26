import 'package:flutter/material.dart';
import 'package:menuloq/config/theme/app_colors.dart';

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.menuColor = AppColors.accent,
    this.loqColor = AppColors.primary,
    this.fontSize,
  });

  final Color menuColor;
  final Color loqColor;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
  
    final style = Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Menu',
            style: style?.copyWith(color: menuColor),
          ),
          TextSpan(
            text: 'Loq',
            style: style?.copyWith(color: loqColor),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}