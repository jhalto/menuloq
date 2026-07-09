import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/route/route_name.dart';
import 'package:menuloq/config/theme/app_colors.dart';
import 'package:menuloq/core/global/app_toast.dart';
import 'package:menuloq/core/helper/phone_number_helper.dart';
import 'package:menuloq/core/widgets/mobile_number_form_field.dart';
import 'package:menuloq/features/account/domain/entities/my_account_entitry.dart';
import 'package:menuloq/features/account/domain/params/update_my_account_params.dart';

import '../bloc/my_account_bloc.dart';
import '../bloc/my_account_event.dart';
import '../bloc/my_account_state.dart';

class MyAccountView extends StatefulWidget {
  const MyAccountView({super.key, this.onChangePassword});

  final VoidCallback? onChangePassword;

  @override
  State<MyAccountView> createState() => _MyAccountViewState();
}

class _MyAccountViewState extends State<MyAccountView> {
  static const double _tabletBreakpoint = 720;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();

  String _countryIsoCode = 'BD';

  MyAccountEntity? _loadedAccount;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final account = context.read<MyAccountBloc>().state.account;

    if (_loadedAccount == null && account != null) {
      _fillForm(account);
    }
  }

  void _fillForm(MyAccountEntity account) {
    final parsedPhone = PhoneNumberHelper.parse(account.user.mobileNumber);

    _loadedAccount = account;
    _nameController.text = account.user.name;
    _emailController.text = account.user.email;
    _mobileController.text = parsedPhone.localNumber;
    _addressController.text = account.user.address ?? '';
    _countryIsoCode = parsedPhone.isoCode;
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final country = MobileNumberFormField.countryFromCode(_countryIsoCode);
    final internationalMobileNumber =
        MobileNumberFormField.toInternationalNumber(
      localNumber: _mobileController.text.trim(),
      dialCode: '+${country.phoneCode}',
    );

    context.read<MyAccountBloc>().add(
      MyAccountSaveRequested(
        params: UpdateMyAccountParams(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          mobileNumber: internationalMobileNumber,
          address: _addressController.text.trim(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyAccountBloc, MyAccountState>(
      listenWhen: (previous, current) =>
          previous.account != current.account ||
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        final account = state.account;

        if (account != null && account != _loadedAccount) {
          setState(() {
            _fillForm(account);
          });
        }

        if (state.errorMessage != null && state.fieldErrors.isEmpty) {
          AppToast.error(context, message: state.errorMessage!);
        }

        if (state.successMessage != null) {
          AppToast.success(context, message: state.successMessage!);
          context.read<MyAccountBloc>().add(
            const MyAccountMessageDismissed(),
          );
        }
      },
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.account != current.account ||
          previous.fieldErrors != current.fieldErrors,
      builder: (context, state) {
        if (state.isLoading && !state.hasAccount) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!state.hasAccount) {
          return _AccountErrorView(
            message: state.errorMessage ?? 'Failed to load account.',
            onRetry: () {
              context.read<MyAccountBloc>().add(
                const MyAccountRefreshRequested(),
              );
            },
          );
        }

        final account = state.account!;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth >= _tabletBreakpoint;

                return CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(
                      child: _AccountHeader(
                        canGoBack: Navigator.of(context).canPop(),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 32 : 16,
                        8,
                        isTablet ? 32 : 16,
                        32,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1080),
                            child: Column(
                              children: [
                                if (isTablet)
                                  _TabletAccountLayout(
                                    account: account,
                                    form: _buildForm(state),
                                    passwordAction: _changePassword,
                                  )
                                else
                                  _MobileAccountLayout(
                                    account: account,
                                    form: _buildForm(state),
                                    passwordAction: _changePassword,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(MyAccountState state) {
    return Column(
      children: [
        _AccountFormCard(
          formKey: _formKey,
          nameController: _nameController,
          emailController: _emailController,
          mobileController: _mobileController,
          addressController: _addressController,
          countryIsoCode: _countryIsoCode,
          enabled: !state.isSaving,
          fieldErrors: state.fieldErrors,
          onMobileChanged: (value) {
            if (_countryIsoCode == value.countryCode) return;

            setState(() {
              _countryIsoCode = value.countryCode;
            });
          },
        ),
        const SizedBox(height: 20),
        _SaveAccountButton(isSaving: state.isSaving, onPressed: _submit),
      ],
    );
  }

  void _changePassword() {
    final customAction = widget.onChangePassword;

    if (customAction != null) {
      customAction();
      return;
    }

    Navigator.pushNamed(context, Routes.changePassword);
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.canGoBack});

  final bool canGoBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Text(
                'My Account',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Manage your personal information',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (canGoBack)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 30),
              ),
            ),
        ],
      ),
    );
  }
}

class _MobileAccountLayout extends StatelessWidget {
  const _MobileAccountLayout({
    required this.account,
    required this.form,
    required this.passwordAction,
  });

  final MyAccountEntity account;
  final Widget form;
  final VoidCallback? passwordAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AccountIdentity(account: account),
        const SizedBox(height: 18),
        _BusinessSummaryCard(business: account.business),
        const SizedBox(height: 18),
        form,
        const SizedBox(height: 18),
        _DesignationCard(
          designation: account.user.designation,
          accountType: account.user.type,
        ),
        const SizedBox(height: 18),
        _PasswordCard(onPressed: passwordAction),
      ],
    );
  }
}

class _TabletAccountLayout extends StatelessWidget {
  const _TabletAccountLayout({
    required this.account,
    required this.form,
    required this.passwordAction,
  });

  final MyAccountEntity account;
  final Widget form;
  final VoidCallback? passwordAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _AccountIdentity(account: account),
              const SizedBox(height: 20),
              _BusinessSummaryCard(business: account.business),
              const SizedBox(height: 20),
              _DesignationCard(
                designation: account.user.designation,
                accountType: account.user.type,
              ),
              const SizedBox(height: 20),
              _PasswordCard(onPressed: passwordAction),
            ],
          ),
        ),
        const SizedBox(width: 26),
        Expanded(flex: 6, child: form),
      ],
    );
  }
}

class _AccountIdentity extends StatelessWidget {
  const _AccountIdentity({required this.account});

  final MyAccountEntity account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _AccountAvatar(account: account),
        const SizedBox(height: 12),
        Text(
          account.user.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          account.user.email,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.account});

  final MyAccountEntity account;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF063D43), Color(0xFF001D22)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _AvatarInitials(initials: account.user.initials),
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  const _AvatarInitials({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BusinessSummaryCard extends StatelessWidget {
  const _BusinessSummaryCard({required this.business});

  final AccountBusinessEntity business;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _AccountCard(
      child: Row(
        children: [
          _BusinessLogo(business: business),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business.businessName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  business.websiteUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 17,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Text(
                  'Read-only',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessLogo extends StatelessWidget {
  const _BusinessLogo({required this.business});

  final AccountBusinessEntity business;

  @override
  Widget build(BuildContext context) {
    final logoUrl = business.logoUrl;

    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoUrl != null && logoUrl.trim().isNotEmpty
          ? Image.network(
              logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(Icons.restaurant_menu_rounded, size: 34);
              },
            )
          : const Icon(Icons.restaurant_menu_rounded, size: 34),
    );
  }
}

class _AccountFormCard extends StatelessWidget {
  const _AccountFormCard({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.mobileController,
    required this.addressController,
    required this.countryIsoCode,
    required this.enabled,
    required this.fieldErrors,
    required this.onMobileChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController mobileController;
  final TextEditingController addressController;
  final String countryIsoCode;
  final bool enabled;
  final Map<String, String> fieldErrors;
  final ValueChanged<MobileNumberValue> onMobileChanged;

  @override
  Widget build(BuildContext context) {
    return _AccountCard(
      padding: const EdgeInsets.all(18),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _AccountTextField(
              label: 'Full name',
              controller: nameController,
              enabled: enabled,
              icon: Icons.person_outline_rounded,
              hintText: 'Enter your full name',
              serverError: fieldErrors['name'] ?? fieldErrors['full_name'],
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Please enter your full name.';
                }

                return null;
              },
            ),
            const SizedBox(height: 18),
            _AccountTextField(
              label: 'Email address',
              controller: emailController,
              enabled: enabled,
              icon: Icons.email_outlined,
              hintText: 'Enter your email address',
              keyboardType: TextInputType.emailAddress,
              serverError: fieldErrors['email'],
              validator: _validateEmail,
            ),
            const SizedBox(height: 18),
            _PhoneNumberField(
              enabled: enabled,
              controller: mobileController,
              countryIsoCode: countryIsoCode,
              serverError: fieldErrors['mobile_number'] ?? fieldErrors['phone'],
              onChanged: onMobileChanged,
            ),
            const SizedBox(height: 18),
            _AccountTextField(
              label: 'Address',
              controller: addressController,
              enabled: enabled,
              icon: Icons.location_on_outlined,
              hintText: 'Enter your address',
              keyboardType: TextInputType.streetAddress,
              maxLines: 3,
              serverError: fieldErrors['address'],
            ),
          ],
        ),
      ),
    );
  }

  static String? _validateEmail(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) {
      return 'Please enter your email address.';
    }

    final valid = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);

    if (!valid) {
      return 'Please enter a valid email address.';
    }

    return null;
  }
}

class _AccountTextField extends StatelessWidget {
  const _AccountTextField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hintText,
    this.enabled = true,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.serverError,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final bool enabled;
  final TextInputType? keyboardType;
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final String? serverError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasServerError =
        serverError != null && serverError!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          readOnly: !enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textInputAction: maxLines > 1
              ? TextInputAction.newline
              : TextInputAction.next,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon),
          ),
        ),
        if (hasServerError) ...[
          const SizedBox(height: 8),
          _InlineErrorMessage(message: serverError!),
        ],
      ],
    );
  }
}

class _PhoneNumberField extends StatelessWidget {
  const _PhoneNumberField({
    required this.enabled,
    required this.controller,
    required this.countryIsoCode,
    required this.onChanged,
    this.serverError,
  });

  final bool enabled;
  final TextEditingController controller;
  final String countryIsoCode;
  final ValueChanged<MobileNumberValue> onChanged;
  final String? serverError;

  @override
  Widget build(BuildContext context) {
    final hasServerError =
        serverError != null && serverError!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Mobile number'),
        const SizedBox(height: 7),
        MobileNumberFormField(
          controller: controller,
          enabled: enabled,
          initialCountryCode: countryIsoCode,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              MobileNumberFormField.validateForCountryCode(
            value: value ?? '',
            countryCode: countryIsoCode,
          ),
          onChanged: onChanged,
        ),
        if (hasServerError) ...[
          const SizedBox(height: 8),
          _InlineErrorMessage(message: serverError!),
        ],
      ],
    );
  }
}

class _DesignationCard extends StatelessWidget {
  const _DesignationCard({
    required this.designation,
    required this.accountType,
  });

  final String designation;
  final String accountType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _AccountCard(
      child: Row(
        children: [
          Icon(Icons.badge_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Designation',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // if (accountType.trim().isNotEmpty) ...[
                //   const SizedBox(height: 3),
                //   Text(
                //     accountType,
                //     style: theme.textTheme.bodySmall?.copyWith(
                //       color: theme.colorScheme.onSurfaceVariant,
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                // ],
              ],
            ),
          ),
          Text(
            designation.trim().isEmpty ? 'Not assigned' : designation,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordCard extends StatelessWidget {
  const _PasswordCard({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _AccountCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Update your account password securely.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: onPressed,
            child: const Text('Change password'),
          ),
        ],
      ),
    );
  }
}

class _SaveAccountButton extends StatelessWidget {
  const _SaveAccountButton({required this.isSaving, required this.onPressed});

  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savingColor = theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: isSaving
            ? null
            : const LinearGradient(
                colors: [Color(0xFF61C500), Color(0xFF43A900)],
              ),
        border: isSaving
            ? Border.all(color: Theme.of(context).colorScheme.outline)
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : onPressed,
        icon: isSaving
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color: savingColor,
                ),
              )
            : const Icon(Icons.save_outlined),
        label: Text(isSaving ? 'Saving...' : 'Save changes'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          disabledForegroundColor: savingColor,
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _InlineErrorMessage extends StatelessWidget {
  const _InlineErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(40)
                : Colors.black.withAlpha(12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _AccountErrorView extends StatelessWidget {
  const _AccountErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 14),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
