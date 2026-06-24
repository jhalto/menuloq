import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../bloc/reset_password/reset_password_bloc.dart';
import '../../bloc/reset_password/reset_password_event.dart';
import '../../bloc/reset_password/reset_password_state.dart';
import '../input_label.dart';
import '../loading_button_content.dart';
import '../message_box.dart';
import '../verifly_email/otp_code_field.dart';

class ResetPasswordContent extends StatefulWidget {
  const ResetPasswordContent({
    super.key,
    this.initialEmail = '',
    this.showBackButton = true,
    this.showWordmark = true,
  });

  final String initialEmail;
  final bool showBackButton;
  final bool showWordmark;

  @override
  State<ResetPasswordContent> createState() => _ResetPasswordContentState();
}

class _ResetPasswordContentState extends State<ResetPasswordContent> {
  final _formKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<OtpCodeFieldState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _otpCode = '';

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    final otp = _otpKey.currentState?.code ?? _otpCode;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (otp.length != 4) {
      context.read<ResetPasswordBloc>().add(
            ResetPasswordSubmitted(
              email: _emailController.text.trim(),
              code: otp,
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
            ),
          );
      return;
    }

    context.read<ResetPasswordBloc>().add(
          ResetPasswordSubmitted(
            email: _emailController.text.trim(),
            code: otp,
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          ),
        );
  }

  void _requestNewOtp() {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();

    if (_emailValidator(email) != null) {
      _formKey.currentState?.validate();
      return;
    }

    _otpCode = '';
    _otpKey.currentState?.clear();

    context.read<ResetPasswordBloc>().add(
          ResetPasswordOtpRequested(email: email),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
      listener: (context, state) {
        if (state.status == ResetPasswordStatus.success) {
          // Navigator.pushReplacementNamed(context, Routes.login);
        }
      },
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isLoading = state.status == ResetPasswordStatus.loading;

        final titleColor =
            isDark ? AppColors.darkTextPrimary : AppColors.primary;

        final subtitleColor =
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

        final password = _passwordController.text;
        final confirmPassword = _confirmPasswordController.text;

        final hasMinLength = password.length >= 8;
        final passwordsMatch =
            password.isNotEmpty && password == confirmPassword;

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
                      color: titleColor,
                    ),
                  ),
                ),

              if (widget.showWordmark) ...[
                const _ResetPasswordWordmark(),
                const SizedBox(height: 30),
              ],

              const _ResetPasswordIcon(),
              const SizedBox(height: 22),

              Text(
                'Create a new password',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
              ),

              const SizedBox(height: 10),

              Text(
                'Enter your verification code and\nchoose a secure new password.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: subtitleColor,
                      height: 1.45,
                    ),
              ),

              const SizedBox(height: 30),

              const InputLabel(text: 'Email address'),
              const SizedBox(height: 8),

              TextFormField(
                controller: _emailController,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: _emailValidator,
              ),

              const SizedBox(height: 20),

              const InputLabel(text: 'Verification code'),
              const SizedBox(height: 10),

              OtpCodeField(
                key: _otpKey,
                enabled: !isLoading,
                onCompleted: (code) {
                  _otpCode = code;
                },
              ),

              const SizedBox(height: 10),

              Text(
                'Auto-focus, numbers only, and paste entire code supported.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: subtitleColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(height: 18),

              const InputLabel(text: 'New password'),
              const SizedBox(height: 8),

              TextFormField(
                controller: _passwordController,
                enabled: !isLoading,
                obscureText: _obscurePassword,
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
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: _passwordValidator,
              ),

              const SizedBox(height: 18),

              const InputLabel(text: 'Confirm password'),
              const SizedBox(height: 8),

              TextFormField(
                controller: _confirmPasswordController,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: subtitleColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(height: 8),

              _PasswordStrengthBar(score: _passwordScore(password)),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _RuleChip(
                    isValid: hasMinLength,
                    text: '8+ characters',
                  ),
                  _RuleChip(
                    isValid: passwordsMatch,
                    text: 'Passwords match',
                  ),
                ],
              ),

              const SizedBox(height: 22),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const LoadingButtonContent()
                      : const Text('Reset password'),
                ),
              ),

              if (isLoading) ...[
                const SizedBox(height: 12),
                const _ResettingBox(),
              ],

              const SizedBox(height: 14),

              TextButton(
                onPressed: isLoading ? null : _requestNewOtp,
                child: const Text('Request a new OTP'),
              ),

              if (state.message != null) ...[
                const SizedBox(height: 18),
                _ResetPasswordStatusMessage(state: state),
              ],

              const SizedBox(height: 24),

              TextButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                        // Navigator.pushReplacementNamed(context, Routes.login);
                        Navigator.pop(context);
                      },
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to sign in'),
              ),
            ],
          ),
        );
      },
    );
  }

  int _passwordScore(String password) {
    var score = 0;

    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    return score.clamp(0, 4);
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

  String? _passwordValidator(String? value) {
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
      return 'Please confirm your password.';
    }

    if (confirmPassword != _passwordController.text) {
      return 'Password confirmation does not match.';
    }

    return null;
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({
    required this.score,
  });

  final int score;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: List.generate(4, (index) {
        final isActive = index < score;

        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.accent
                  : isDark
                      ? AppColors.darkBorder
                      : AppColors.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

class _RuleChip extends StatelessWidget {
  const _RuleChip({
    required this.isValid,
    required this.text,
  });

  final bool isValid;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isValid
        ? isDark
            ? const Color(0xFF173D22)
            : AppColors.accentLight
        : isDark
            ? AppColors.darkFill
            : AppColors.fill;

    final borderColor = isValid ? AppColors.accent : AppColors.border;

    final textColor = isValid
        ? isDark
            ? AppColors.darkAccent
            : AppColors.accent
        : isDark
            ? AppColors.darkTextMuted
            : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withAlpha(isValid ? 150 : 100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle_outline_rounded : Icons.circle_outlined,
            size: 18,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _ResetPasswordStatusMessage extends StatelessWidget {
  const _ResetPasswordStatusMessage({
    required this.state,
  });

  final ResetPasswordState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (state.status) {
      case ResetPasswordStatus.failure:
        return MessageBox(
          icon: Icons.error_rounded,
          text: state.message ?? 'The OTP code is invalid.',
          backgroundColor:
              isDark ? const Color(0xFF3A1515) : AppColors.dangerLight,
          borderColor: AppColors.danger,
          iconColor: AppColors.danger,
          textColor: isDark ? AppColors.darkTextPrimary : AppColors.danger,
        );

      case ResetPasswordStatus.expired:
        return MessageBox(
          icon: Icons.timer_rounded,
          text: state.message ?? 'OTP has expired. Please request a new OTP.',
          backgroundColor:
              isDark ? const Color(0xFF3A2A0A) : AppColors.warningLight,
          borderColor: AppColors.warning,
          iconColor: AppColors.warning,
          textColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        );

      case ResetPasswordStatus.passwordMismatch:
        return MessageBox(
          icon: Icons.error_rounded,
          text: state.message ?? 'Password confirmation does not match.',
          backgroundColor:
              isDark ? const Color(0xFF3A1515) : AppColors.dangerLight,
          borderColor: AppColors.danger,
          iconColor: AppColors.danger,
          textColor: isDark ? AppColors.darkTextPrimary : AppColors.danger,
        );

      case ResetPasswordStatus.success:
        return MessageBox(
          icon: Icons.check_circle_rounded,
          text: state.message ?? 'Password reset successfully.',
          actionText: 'Continue to sign in',
          backgroundColor:
              isDark ? const Color(0xFF12351F) : AppColors.successLight,
          borderColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          actionColor: AppColors.accent,
          onActionTap: () {
            // Navigator.pushReplacementNamed(context, Routes.login);
          },
        );

      case ResetPasswordStatus.initial:
      case ResetPasswordStatus.loading:
        return const SizedBox.shrink();
    }
  }
}

class _ResettingBox extends StatelessWidget {
  const _ResettingBox();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF173D22) : AppColors.accentLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Resetting password...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w900,
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
              Icons.lock_outline_rounded,
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