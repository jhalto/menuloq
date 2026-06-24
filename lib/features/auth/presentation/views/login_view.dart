import 'package:flutter/material.dart';
import 'package:menuloq/features/auth/presentation/layouts/mobile_login_layout.dart';
import 'package:menuloq/features/auth/presentation/layouts/tablet_login_layout.dart';

import '../../../../config/theme/app_colors.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  static const double _tabletBreakpoint = 720;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= _tabletBreakpoint;

            if (isTablet) {
              return const TabletLoginLayout();
            }

            return const MobileLoginLayout();
          },
        ),
      ),
    );
  }
}