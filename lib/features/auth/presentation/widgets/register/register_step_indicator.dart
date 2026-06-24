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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepItem(
          number: '1',
          title: 'Business',
          isActive: isBusiness,
        ),
        Container(
          width: 78,
          height: 1.4,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          color: AppColors.border,
        ),
        _StepItem(
          number: '2',
          title: 'Security',
          isActive: isSecurity,
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.title,
    required this.isActive,
  });

  final String number;
  final String title;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.accent;
    final inactiveColor = AppColors.textMuted;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 44,
          height: 44,
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
                ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isActive ? activeColor : inactiveColor,
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}