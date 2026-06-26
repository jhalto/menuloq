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

  static const double _outerPadding = 24;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(
          flex: 4,
          child: _RegisterBrandPanel(),
        ),

        Expanded(
          flex: 8,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardMinHeight = constraints.maxHeight - (_outerPadding * 2);

              return SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(_outerPadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 620,
                      minHeight: cardMinHeight,
                    ),
                    child: Container(
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
              );
            },
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
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isShortHeight = constraints.maxHeight < 640;

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.all(isShortHeight ? 28 : 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: BrandLogo(color: AppColors.white),
                ),

                SizedBox(height: isShortHeight ? 30 : 50),

                Text(
                  'Start your business\nwith MenuLoq.',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        fontSize: isShortHeight ? 32 : null,
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

                SizedBox(height: isShortHeight ? 24 : 32),

                const _PanelPoint(text: 'Business profile setup'),
                const SizedBox(height: 12),
                const _PanelPoint(text: 'Custom MenuLoq subdomain'),
                const SizedBox(height: 12),
                const _PanelPoint(text: 'Secure password protection'),

                SizedBox(height: isShortHeight ? 24 : 40),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white.withAlpha(24),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.white.withAlpha(35),
                    ),
                  ),
                  child: Text(
                    'Simple setup. Clean dashboard. Better restaurant management.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withAlpha(220),
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                  ),
                ),
              ],
            ),
          );
        },
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
        Flexible(
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