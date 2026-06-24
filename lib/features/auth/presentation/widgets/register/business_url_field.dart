import 'package:flutter/material.dart';
import 'package:menuloq/config/theme/app_colors.dart';


class BusinessUrlField extends StatelessWidget {
  const BusinessUrlField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.validator,
  });

  final TextEditingController controller;
  final bool enabled;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: 'your-business',
        prefixIcon: const Icon(Icons.language_rounded),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 134,
          minHeight: 56,
        ),
        suffixIcon: Container(
          alignment: Alignment.centerRight,
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.border),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              '.menuloq.com',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ),
      ),
      validator: validator,
    );
  }
}