import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/route/route_name.dart';
import 'package:menuloq/core/global/app_toast.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../bloc/reset_password/reset_password_bloc.dart';
import '../../bloc/reset_password/reset_password_event.dart';
import '../../bloc/reset_password/reset_password_state.dart';
import '../input_label.dart';
import '../loading_button_content.dart';

class ResetPasswordContent extends StatefulWidget {
  const ResetPasswordContent({
    super.key,
    required this.email,
    required this.otp,
    this.showBackButton = true,
    this.showWordmark = true,
  });
  final String email;
  final String otp;
  final bool showBackButton;
  final bool showWordmark;

  @override
  State<ResetPasswordContent> createState() => _ResetPasswordContentState();
}

class _ResetPasswordContentState extends State<ResetPasswordContent> {
  final _formKey = GlobalKey<FormState>();

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _newPasswordFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<ResetPasswordBloc>().add(
      ResetPasswordSubmitted(
        email: widget.email,
        otp: widget.otp,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            previous.message != current.message;
      },
      listener: (context, state) {
        if ((state.status == ResetPasswordStatus.failure ||
                state.status == ResetPasswordStatus.expired ||
                state.status == ResetPasswordStatus.passwordMismatch) &&
            state.message != null) {
          AppToast.error(context, message: state.message!);
        }

        if (state.status == ResetPasswordStatus.success) {
          AppToast.success(
            context,
            message: 'Password changed successfully.',
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final isLoading = state.status == ResetPasswordStatus.loading;

        final titleColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.primary;

        final subtitleColor = isDark
            ? AppColors.darkTextSecondary
            : AppColors.textSecondary;

        final newPassword = _newPasswordController.text;
        final confirmPassword = _confirmPasswordController.text;

        final hasMinLength = newPassword.length >= 8;
        final passwordsMatch =
            newPassword.isNotEmpty && newPassword == confirmPassword;

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
                    icon: Icon(Icons.arrow_back_rounded, color: titleColor),
                  ),
                ),

              if (widget.showWordmark) ...[
                const _ResetPasswordWordmark(),
                const SizedBox(height: 30),
              ],

              const _ResetPasswordIcon(),
              const SizedBox(height: 22),

              Text(
                'Reset password',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Update your account password to keep your account secure.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: subtitleColor,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 30),

              const InputLabel(text: 'New password', isRequired: true),
              const SizedBox(height: 8),

              TextFormField(
                controller: _newPasswordController,
                focusNode: _newPasswordFocusNode,
                enabled: !isLoading,
                obscureText: _obscureNewPassword,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Enter new password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: _newPasswordValidator,
                onFieldSubmitted: (_) {
                  _confirmPasswordFocusNode.requestFocus();
                },
              ),

              const SizedBox(height: 18),

              const InputLabel(text: 'Confirm password', isRequired: true),
              const SizedBox(height: 8),

              TextFormField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                enabled: !isLoading,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Re-enter new password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: _confirmPasswordValidator,
                onFieldSubmitted: (_) => _submit(),
              ),

              const SizedBox(height: 12),

              Text(
                'Use at least 8 characters.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: subtitleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _RuleChip(isValid: hasMinLength, text: '8+ characters'),
                  _RuleChip(isValid: passwordsMatch, text: 'Passwords match'),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const LoadingButtonContent(
                          label: 'Resetting password...',
                        )
                      : const Text('Reset password'),
                ),
              ),

            ],
          ),
        );
      },
    );
  }



  String? _newPasswordValidator(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter your new password.';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please confirm your new password.';
    }

    if (confirmPassword != _newPasswordController.text) {
      return 'Password confirmation does not match.';
    }

    return null;
  }
}

class _RuleChip extends StatelessWidget {
  const _RuleChip({required this.isValid, required this.text});

  final bool isValid;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isValid
        ? isDark
              ? const Color(0xFF12351F)
              : AppColors.accentLight
        : isDark
        ? AppColors.darkFill
        : AppColors.fill;

    final borderColor = isValid
        ? AppColors.accent
        : isDark
        ? AppColors.darkBorder
        : AppColors.border;

    final textColor = isValid
        ? isDark
              ? AppColors.darkAccent
              : AppColors.accent
        : isDark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withAlpha(isValid ? 180 : 120)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              isValid
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              key: ValueKey<bool>(isValid),
              size: 18,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetPasswordIcon extends StatelessWidget {
  const _ResetPasswordIcon();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.lock_reset_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
              size: 44,
            ),
            Positioned(
              right: 15,
              bottom: 15,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetPasswordWordmark extends StatelessWidget {
  const _ResetPasswordWordmark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final style = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -0.4,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Menu',
            style: style?.copyWith(
              color: isDark ? AppColors.accent : AppColors.primary,
            ),
          ),
          TextSpan(
            text: 'Loq',
            style: style?.copyWith(
              color: isDark ? AppColors.white : AppColors.accent,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
