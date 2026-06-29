import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/route/route_name.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../bloc/forgot_password/forgot_password_bloc.dart';
import '../../bloc/forgot_password/forgot_password_event.dart';
import '../../bloc/forgot_password/forgot_password_state.dart';
import '../input_label.dart';
import '../loading_button_content.dart';
import '../message_box.dart';
import 'forgot_password_info_row.dart';

class ForgotPasswordContent extends StatefulWidget {
  const ForgotPasswordContent({
    super.key,
    this.showBackButton = true,
    this.showWordmark = true,
  });

  final bool showBackButton;
  final bool showWordmark;

  @override
  State<ForgotPasswordContent> createState() => _ForgotPasswordContentState();
}

class _ForgotPasswordContentState extends State<ForgotPasswordContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<ForgotPasswordBloc>().add(
          ForgotPasswordOtpRequested(
            email: _emailController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (context, state) {
        if (state.status == ForgotPasswordStatus.success) {
          Navigator.pushNamed(
            context,
            Routes.resetPassword,
            arguments: state.email,
          );
        }
      },
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isLoading = state.status == ForgotPasswordStatus.loading;

        final titleColor =
            isDark ? AppColors.darkTextPrimary : AppColors.primary;

        final subtitleColor =
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showBackButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.primary,
                    ),
                  ),
                ),

              if (widget.showWordmark) ...[
                const _ForgotPasswordWordmark(),
                const SizedBox(height: 54),
              ],

              const _ForgotPasswordHeroIcon(),
              const SizedBox(height: 34),

              Text(
                'Forgot password?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                    ),
              ),

              const SizedBox(height: 12),

              Text(
                'Enter your registered email address and\nwe’ll send you a 4-digit verification code.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: subtitleColor,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
              ),

              const SizedBox(height: 58),

              const InputLabel(text: 'Email address'),
              const SizedBox(height: 8),

              TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: _emailValidator,
                onFieldSubmitted: (_) => _submit(),
              ),

              const SizedBox(height: 34),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const LoadingButtonContent()
                      : const Text('Send OTP'),
                ),
              ),

              if (state.message != null) ...[
                const SizedBox(height: 16),
                _ForgotPasswordMessage(state: state),
              ],

              const SizedBox(height: 46),

              const ForgotPasswordInfoRow(
                icon: Icons.lock_reset_rounded,
                text: 'The code will be valid for 10 minutes.',
              ),

              const SizedBox(height: 22),

              const ForgotPasswordInfoRow(
                icon: Icons.schedule_rounded,
                text: 'You can request a new OTP after 60 seconds.',
              ),

              const SizedBox(height: 46),

              Divider(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),

              const SizedBox(height: 18),

              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        // Navigator.pushReplacementNamed(context, Routes.login);
                        Navigator.pop(context);
                      },
                child: const Text('Back to sign in'),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address.';
    }

    final isValidEmail = RegExp(
      r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);

    if (!isValidEmail) {
      return 'Please enter a valid email address.';
    }

    return null;
  }
}

class _ForgotPasswordMessage extends StatelessWidget {
  const _ForgotPasswordMessage({
    required this.state,
  });

  final ForgotPasswordState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case ForgotPasswordStatus.success:
        return MessageBox(
          icon: Icons.check_circle_rounded,
          text: state.message ?? 'A 4-digit verification code has been sent.',
          backgroundColor: AppColors.successLight,
          borderColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: AppColors.textPrimary,
          actionText: 'Go to Reset Password',
          actionColor: AppColors.accent,
          onActionTap: () {
            if (state.email.isNotEmpty) {
              Navigator.pushNamed(
                context,
                Routes.resetPassword,
                arguments: state.email,
              );
            }
          },
        );

      case ForgotPasswordStatus.failure:
        return MessageBox(
          icon: Icons.error_rounded,
          text: state.message ?? 'Could not send OTP. Please try again.',
          backgroundColor: AppColors.dangerLight,
          borderColor: AppColors.danger,
          iconColor: AppColors.danger,
          textColor: AppColors.danger,
        );

      case ForgotPasswordStatus.initial:
      case ForgotPasswordStatus.loading:
        return const SizedBox.shrink();
    }
  }
}

class _ForgotPasswordHeroIcon extends StatelessWidget {
  const _ForgotPasswordHeroIcon();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        width: 132,
        height: 132,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkAccentLight : AppColors.accentLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? AppColors.darkAccent.withAlpha(40)
                : AppColors.accent.withAlpha(35),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.mail_rounded,
              color: isDark ? AppColors.darkAccent : AppColors.accent,
              size: 70,
            ),
            Positioned(
              right: 24,
              bottom: 30,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkAccent : AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.background,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: isDark ? AppColors.darkBackground : AppColors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgotPasswordWordmark extends StatelessWidget {
  const _ForgotPasswordWordmark();

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
            style: style?.copyWith(color: AppColors.primary),
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