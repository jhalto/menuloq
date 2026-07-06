import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/theme/app_colors.dart';
import 'package:menuloq/features/business_setting/domain/intities/business_settings_entity.dart';
import 'package:menuloq/features/business_setting/presentation/bloc/business_settings_bloc.dart';
import 'package:menuloq/features/business_setting/presentation/bloc/business_settings_state.dart';
import 'package:menuloq/features/business_setting/presentation/widgets/business_setting_text_field.dart';
import 'package:menuloq/features/business_setting/presentation/widgets/field_label.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

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

  @override
  void initState() {
    super.initState();
    _fillFormFromApi();
  }

  @override
  void didUpdateWidget(covariant BusinessProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.settings.business.id != widget.settings.business.id) {
      _formFilledFromApi = false;
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

    _countryIsoCode = business.country.trim().isNotEmpty
        ? business.country.trim().toUpperCase()
        : 'BD';

    _mobileController.text = PhoneNumberHelper.toLocalDisplayNumber(
      fullNumber: business.businessMobileNumber,
      isoCode: _countryIsoCode,
    );

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
    final mobileNumber = PhoneNumberHelper.toInternationalNumber(
      value: _mobileController.text.trim(),
      isoCode: _countryIsoCode,
    );
    // TODO: Later call update business settings API here.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Update API is not connected yet.'),
        behavior: SnackBarBehavior.floating,
      ),
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
                        ),

                        const SizedBox(height: 28),

                        FieldLabel(text: 'Business name'),
                        const SizedBox(height: 8),
                        BusinessSettingTextField(
                          controller: _businessNameController,
                          enabled: !isSaving,
                          hintText: 'Enter business name',
                          validator: _requiredValidator,
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
                        ),

                        const SizedBox(height: 20),

                        FieldLabel(text: 'Business mobile number'),
                        const SizedBox(height: 8),
                        _PhoneInputRow(
                          enabled: !isSaving,
                          countryIsoCode: _countryIsoCode,
                          mobileController: _mobileController,
                          onCountryChanged: (value) {
                            setState(() {
                              _countryIsoCode = value;
                              _mobileController.clear();
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
  });

  final bool isWide;
  final String businessName;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _BusinessLogoPreview(businessName: businessName, logoUrl: logoUrl),
        const SizedBox(width: 34),
        const Expanded(
          child: _LogoPickerActions(
            textAlign: TextAlign.start,
            crossAxisAlignment: CrossAxisAlignment.start,
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
  });

  final String businessName;
  final String? logoUrl;

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
            child: logoUrl != null && logoUrl!.trim().isNotEmpty
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
  });

  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        OutlinedButton(
          onPressed: () {
            // TODO: Open image picker.
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(160, 54),
            foregroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.accent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
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

class _PhoneInputRow extends StatelessWidget {
  const _PhoneInputRow({
    required this.enabled,
    required this.countryIsoCode,
    required this.mobileController,
    required this.onCountryChanged,
  });

  final bool enabled;
  final String countryIsoCode;
  final TextEditingController mobileController;
  final ValueChanged<String> onCountryChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 132,
          child: IgnorePointer(
            ignoring: !enabled,
            child: CountryCodePicker(
              initialSelection: countryIsoCode,
              favorite: const [
                'BD',
                '+880',
                'US',
                '+1',
                'GB',
                '+44',
                'IN',
                '+91',
              ],
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              alignLeft: false,
              padding: EdgeInsets.zero,
              onChanged: (country) {
                final code = country.code;
                if (code == null || code.trim().isEmpty) return;
                onCountryChanged(code.toUpperCase());
              },
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: BusinessSettingTextField(
            controller: mobileController,
            enabled: enabled,
            hintText: countryIsoCode == 'BD' ? '017XXXXXXXX' : 'Phone number',
            keyboardType: TextInputType.phone,
            validator: (value) {
              return PhoneNumberHelper.validateMobileNumber(
                value: value ?? '',
                isoCode: countryIsoCode,
              );
            },
          ),
        ),
      ],
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

const List<String> _phoneCountryCodes = [
  '+880',
  '+1',
  '+44',
  '+91',
  '+971',
  '+966',
  '+974',
  '+965',
  '+60',
  '+65',
];

class PhoneNumberHelper {
  const PhoneNumberHelper._();

  static String? validateMobileNumber({
    required String value,
    required String isoCode,
  }) {
    final rawValue = value.trim();

    if (rawValue.isEmpty) {
      return 'Please enter mobile number.';
    }

    final normalizedIsoCode = isoCode.trim().toUpperCase();

    if (normalizedIsoCode == 'BD') {
      final digits = rawValue.replaceAll(RegExp(r'\D'), '');

      if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(digits)) {
        return 'Bangladesh mobile number must be 11 digits and start with 01.';
      }
    }

    final iso = _toIsoCode(normalizedIsoCode);

    if (iso == null) {
      return 'Unsupported country code.';
    }

    try {
      final phoneNumber = PhoneNumber.parse(rawValue, destinationCountry: iso);

      final isValidMobile = phoneNumber.isValid(type: PhoneNumberType.mobile);

      if (!isValidMobile) {
        return 'Please enter a valid mobile number.';
      }

      return null;
    } catch (_) {
      return 'Please enter a valid mobile number.';
    }
  }

  static String toLocalDisplayNumber({
    required String fullNumber,
    required String isoCode,
  }) {
    final value = fullNumber.trim();

    if (value.isEmpty) return '';

    final normalizedIsoCode = isoCode.trim().toUpperCase();

    if (normalizedIsoCode == 'BD') {
      final digits = value.replaceAll(RegExp(r'\D'), '');

      if (digits.startsWith('880') && digits.length == 13) {
        return '0${digits.substring(3)}';
      }

      if (digits.startsWith('01') && digits.length == 11) {
        return digits;
      }
    }

    try {
      final phoneNumber = PhoneNumber.parse(value);
      return phoneNumber.formatNsn();
    } catch (_) {
      return value;
    }
  }

  static String toInternationalNumber({
    required String value,
    required String isoCode,
  }) {
    final iso = _toIsoCode(isoCode.trim().toUpperCase());

    if (iso == null) return value.trim();

    try {
      final phoneNumber = PhoneNumber.parse(
        value.trim(),
        destinationCountry: iso,
      );

      return phoneNumber.international.replaceAll(RegExp(r'\s+'), '');
    } catch (_) {
      return value.trim();
    }
  }

  static IsoCode? _toIsoCode(String isoCode) {
    try {
      return IsoCode.values.byName(isoCode);
    } catch (_) {
      return null;
    }
  }
}
