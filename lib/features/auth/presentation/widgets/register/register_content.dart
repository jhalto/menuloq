import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/route/route_name.dart';
import 'package:menuloq/config/theme/app_colors.dart';
import 'package:menuloq/core/global/brand_word_mark.dart';
import 'package:menuloq/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:menuloq/features/auth/presentation/bloc/register/register_event.dart';
import 'package:menuloq/features/auth/presentation/bloc/register/register_state.dart';

import '../divider_text.dart';
import '../input_label.dart';
import '../loading_button_content.dart';
import 'business_url_field.dart';
import 'mobile_number_field.dart';
import 'register_step_indicator.dart';

class RegisterContent extends StatefulWidget {
  const RegisterContent({super.key, this.showWordmark = true});

  final bool showWordmark;

  @override
  State<RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<RegisterContent> {
  final _businessFormKey = GlobalKey<FormState>();
  final _securityFormKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController();
  final _businessSlugController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessSlugController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _continueToSecurity() {
    FocusScope.of(context).unfocus();

    // if (!(_businessFormKey.currentState?.validate() ?? false)) return;

    context.read<RegisterBloc>().add(
      RegisterBusinessStepSubmitted(
        businessName: _businessNameController.text.trim(),
        businessSlug: _businessSlugController.text.trim().toLowerCase(),
        ownerName: _ownerNameController.text.trim(),
        email: _emailController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
      ),
    );
  }

  void _createAccount() {
    FocusScope.of(context).unfocus();

    // if (!(_securityFormKey.currentState?.validate() ?? false)) return;

    // context.read<RegisterBloc>().add(
    //   RegisterSubmitted(password: _passwordController.text),
    // );
    Navigator.pushNamed(context, Routes.veriflyEmail, arguments:  _emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.status == RegisterStatus.success) {
          // Navigator.pushReplacementNamed(context, Routes.dashboard);
        }
      },
      builder: (context, state) {
        final isLoading = state.status == RegisterStatus.loading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showWordmark) ...[
              const BrandWordmark(),
              const SizedBox(height: 34),
            ],
            const _RegisterHeader(),
            const SizedBox(height: 34),
            RegisterStepIndicator(currentStep: state.step),
            const SizedBox(height: 38),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: state.step == RegisterStep.business
                  ? _BusinessStepForm(
                      key: const ValueKey('business-step'),
                      formKey: _businessFormKey,
                      isLoading: isLoading,
                      businessNameController: _businessNameController,
                      businessSlugController: _businessSlugController,
                      ownerNameController: _ownerNameController,
                      emailController: _emailController,
                      mobileController: _mobileController,
                      onContinue: _continueToSecurity,
                    )
                  : _SecurityStepForm(
                      key: const ValueKey('security-step'),
                      formKey: _securityFormKey,
                      isLoading: isLoading,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      obscurePassword: _obscurePassword,
                      obscureConfirmPassword: _obscureConfirmPassword,
                      onPasswordVisibilityTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      onConfirmVisibilityTap: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      onSubmit: _createAccount,
                      passwordValidator: _passwordValidator,
                      confirmPasswordValidator: _confirmPasswordValidator,
                    ),
            ),
            if (state.message != null) ...[
              const SizedBox(height: 14),
              _ErrorBox(message: state.message!),
            ],
            const SizedBox(height: 26),
            const DividerText(text: ''),
            const SizedBox(height: 18),
            _SignInFooter(
              onTap: isLoading
                  ? null
                  : () {
                      // Navigator.pushReplacementNamed(context, Routes.login);
                    },
            ),
          ],
        );
      },
    );
  }

  String? _passwordValidator(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter your password.';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      return 'Password must include at least one letter.';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must include at least one number.';
    }

    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Password must include at least one symbol.';
    }

    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please confirm your password.';
    }

    if (confirmPassword != _passwordController.text) {
      return 'Password and confirm password do not match.';
    }

    return null;
  }
}

class _BusinessStepForm extends StatelessWidget {
  const _BusinessStepForm({
    super.key,
    required this.formKey,
    required this.isLoading,
    required this.businessNameController,
    required this.businessSlugController,
    required this.ownerNameController,
    required this.emailController,
    required this.mobileController,
    required this.onContinue,
  });

  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final TextEditingController businessNameController;
  final TextEditingController businessSlugController;
  final TextEditingController ownerNameController;
  final TextEditingController emailController;
  final TextEditingController mobileController;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const InputLabel(text: 'Business name'),
          const SizedBox(height: 8),
          TextFormField(
            controller: businessNameController,
            enabled: !isLoading,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Enter your business name',
              prefixIcon: Icon(Icons.storefront_outlined),
            ),
            validator: _requiredValidator('Please enter your business name.'),
          ),
          const SizedBox(height: 18),
          const InputLabel(text: 'Business URL'),
          const SizedBox(height: 8),
          BusinessUrlField(
            controller: businessSlugController,
            enabled: !isLoading,
            validator: _businessSlugValidator,
          ),
          const SizedBox(height: 18),
          const InputLabel(text: 'Owner name'),
          const SizedBox(height: 8),
          TextFormField(
            controller: ownerNameController,
            enabled: !isLoading,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Enter owner full name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: _requiredValidator('Please enter owner name.'),
          ),
          const SizedBox(height: 18),
          const InputLabel(text: 'Email address'),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Enter your email address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: _emailValidator,
          ),
          const SizedBox(height: 18),
          const InputLabel(text: 'Mobile number'),
          const SizedBox(height: 8),
          MobileNumberField(
            controller: mobileController,
            enabled: !isLoading,
            validator: _mobileValidator,
            onCountryChanged: (country) {
              // Save this in local state or Bloc if needed.
              // country.phoneCode = 880
              // country.countryCode = BD
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : onContinue,
              child: const Text('Continue'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Password setup comes next',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static FormFieldValidator<String> _requiredValidator(String message) {
    return (value) {
      if ((value ?? '').trim().isEmpty) return message;
      return null;
    };
  }

  static String? _businessSlugValidator(String? value) {
    final slug = (value ?? '').trim().toLowerCase();

    if (slug.isEmpty) {
      return 'Please enter your business URL.';
    }

    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(slug)) {
      return 'Use lowercase letters, numbers, and hyphen only.';
    }

    return null;
  }

  static String? _emailValidator(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) {
      return 'Please enter your email address.';
    }

    final isValid = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

    if (!isValid) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  static String? _mobileValidator(String? value) {
    final mobile = (value ?? '').trim();

    if (mobile.isEmpty) {
      return 'Please enter your mobile number.';
    }

    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(mobile)) {
      return 'Please enter a valid mobile number.';
    }

    return null;
  }
}

class _SecurityStepForm extends StatelessWidget {
  const _SecurityStepForm({
    super.key,
    required this.formKey,
    required this.isLoading,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onPasswordVisibilityTap,
    required this.onConfirmVisibilityTap,
    required this.onSubmit,
    required this.passwordValidator,
    required this.confirmPasswordValidator,
  });

  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onPasswordVisibilityTap;
  final VoidCallback onConfirmVisibilityTap;
  final VoidCallback onSubmit;
  final FormFieldValidator<String> passwordValidator;
  final FormFieldValidator<String> confirmPasswordValidator;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const InputLabel(text: 'Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: passwordController,
            enabled: !isLoading,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: isLoading ? null : onPasswordVisibilityTap,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: passwordValidator,
          ),
          const SizedBox(height: 18),
          const InputLabel(text: 'Confirm password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: confirmPasswordController,
            enabled: !isLoading,
            obscureText: obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Confirm your password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: isLoading ? null : onConfirmVisibilityTap,
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: confirmPasswordValidator,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 18),
          Text(
            'Use at least 8 characters, including a letter, a number, and a symbol.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 34),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              child: isLoading
                  ? const LoadingButtonContent()
                  : const Text('Create account'),
            ),
          ),
        ],
      ),
    );
  }
}



class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Create your account',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start managing your business in minutes.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SignInFooter extends StatelessWidget {
  const _SignInFooter({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(onPressed: onTap, child: const Text('Sign in')),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
