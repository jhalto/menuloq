import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/route/route_name.dart';
import 'package:menuloq/core/global/app_toast.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../bloc/login/auth_bloc.dart';
import '../../bloc/login/auth_event.dart';
import '../../bloc/login/auth_state.dart';
import '../brand_logo.dart';
import '../divider_text.dart';
import '../input_label.dart';
import '../loading_button_content.dart';

class LoginContent extends StatefulWidget {
  const LoginContent({
    super.key,
    this.showLogo = true,
  });

  final bool showLogo;

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
          LoginSubmitted(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if ((state.status == AuthStatus.failure ||
                state.status == AuthStatus.inactive) &&
            state.message != null) {
          AppToast.error(context, message: state.message!);
        }

        if (state.status == AuthStatus.success) {
          Navigator.pushReplacementNamed(context, Routes.dashboard);
        }

        if (state.status == AuthStatus.emailNotVerified &&
            state.email != null) {
          Navigator.pushNamed(
            context,
            Routes.verifyEmail,
            arguments: state.email,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final createAccountForeground = isDark
            ? AppColors.darkAccent
            : AppColors.accent;
        final createAccountBackground = isDark
            ? AppColors.darkAccentLight
            : AppColors.accentLight;
        final createAccountBorder = isDark
            ? AppColors.darkAccent.withAlpha(120)
            : AppColors.accent.withAlpha(110);

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showLogo) ...[
                const BrandLogo(),
                const SizedBox(height: 20),
              ],
              _HeaderSection(),
              const SizedBox(height: 24),
              const InputLabel(text: 'Email address'),
              const SizedBox(height: 4),
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: _emailValidator,
                onFieldSubmitted: (_) {
                  _passwordFocusNode.requestFocus();
                },
              ),
              const SizedBox(height: 10),
              const InputLabel(text: 'Password'),
              const SizedBox(height: 4),
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                enabled: !isLoading,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  hintText: 'Enter your password',
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
                onFieldSubmitted: (_) => _submit(),
              ),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pushNamed(context, Routes.forgotPassword);
                        },
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const LoadingButtonContent()
                      : const Text('Sign in'),
                ),
              ),
              const SizedBox(height: 16),
              const DividerText(text: 'New to MenuLoq?'),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: createAccountBackground,
                    foregroundColor: createAccountForeground,
                    disabledBackgroundColor:
                        createAccountBackground.withAlpha(90),
                    disabledForegroundColor:
                        createAccountForeground.withAlpha(120),
                    side: BorderSide(color: createAccountBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pushNamed(context, Routes.register);
                        },
                  child: const Text('Create an account'),
                ),
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

  String? _passwordValidator(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter your password.';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to manage your business.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
