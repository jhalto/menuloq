import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/route/route_name.dart';
import 'package:menuloq/config/theme/app_colors.dart';
import 'package:menuloq/core/global/brand_word_mark.dart';
import 'package:menuloq/core/global/app_toast.dart';
import 'package:menuloq/core/helper/go_url_helper.dart';
import 'package:menuloq/core/widgets/mobile_number_form_field.dart';
import 'package:menuloq/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:menuloq/features/auth/presentation/bloc/register/register_event.dart';
import 'package:menuloq/features/auth/presentation/bloc/register/register_state.dart';

import '../divider_text.dart';
import '../input_label.dart';
import '../loading_button_content.dart';
import 'business_domain_field.dart';
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
  final _businessDomainController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _businessAddressController = TextEditingController();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _mobileFocusNode = FocusNode();
  final _businessAddressFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = false;
  String _countryCode = '+880';
  String _countryIsoCode = 'BD';
  RegisterStep _lastStep = RegisterStep.business;

  String _buildFullMobileNumber() {
    return MobileNumberFormField.toInternationalNumber(
      localNumber: _mobileController.text,
      dialCode: _countryCode,
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessDomainController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _businessAddressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _mobileFocusNode.dispose();
    _businessAddressFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _continueToSecurity() {
    FocusScope.of(context).unfocus();

    if (!(_businessFormKey.currentState?.validate() ?? false)) return;

    context.read<RegisterBloc>().add(
      RegisterBusinessStepSubmitted(
        businessName: _businessNameController.text.trim(),
        subdomain: _businessDomainController.text.trim().toLowerCase(),
        ownerName: _ownerNameController.text.trim(),
        email: _emailController.text.trim(),
        mobileNumber: _buildFullMobileNumber(),
        businessAddress: _businessAddressController.text.trim(),
      ),
    );
  }

  void _onBusinessFieldChanged() {
    final bloc = context.read<RegisterBloc>();
    final state = bloc.state;
    final hasServerError =
        state.emailError != null ||
        state.subdomainError != null ||
        state.mobileError != null ||
        state.businessAddressError != null ||
        state.message != null;

    bloc.add(const RegisterBusinessFieldsChanged());
    if (!hasServerError) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _businessFormKey.currentState?.validate();
    });
  }

  void _createAccount() {
    FocusScope.of(context).unfocus();

    if (!(_securityFormKey.currentState?.validate() ?? false)) return;

    final state = context.read<RegisterBloc>().state;
    final businessName = state.businessName.trim().isNotEmpty
        ? state.businessName
        : _businessNameController.text.trim();
    final userName = state.subdomain.trim().isNotEmpty
        ? state.subdomain
        : _businessDomainController.text.trim().toLowerCase();
    final ownerName = state.ownerName.trim().isNotEmpty
        ? state.ownerName
        : _ownerNameController.text.trim();
    final email = state.email.trim().isNotEmpty
        ? state.email
        : _emailController.text.trim();
    final mobileNumber = state.mobileNumber.trim().isNotEmpty
        ? state.mobileNumber
        : _buildFullMobileNumber();
    final businessAddress = state.businessAddress.trim().isNotEmpty
        ? state.businessAddress
        : _businessAddressController.text.trim();

    context.read<RegisterBloc>().add(
      RegisterSubmitted(
        businessName: businessName,
        userName: userName,
        ownerName: ownerName,
        email: email,
        mobileNumber: mobileNumber,
        businessAddress: businessAddress,
        termsAccepted: _termsAccepted,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        final movedToSecurity =
            _lastStep != RegisterStep.security &&
            state.step == RegisterStep.security;
        _lastStep = state.step;

        if (movedToSecurity) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _passwordFocusNode.requestFocus();
          });
        }

        if (state.status == RegisterStatus.failure) {
          if (state.message != null) {
            AppToast.error(context, message: state.message!);
          }

          if (state.step == RegisterStep.business) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _businessFormKey.currentState?.validate();
            });
          }
        }

        if (state.status == RegisterStatus.success) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.verifyEmail,
            (route) => false,
            arguments: state.email,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == RegisterStatus.loading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showWordmark) ...[const BrandWordmark()],
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
                      businessDomainController: _businessDomainController,
                      ownerNameController: _ownerNameController,
                      emailController: _emailController,
                      mobileController: _mobileController,
                      businessAddressController: _businessAddressController,
                      mobileFocusNode: _mobileFocusNode,
                      businessAddressFocusNode: _businessAddressFocusNode,
                      emailError: state.emailError,
                      subdomainError: state.subdomainError,
                      mobileError: state.mobileError,
                      businessAddressError: state.businessAddressError,
                      countryIsoCode: _countryIsoCode,
                      onMobileChanged: (value) {
                        _countryCode = value.dialCode;
                        _countryIsoCode = value.countryCode;
                        _onBusinessFieldChanged();
                      },
                      onChanged: _onBusinessFieldChanged,
                      onContinue: _continueToSecurity,
                    )
                  : _SecurityStepForm(
                      key: const ValueKey('security-step'),
                      formKey: _securityFormKey,
                      isLoading: isLoading,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      passwordFocusNode: _passwordFocusNode,
                      confirmPasswordFocusNode: _confirmPasswordFocusNode,
                      obscurePassword: _obscurePassword,
                      obscureConfirmPassword: _obscureConfirmPassword,
                      termsAccepted: _termsAccepted,
                      onBack: () {
                        context.read<RegisterBloc>().add(
                          const RegisterBackToBusinessRequested(),
                        );
                      },
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
                      onTermsChanged: (value) {
                        setState(() {
                          _termsAccepted = value;
                        });
                      },
                      onTermsTap: () async {
                        final opened = await GoUrlHelper.open(
                          'https://menuloq.com/terms-and-conditions',
                        );

                        if (!opened && context.mounted) {
                          AppToast.error(
                            context,
                            message: 'Could not open Terms & Conditions.',
                          );
                        }
                      },
                      onSubmit: _createAccount,
                      passwordValidator: _passwordValidator,
                      confirmPasswordValidator: _confirmPasswordValidator,
                    ),
            ),
            const SizedBox(height: 20),
            const DividerText(text: ''),
            _SignInFooter(
              onTap: isLoading
                  ? null
                  : () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Routes.login,
                        (route) => false,
                      );
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
    required this.businessDomainController,
    required this.ownerNameController,
    required this.emailController,
    required this.mobileController,
    required this.businessAddressController,
    required this.mobileFocusNode,
    required this.businessAddressFocusNode,
    required this.countryIsoCode,
    required this.onMobileChanged,
    required this.onChanged,
    required this.onContinue,
    required this.emailError,
    required this.subdomainError,
    required this.mobileError,
    required this.businessAddressError,
  });

  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final TextEditingController businessNameController;
  final TextEditingController businessDomainController;
  final TextEditingController ownerNameController;
  final TextEditingController emailController;
  final TextEditingController mobileController;
  final TextEditingController businessAddressController;
  final FocusNode mobileFocusNode;
  final FocusNode businessAddressFocusNode;
  final VoidCallback onContinue;
  final VoidCallback onChanged;
  final String countryIsoCode;
  final ValueChanged<MobileNumberValue> onMobileChanged;
  final String? emailError;
  final String? subdomainError;
  final String? mobileError;
  final String? businessAddressError;

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
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 18),
          const InputLabel(text: 'Subdomain'),
          const SizedBox(height: 8),
          BusinessDomainField(
            controller: businessDomainController,
            enabled: !isLoading,
            validator: (value) =>
                _businessDomainValidator(value, apiError: subdomainError),
            onChanged: (_) => onChanged(),
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
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 18),
          const InputLabel(text: 'Business Email'),
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
            validator: (value) => _emailValidator(value, apiError: emailError),
            onChanged: (_) => onChanged(),
            onFieldSubmitted: (_) {
              mobileFocusNode.requestFocus();
            },
          ),
          const SizedBox(height: 18),
          const InputLabel(text: 'Mobile number'),
          const SizedBox(height: 8),
          MobileNumberFormField(
            controller: mobileController,
            focusNode: mobileFocusNode,
            enabled: !isLoading,
            initialCountryCode: countryIsoCode,
            textInputAction: TextInputAction.next,
            validator: (value) =>
                _mobileValidator(
                  value,
                  countryIsoCode: countryIsoCode,
                  apiError: mobileError,
                ),
            onChanged: (value) {
              onMobileChanged(value);
            },
            onFieldSubmitted: (_) {
              businessAddressFocusNode.requestFocus();
            },
          ),
          const SizedBox(height: 18),
          const InputLabel(text: 'Business address'),
          const SizedBox(height: 8),
          TextFormField(
            controller: businessAddressController,
            focusNode: businessAddressFocusNode,
            enabled: !isLoading,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Enter business address',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            validator: (value) =>
                _requiredValidator(
                  'Please enter business address.',
                  apiError: businessAddressError,
                )(value),
            onChanged: (_) => onChanged(),
            onFieldSubmitted: (_) => onContinue(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : onContinue,
              child: isLoading
                  ? const LoadingButtonContent()
                  : const Text('Continue'),
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

  static FormFieldValidator<String> _requiredValidator(
    String message, {
    String? apiError,
  }) {
    return (value) {
      if ((value ?? '').trim().isEmpty) return message;
      return apiError;
    };
  }

  static String? _businessDomainValidator(String? value, {String? apiError}) {
    final slug = (value ?? '').trim().toLowerCase();

    if (slug.isEmpty) {
      return 'Please enter your business URL.';
    }

    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(slug)) {
      return 'Use lowercase letters, numbers, and hyphen only.';
    }

    return apiError;
  }

  static String? _emailValidator(String? value, {String? apiError}) {
    final email = (value ?? '').trim();

    if (email.isEmpty) {
      return 'Please enter your email address.';
    }

    final isValid = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);

    if (!isValid) {
      return 'Please enter a valid email address.';
    }

    return apiError;
  }

  static String? _mobileValidator(
    String? value, {
    required String countryIsoCode,
    String? apiError,
  }) {
    return MobileNumberFormField.validateForCountryCode(
      value: value ?? '',
      countryCode: countryIsoCode,
      apiError: apiError,
    );
  }
}

class _SecurityStepForm extends StatelessWidget {
  const _SecurityStepForm({
    super.key,
    required this.formKey,
    required this.isLoading,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.termsAccepted,
    required this.onBack,
    required this.onPasswordVisibilityTap,
    required this.onConfirmVisibilityTap,
    required this.onTermsChanged,
    required this.onTermsTap,
    required this.onSubmit,
    required this.passwordValidator,
    required this.confirmPasswordValidator,
  });

  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool termsAccepted;
  final VoidCallback onBack;
  final VoidCallback onPasswordVisibilityTap;
  final VoidCallback onConfirmVisibilityTap;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onTermsTap;
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
            focusNode: passwordFocusNode,
            enabled: !isLoading,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: ExcludeFocus(
                child: IconButton(
                  onPressed: isLoading ? null : onPasswordVisibilityTap,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            validator: passwordValidator,
            onFieldSubmitted: (_) {
              confirmPasswordFocusNode.requestFocus();
            },
          ),
          const SizedBox(height: 18),
          const InputLabel(text: 'Confirm password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocusNode,
            enabled: !isLoading,
            obscureText: obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Confirm your password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: ExcludeFocus(
                child: IconButton(
                  onPressed: isLoading ? null : onConfirmVisibilityTap,
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            validator: confirmPasswordValidator,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 18),
          Text(
            'Use at least 8 characters.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          FormField<bool>(
            initialValue: termsAccepted,
            validator: (_) {
              if (!termsAccepted) {
                return 'Please accept the Terms & Conditions to create your account.';
              }

              return null;
            },
            builder: (field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: termsAccepted,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    final nextValue = value ?? false;
                                    onTermsChanged(nextValue);
                                    field.didChange(nextValue);
                                  },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: isLoading
                              ? null
                              : () {
                                  final nextValue = !termsAccepted;
                                  onTermsChanged(nextValue);
                                  field.didChange(nextValue);
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Wrap(
                              spacing: 2,
                              runSpacing: 2,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  'I accept the ',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                        height: 1.35,
                                      ),
                                ),
                                TextButton(
                                  onPressed: isLoading ? null : onTermsTap,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          height: 1.35,
                                        ),
                                  ),
                                  child: const Text('Terms & Conditions'),
                                ),
                                Text(
                                  '.',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                        height: 1.35,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (field.errorText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      field.errorText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 34),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSubmit,
                    child: isLoading
                        ? const LoadingButtonContent()
                        : const Text('Create account'),
                  ),
                ),
              ),
            ],
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark
        ? AppColors.white.withAlpha(235)
        : AppColors.textPrimary;

    final subtitleColor = isDark
        ? AppColors.white.withAlpha(170)
        : AppColors.textSecondary;

    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          'Create Business account',
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start managing your business in minutes.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: subtitleColor,
            fontWeight: FontWeight.w500,
          ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: isDark ? AppColors.darkPrimary : AppColors.accent,
            textStyle: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          child: const Text('Sign in'),
        ),
      ],
    );
  }
}

