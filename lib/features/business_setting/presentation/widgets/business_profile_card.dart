import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/theme/app_colors.dart';
import 'package:menuloq/core/global/app_toast.dart';
import 'package:menuloq/core/helper/image_picker_helper.dart';
import 'package:menuloq/core/helper/phone_number_helper.dart';
import 'package:menuloq/core/widgets/mobile_number_form_field.dart';
import 'package:menuloq/features/business_setting/domain/intities/business_settings_entity.dart';
import 'package:menuloq/features/business_setting/domain/params/update_business_settings_params.dart';
import 'package:menuloq/features/business_setting/presentation/bloc/business_settings_bloc.dart';
import 'package:menuloq/features/business_setting/presentation/bloc/business_settings_event.dart';
import 'package:menuloq/features/business_setting/presentation/bloc/business_settings_state.dart';
import 'package:menuloq/features/business_setting/presentation/widgets/business_setting_text_field.dart';
import 'package:menuloq/features/business_setting/presentation/widgets/field_label.dart';

class BusinessProfileCard extends StatefulWidget {
  const BusinessProfileCard({super.key, required this.settings});

  final BusinessSettingsEntity settings;

  @override
  State<BusinessProfileCard> createState() => BusinessProfileCardState();
}

class BusinessProfileCardState extends State<BusinessProfileCard> {
  final _formKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController();
  final _subdomainController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();

  String _countryIsoCode = 'BD';
  bool _formFilledFromApi = false;
  PickedAppImage? _selectedLogo;
  bool _isPickingLogo = false;

  @override
  void initState() {
    super.initState();
    _fillFormFromApi();
  }

  @override
  void didUpdateWidget(covariant BusinessProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.settings != widget.settings) {
      _formFilledFromApi = false;
      _selectedLogo = null;
      _fillFormFromApi();
    }
  }

  void _fillFormFromApi() {
    if (_formFilledFromApi) return;

    final business = widget.settings.business;

    _businessNameController.text = business.businessName;
    _subdomainController.text = business.websiteUrl;
    _ownerNameController.text = business.ownerName;
    _emailController.text = business.businessEmail;

    final fallbackCountry = MobileNumberFormField.countryFromCode(
      business.country,
    );
    final mobileDialCode =
        business.mobileDialCode ?? '+${fallbackCountry.phoneCode}';
    final parsedPhone = PhoneNumberHelper.parse(
      MobileNumberFormField.toInternationalNumber(
        localNumber: business.businessMobileNumber,
        dialCode: mobileDialCode,
      ),
    );

    _countryIsoCode = parsedPhone.isoCode;
    _mobileController.text = parsedPhone.localNumber;

    _addressController.text = business.businessAddress ?? '';

    _formFilledFromApi = true;
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _subdomainController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final settings = widget.settings;
    final mobileCountry = MobileNumberFormField.countryFromCode(
      _countryIsoCode,
    );

    context.read<BusinessSettingsBloc>().add(
      BusinessSettingsSaveRequested(
        UpdateBusinessSettingsParams.fromSettings(
          settings,
          businessName: _businessNameController.text.trim(),
          ownerName: _ownerNameController.text.trim(),
          businessEmail: _emailController.text.trim(),
          businessMobileNumber: _mobileController.text.trim(),
          mobileDialCode: '+${mobileCountry.phoneCode}',
          businessAddress: _addressController.text.trim(),
          logoBytes: _selectedLogo?.bytes,
          logoFileName: _selectedLogo?.fileName,
        ),
      ),
    );
  }

  void _onFieldChanged() {
    context.read<BusinessSettingsBloc>().add(
      const BusinessSettingsFieldsChanged(),
    );
  }

  Future<void> _pickLogo() async {
    if (_isPickingLogo) return;

    final source = await _showImageSourcePicker();
    if (source == null || !mounted) return;

    setState(() => _isPickingLogo = true);

    try {
      final image = await ImagePickerHelper.pick(source: source);
      if (!mounted || image == null) return;

      setState(() => _selectedLogo = image);
      _onFieldChanged();
    } on ImagePickerException catch (error) {
      if (mounted) AppToast.error(context, message: error.message);
    } catch (_) {
      if (mounted) {
        AppToast.error(
          context,
          message: 'Could not select the image. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingLogo = false);
    }
  }

  Future<AppImageSource?> _showImageSourcePicker() {
    final theme = Theme.of(context);

    return showModalBottomSheet<AppImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: theme.colorScheme.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose logo source',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context, AppImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Photo library'),
                  onTap: () {
                    Navigator.pop(context, AppImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final business = widget.settings.business;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final borderColor = isDark
        ? AppColors.darkCardBorder
        : AppColors.cardBorder;

    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return BlocBuilder<BusinessSettingsBloc, BusinessSettingsState>(
      builder: (context, state) {
        final isSaving = state.isSaving;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? AppColors.darkShadow
                          : AppColors.lightShadow,
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 640;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Profile',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: titleColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 22),

                        _LogoPickerSection(
                          isWide: isWide,
                          businessName: business.businessName,
                          logoUrl: business.logoUrl,
                          selectedLogo: _selectedLogo,
                          isPicking: _isPickingLogo,
                          enabled: !isSaving,
                          onPick: _pickLogo,
                          errorText: state.fieldErrors['logo'],
                        ),

                        const SizedBox(height: 28),

                        FieldLabel(text: 'Business name'),
                        const SizedBox(height: 8),
                        BusinessSettingTextField(
                          controller: _businessNameController,
                          enabled: !isSaving,
                          hintText: 'Enter business name',
                          validator: _requiredValidator,
                          serverError: state.fieldErrors['business_name'],
                          onChanged: (_) => _onFieldChanged(),
                        ),

                        const SizedBox(height: 20),

                        FieldLabel(text: 'Business URL / Subdomain'),
                        const SizedBox(height: 8),
                        BusinessSettingTextField(
                          controller: _subdomainController,
                          enabled: !isSaving,
                          readOnly: true,
                          hintText: 'business.menuloq.com',
                          suffixIcon: Icons.lock_outline_rounded,
                        ),
                        const SizedBox(height: 10),
                        const _LockedUrlHint(),

                        const SizedBox(height: 22),

                        FieldLabel(text: 'Owner name'),
                        const SizedBox(height: 8),
                        BusinessSettingTextField(
                          controller: _ownerNameController,
                          enabled: !isSaving,
                          hintText: 'Enter owner name',
                          validator: _requiredValidator,
                          serverError: state.fieldErrors['owner_name'],
                          onChanged: (_) => _onFieldChanged(),
                        ),

                        const SizedBox(height: 20),

                        FieldLabel(text: 'Business email'),
                        const SizedBox(height: 8),
                        BusinessSettingTextField(
                          controller: _emailController,
                          enabled: !isSaving,
                          hintText: 'Enter business email',
                          keyboardType: TextInputType.emailAddress,
                          validator: _emailValidator,
                          serverError: state.fieldErrors['business_email'],
                          onChanged: (_) => _onFieldChanged(),
                        ),

                        const SizedBox(height: 20),

                        FieldLabel(text: 'Business mobile number'),
                        const SizedBox(height: 8),
                        MobileNumberFormField(
                          controller: _mobileController,
                          enabled: !isSaving,
                          initialCountryCode: _countryIsoCode,
                          serverError:
                              state.fieldErrors['business_mobile_number'],
                          validator: (value) =>
                              MobileNumberFormField.validateForCountryCode(
                            value: value ?? '',
                            countryCode: _countryIsoCode,
                          ),
                          onChanged: (value) {
                            _onFieldChanged();
                            if (_countryIsoCode == value.countryCode) return;
                            setState(() {
                              _countryIsoCode = value.countryCode;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        FieldLabel(text: 'Business address'),
                        const SizedBox(height: 8),
                        BusinessSettingTextField(
                          controller: _addressController,
                          enabled: !isSaving,
                          hintText: 'Enter business address',
                          maxLines: 3,
                          textInputAction: TextInputAction.newline,
                          serverError: state.fieldErrors['business_address'],
                          onChanged: (_) => _onFieldChanged(),
                        ),

                        const SizedBox(height: 22),

                        _InfoTile(
                          icon: Icons.badge_outlined,
                          title: 'Business ID',
                          value: business.id.toString(),
                        ),
                        const SizedBox(height: 10),
                        _InfoTile(
                          icon: Icons.link_rounded,
                          title: 'Username',
                          value: business.userName,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              _SaveButton(isSaving: isSaving, onPressed: _saveChanges),
            ],
          ),
        );
      },
    );
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'This field is required.';
    }

    return null;
  }

  String? _emailValidator(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) {
      return 'Please enter business email.';
    }

    final isValid = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

    if (!isValid) {
      return 'Please enter a valid email address.';
    }

    return null;
  }
}




class _LogoPickerSection extends StatelessWidget {
  const _LogoPickerSection({
    required this.isWide,
    required this.businessName,
    required this.logoUrl,
    required this.selectedLogo,
    required this.isPicking,
    required this.enabled,
    required this.onPick,
    this.errorText,
  });

  final bool isWide;
  final String businessName;
  final String? logoUrl;
  final PickedAppImage? selectedLogo;
  final bool isPicking;
  final bool enabled;
  final VoidCallback onPick;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _BusinessLogoPreview(
          businessName: businessName,
          logoUrl: logoUrl,
          selectedLogo: selectedLogo,
        ),
        const SizedBox(width: 34),
        Expanded(
          child: _LogoPickerActions(
            textAlign: TextAlign.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            isPicking: isPicking,
            enabled: enabled,
            onPick: onPick,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

class _BusinessLogoPreview extends StatelessWidget {
  const _BusinessLogoPreview({
    required this.businessName,
    required this.logoUrl,
    required this.selectedLogo,
  });

  final String businessName;
  final String? logoUrl;
  final PickedAppImage? selectedLogo;

  @override
  Widget build(BuildContext context) {
    final initials = _businessInitials(businessName);

    return SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        children: [
          Container(
            width: 126,
            height: 126,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(35),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF004D40), Color(0xFF00251F)],
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: selectedLogo != null
                ? Image.memory(
                    selectedLogo!.bytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                : logoUrl != null && logoUrl!.trim().isNotEmpty
                ? Image.network(
                    logoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return _LogoFallback(initials: initials);
                    },
                  )
                : _LogoFallback(initials: initials),
          ),
          Positioned(
            right: 4,
            bottom: 12,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 32,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LogoPickerActions extends StatelessWidget {
  const _LogoPickerActions({
    required this.textAlign,
    required this.crossAxisAlignment,
    required this.isPicking,
    required this.enabled,
    required this.onPick,
    this.errorText,
  });

  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final bool isPicking;
  final bool enabled;
  final VoidCallback onPick;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        OutlinedButton(
          onPressed: enabled && !isPicking ? onPick : null,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(160, 54),
            foregroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.accent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: isPicking
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                )
              : const Text(
                  'Change logo',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          'PNG or JPG, maximum 512 KB',
          textAlign: textAlign,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (errorText != null && errorText!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            textAlign: textAlign,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

String _businessInitials(String value) {
  final words = value.trim().split(RegExp(r'\s+'));

  if (words.isEmpty || value.trim().isEmpty) return 'ML';

  if (words.length == 1) {
    return words.first
        .substring(0, words.first.length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  return '${words[0][0]}${words[1][0]}'.toUpperCase();
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaving, required this.onPressed});

  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isSaving ? 0.75 : 1,
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Color(0xFF64C800), Color(0xFF42A500)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withAlpha(60),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: isSaving ? null : onPressed,
          icon: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: AppColors.white,
                  ),
                )
              : const Icon(Icons.save_outlined),
          label: Text(isSaving ? 'Saving...' : 'Save changes'),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: AppColors.white,
            shadowColor: Colors.transparent,
            foregroundColor: AppColors.white,
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkFill : AppColors.fill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedUrlHint extends StatelessWidget {
  const _LockedUrlHint();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 18,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Business URL cannot be changed.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
