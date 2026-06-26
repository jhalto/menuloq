import 'package:flutter/material.dart';
import 'package:menuloq/config/theme/app_colors.dart';
import 'package:menuloq/features/auth/presentation/bloc/register/register_state.dart';

class RegisterStepIndicator extends StatelessWidget {
  const RegisterStepIndicator({
    super.key,
    required this.currentStep,
  });

  final RegisterStep currentStep;

  @override
  Widget build(BuildContext context) {
    final isBusiness = currentStep == RegisterStep.business;
    final isSecurity = currentStep == RegisterStep.security;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;

        return Row(
          children: [
            Flexible(
              child: _StepItem(
                number: '1',
                title: 'Business',
                isActive: isBusiness,
                isCompact: isCompact,
              ),
            ),

            Expanded(
              child: Container(
                height: 1.4,
                margin: EdgeInsets.symmetric(
                  horizontal: isCompact ? 8 : 14,
                ),
                color: AppColors.border,
              ),
            ),

            Flexible(
              child: _StepItem(
                number: '2',
                title: 'Security',
                isActive: isSecurity,
                isCompact: isCompact,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.title,
    required this.isActive,
    required this.isCompact,
  });

  final String number;
  final String title;
  final bool isActive;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.accent;
    final inactiveColor = AppColors.textMuted;

    final circleSize = isCompact ? 38.0 : 44.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: circleSize,
          height: circleSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? activeColor : AppColors.border,
              width: 1.4,
            ),
          ),
          child: Text(
            number,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isActive ? AppColors.white : inactiveColor,
                  fontWeight: FontWeight.w900,
                  fontSize: isCompact ? 14 : null,
                ),
          ),
        ),
        SizedBox(width: isCompact ? 7 : 10),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isActive ? activeColor : inactiveColor,
                  fontWeight: FontWeight.w900,
                  fontSize: isCompact ? 13 : null,
                ),
          ),
        ),
      ],
    );
  }
}