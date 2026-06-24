import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../widgets/login/login_brand_panel.dart';
import '../widgets/login/login_content.dart';

class TabletLoginLayout extends StatelessWidget {
  const TabletLoginLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: LoginBrandPanel(),
        ),
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 460),
                padding: const EdgeInsets.all(34),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.lightShadow,
                      blurRadius: 28,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: const LoginContent(showLogo: false),
              ),
            ),
          ),
        ),
      ],
    );
  }
}