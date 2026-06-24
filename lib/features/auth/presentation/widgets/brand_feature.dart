import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

class BrandFeature extends StatelessWidget {
  const BrandFeature({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.accent,
          size: 22,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}