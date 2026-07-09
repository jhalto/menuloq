import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/theme/app_colors.dart';
import 'package:menuloq/core/global/app_toast.dart';
import 'package:menuloq/core/global/brand_word_mark.dart';
import 'package:menuloq/features/account/presentation/bloc/change_password/change_password_bloc.dart';
import 'package:menuloq/features/account/presentation/bloc/change_password/change_password_event.dart';
import 'package:menuloq/features/account/presentation/bloc/change_password/change_password_state.dart';
import 'package:menuloq/features/auth/presentation/widgets/input_label.dart';
import 'package:menuloq/features/auth/presentation/widgets/loading_button_content.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  static const double _tabletBreakpoint = 720;

  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _currentPasswordFocusNode = FocusNode();
  final _newPasswordFocusNode = FocusNode();
  final _confirmationFocusNode = FocusNode();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _currentPasswordFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmationController.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmationFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<ChangePasswordBloc>().add(
          ChangePasswordSubmitted(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
            newPasswordConfirmation: _confirmationController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= _tabletBreakpoint;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 40 : 20,
                vertical: isTablet ? 40 : 16,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding: EdgeInsets.all(isTablet ? 34 : 20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkCardBorder
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: _buildForm(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.message != current.message,
      listener: (context, state) {
        if (state.status == ChangePasswordStatus.failure &&
            state.message != null) {
          AppToast.error(context, message: state.message!);
        }

        if (state.status == ChangePasswordStatus.success) {
          AppToast.success(
            context,
            message: state.message ?? 'Password changed successfully.',
          );
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final isLoading = state.status == ChangePasswordStatus.loading;
        final titleColor =
            isDark ? AppColors.darkTextPrimary : AppColors.primary;
        final subtitleColor =
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed:
                        isLoading ? null : () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_rounded, color: titleColor),
                  ),
                  const Expanded(child: BrandWordmark(fontSize: 24)),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),
              Icon(
                Icons.password_rounded,
                size: 52,
                color: isDark ? AppColors.darkAccent : AppColors.accent,
              ),
              const SizedBox(height: 18),
              Text(
                'Change password',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your current password, then choose a secure new one.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: subtitleColor,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 30),
              const InputLabel(text: 'Current password', isRequired: true),
              const SizedBox(height: 8),
              _PasswordField(
                controller: _currentPasswordController,
                focusNode: _currentPasswordFocusNode,
                enabled: !isLoading,
                obscureText: _obscureCurrentPassword,
                hintText: 'Enter current password',
                textInputAction: TextInputAction.next,
                onVisibilityTap: () {
                  setState(() {
                    _obscureCurrentPassword = !_obscureCurrentPassword;
                  });
                },
                validator: _currentPasswordValidator,
                onFieldSubmitted: (_) => _newPasswordFocusNode.requestFocus(),
              ),
              const SizedBox(height: 18),
              const InputLabel(text: 'New password', isRequired: true),
              const SizedBox(height: 8),
              _PasswordField(
                controller: _newPasswordController,
                focusNode: _newPasswordFocusNode,
                enabled: !isLoading,
                obscureText: _obscureNewPassword,
                hintText: 'Enter new password',
                textInputAction: TextInputAction.next,
                onVisibilityTap: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
                validator: _newPasswordValidator,
                onFieldSubmitted: (_) => _confirmationFocusNode.requestFocus(),
              ),
              const SizedBox(height: 18),
              const InputLabel(text: 'Confirm new password', isRequired: true),
              const SizedBox(height: 8),
              _PasswordField(
                controller: _confirmationController,
                focusNode: _confirmationFocusNode,
                enabled: !isLoading,
                obscureText: _obscureConfirmation,
                hintText: 'Re-enter new password',
                textInputAction: TextInputAction.done,
                onVisibilityTap: () {
                  setState(() {
                    _obscureConfirmation = !_obscureConfirmation;
                  });
                },
                validator: _confirmationValidator,
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
              const SizedBox(height: 28),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const LoadingButtonContent(
                          label: 'Changing password...',
                        )
                      : const Text('Change password'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _currentPasswordValidator(String? value) {
    if ((value ?? '').isEmpty) return 'Please enter your current password.';
    return null;
  }

  String? _newPasswordValidator(String? value) {
    final password = value ?? '';

    if (password.isEmpty) return 'Please enter your new password.';
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (password == _currentPasswordController.text) {
      return 'New password must be different from the current password.';
    }

    return null;
  }

  String? _confirmationValidator(String? value) {
    final confirmation = value ?? '';

    if (confirmation.isEmpty) return 'Please confirm your new password.';
    if (confirmation != _newPasswordController.text) {
      return 'Password confirmation does not match.';
    }

    return null;
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.obscureText,
    required this.hintText,
    required this.textInputAction,
    required this.onVisibilityTap,
    required this.validator,
    required this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final bool obscureText;
  final String hintText;
  final TextInputAction textInputAction;
  final VoidCallback onVisibilityTap;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: ExcludeFocus(
          child: IconButton(
            tooltip: obscureText ? 'Show password' : 'Hide password',
            onPressed: enabled ? onVisibilityTap : null,
            icon: Icon(
              obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
      ),
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
