import 'package:flutter/material.dart';
import 'package:menuloq/config/theme/app_colors.dart';

class BusinessSettingTextField extends StatelessWidget {
  const BusinessSettingTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.suffixIcon,
    this.validator,
    this.serverError,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final IconData? suffixIcon;
  final String? Function(String?)? validator;
  final String? serverError;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        errorText: serverError,
        suffixIcon: suffixIcon == null
            ? null
            : Icon(
                suffixIcon,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
        filled: true,
        fillColor: readOnly
            ? isDark
                  ? AppColors.darkFill
                  : AppColors.fill
            : isDark
            ? AppColors.darkCard
            : AppColors.surface,
      ),
    );
  }
}
