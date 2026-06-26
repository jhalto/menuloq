import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';


class InputLabel extends StatelessWidget {
  const InputLabel({
    super.key,
    required this.text,
    this.isRequired = false,
  });

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RichText(
      text: TextSpan(
        text: text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}