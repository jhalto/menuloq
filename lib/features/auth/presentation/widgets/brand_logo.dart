import 'package:flutter/material.dart';
import 'package:menuloq/core/global/brand_word_mark.dart';

import '../../../../config/theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.color = AppColors.primary});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BrandWordmark(loqColor: color),
        const SizedBox(height: 20),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color == AppColors.white
                ? AppColors.white.withAlpha(20)
                : AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.restaurant_menu_rounded, color: color, size: 38),
              Positioned(
                right: 7,
                bottom: 8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
