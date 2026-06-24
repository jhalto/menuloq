import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../widgets/forgot_password/forgot_password_content.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

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
              return const _TabletForgotPasswordLayout();
            }

            return const _MobileForgotPasswordLayout();
          },
        ),
      ),
    );
  }
}

class _MobileForgotPasswordLayout extends StatelessWidget {
  const _MobileForgotPasswordLayout();

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 430),
          child: ForgotPasswordContent(),
        ),
      ),
    );
  }
}

class _TabletForgotPasswordLayout extends StatelessWidget {
  const _TabletForgotPasswordLayout();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        const Expanded(
          child: _ForgotPasswordBrandPanel(),
        ),
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(34),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? AppColors.darkShadow
                          : AppColors.lightShadow,
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: const ForgotPasswordContent(
                  showBackButton: false,
                  showWordmark: false,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ForgotPasswordBrandPanel extends StatelessWidget {
  const _ForgotPasswordBrandPanel();

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
          const _PanelWordmark(),
          const Spacer(),
          Text(
            'Recover your\naccount safely.',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'We’ll send a secure verification code to your registered email address.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.white.withAlpha(210),
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 32),
          const _PanelPoint(text: '4-digit OTP verification'),
          const SizedBox(height: 12),
          const _PanelPoint(text: '10 minutes code validity'),
          const SizedBox(height: 12),
          const _PanelPoint(text: 'Secure password reset flow'),
        ],
      ),
    );
  }
}

class _PanelWordmark extends StatelessWidget {
  const _PanelWordmark();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Menu',
            style: style?.copyWith(color: AppColors.white),
          ),
          TextSpan(
            text: 'Loq',
            style: style?.copyWith(color: AppColors.accent),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _PanelPoint extends StatelessWidget {
  const _PanelPoint({
    required this.text,
  });

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
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}