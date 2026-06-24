import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

class LoadingButtonContent extends StatelessWidget {
  const LoadingButtonContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
        ),
        SizedBox(width: 12),
        Text('Signing in...'),
      ],
    );
  }
}