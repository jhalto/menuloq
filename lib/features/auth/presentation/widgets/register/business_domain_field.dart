import 'package:flutter/material.dart';

class BusinessDomainField extends StatelessWidget {
  const BusinessDomainField({
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
    final theme = Theme.of(context);

    final hintColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: 0.75,
    );

    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.next,
      
      decoration: InputDecoration(
        hintText: 'subdomain',
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: hintColor,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(Icons.domain),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
         
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.35),
                  ),
                ),
              ),
              child: Text(
                '.menuloq.com',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
      validator: validator,
    );
  }
}