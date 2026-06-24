import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../widgets/brand_logo.dart';
import '../widgets/register/register_content.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  static const double _tabletBreakpoint = 720;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= _tabletBreakpoint;

            if (isTablet) {
              return const _TabletRegisterLayout();
            }

            return const _MobileRegisterLayout();
          },
        ),
      ),
    );
  }
}

class _MobileRegisterLayout extends StatelessWidget {
  const _MobileRegisterLayout();

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 430),
          child: RegisterContent(),
        ),
      ),
    );
  }
}

class _TabletRegisterLayout extends StatelessWidget {
  const _TabletRegisterLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _RegisterBrandPanel()),
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(34),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withAlpha(120),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.lightShadow,
                      blurRadius: 28,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: const RegisterContent(showWordmark: false),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterBrandPanel extends StatelessWidget {
  const _RegisterBrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.center,
            child: BrandLogo(color: AppColors.white),
          ),
          const Spacer(),
          Text(
            'Start your business\nwith MenuLoq.',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create your business profile, choose your MenuLoq URL, and secure your account in minutes.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.white.withAlpha(210),
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 32),
          const _PanelPoint(text: 'Business profile setup'),
          const SizedBox(height: 12),
          const _PanelPoint(text: 'Custom MenuLoq subdomain'),
          const SizedBox(height: 12),
          const _PanelPoint(text: 'Secure password protection'),
        ],
      ),
    );
  }
}

class _PanelPoint extends StatelessWidget {
  const _PanelPoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.accent,
          size: 22,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}