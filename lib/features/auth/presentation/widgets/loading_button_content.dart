import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

class LoadingButtonContent extends StatelessWidget {
  const LoadingButtonContent({
    super.key,
    this.label = 'Signing in...',
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
        ),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}
