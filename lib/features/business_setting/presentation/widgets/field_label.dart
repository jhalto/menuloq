
import 'package:flutter/material.dart';
import 'package:menuloq/config/theme/app_colors.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key,required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
