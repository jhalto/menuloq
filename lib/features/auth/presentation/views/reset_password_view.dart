import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_colors.dart';
import '../bloc/reset_password/reset_password_bloc.dart';
import '../bloc/reset_password/reset_password_event.dart';
import '../widgets/reset_password/reset_password_content.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({
    super.key,
    this.initialEmail = '',
  });

  final String initialEmail;

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  static const double _tabletBreakpoint = 720;

  @override
  void initState() {
    super.initState();

    context.read<ResetPasswordBloc>().add(
          ResetPasswordStarted(email: widget.initialEmail),
        );
  }

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
              return _TabletResetPasswordLayout(
                initialEmail: widget.initialEmail,
              );
            }

            return _MobileResetPasswordLayout(
              initialEmail: widget.initialEmail,
            );
          },
        ),
      ),
    );
  }
}

class _MobileResetPasswordLayout extends StatelessWidget {
  const _MobileResetPasswordLayout({
    required this.initialEmail,
  });

  final String initialEmail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ResetPasswordContent(initialEmail: initialEmail),
        ),
      ),
    );
  }
}

class _TabletResetPasswordLayout extends StatelessWidget {
  const _TabletResetPasswordLayout({
    required this.initialEmail,
  });

  final String initialEmail;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        const Expanded(
          child: _ResetPasswordBrandPanel(),
        ),
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
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
                child: ResetPasswordContent(
                  initialEmail: initialEmail,
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

class _ResetPasswordBrandPanel extends StatelessWidget {
  const _ResetPasswordBrandPanel();

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
            'Create a secure\nnew password.',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Use your verification code and set a strong password to recover your MenuLoq account.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.white.withAlpha(210),
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 32),
          const _PanelPoint(text: 'OTP verification'),
          const SizedBox(height: 12),
          const _PanelPoint(text: 'Strong password validation'),
          const SizedBox(height: 12),
          const _PanelPoint(text: 'Secure account recovery'),
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