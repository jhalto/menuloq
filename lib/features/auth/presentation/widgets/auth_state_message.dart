import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_colors.dart';
import '../bloc/login/auth_bloc.dart';
import '../bloc/login/auth_event.dart';
import '../bloc/login/auth_state.dart';
import 'message_box.dart';

class AuthStateMessage extends StatelessWidget {
  const AuthStateMessage({
    super.key,
    required this.state,
  });

  final AuthState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case AuthStatus.failure:
        return MessageBox(
          icon: Icons.error_rounded,
          text: state.message ?? 'Email or password is incorrect.',
          backgroundColor: AppColors.dangerLight,
          borderColor: AppColors.danger,
          iconColor: AppColors.danger,
          textColor: AppColors.danger,
        );

      case AuthStatus.emailNotVerified:
        return MessageBox(
          icon: Icons.warning_rounded,
          text: state.message ??
              'Please verify your email address before signing in.',
          actionText: 'Verify email',
          backgroundColor: AppColors.warningLight,
          borderColor: AppColors.warning,
          iconColor: AppColors.warning,
          textColor: AppColors.textPrimary,
          actionColor: AppColors.warning,
          onActionTap: () {
            context.read<AuthBloc>().add(VerifyEmailRequested());
          },
        );

      case AuthStatus.inactive:
        return MessageBox(
          icon: Icons.warning_rounded,
          text: state.message ??
              'Your account is inactive. Please contact support.',
          actionText: 'Contact support',
          backgroundColor: AppColors.warningLight,
          borderColor: AppColors.warning,
          iconColor: AppColors.warning,
          textColor: AppColors.textPrimary,
          actionColor: AppColors.warning,
          onActionTap: () {
            // Open support page or contact screen.
          },
        );

      case AuthStatus.success:
        return const MessageBox(
          icon: Icons.check_circle_rounded,
          text: 'Login successful. Opening dashboard...',
          backgroundColor: AppColors.successLight,
          borderColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: AppColors.textPrimary,
        );

      case AuthStatus.initial:
      case AuthStatus.loading:
        return const SizedBox.shrink();
    }
  }
}