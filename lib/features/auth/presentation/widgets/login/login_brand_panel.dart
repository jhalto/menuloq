import 'package:flutter/material.dart';

import '../../../../../config/theme/app_colors.dart';
import '../brand_feature.dart';
import '../brand_logo.dart';

class LoginBrandPanel extends StatelessWidget {
  const LoginBrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.dark();
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.center,
            child: BrandLogo(color: AppColors.white),
          ),
          const Spacer(),
          Text(
            'Run your restaurant\nwith confidence.',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Manage POS, QR menu, orders, billing, tables and reports from one simple dashboard.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.white.withAlpha(210),
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 32),
          const BrandFeature(text: 'Smart restaurant POS'),
          const SizedBox(height: 12),
          const BrandFeature(text: 'Digital QR menu'),
          const SizedBox(height: 12),
          const BrandFeature(text: 'Order & billing management'),
        ],
      ),
    );
  }
}