import 'package:flutter/material.dart';

import '../../../../../config/theme/app_colors.dart';

class ForgotPasswordInfoRow extends StatelessWidget {
  const ForgotPasswordInfoRow({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final iconBgColor =
        isDark ? AppColors.darkAccentLight : AppColors.accentLight;

    final textColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.darkAccent : AppColors.accent,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );
  }
}