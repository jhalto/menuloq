import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menuloq/config/theme/app_colors.dart';

class MobileNumberValue {
  const MobileNumberValue({
    required this.country,
    required this.localNumber,
    required this.internationalNumber,
  });

  final Country country;
  final String localNumber;
  final String internationalNumber;

  String get dialCode => '+${country.phoneCode}';
  String get countryCode => country.countryCode;
}

class MobileNumberFormField extends StatefulWidget {
  const MobileNumberFormField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.initialCountryCode = 'BD',
    this.validator,
    this.onChanged,
    this.onCountryChanged,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.hintText,
    this.serverError,
  });

  final TextEditingController controller;
  final bool enabled;
  final String initialCountryCode;
  final FormFieldValidator<String>? validator;
  final ValueChanged<MobileNumberValue>? onChanged;
  final ValueChanged<Country>? onCountryChanged;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final String? hintText;
  final String? serverError;

  static String toInternationalNumber({
    required String localNumber,
    required String dialCode,
  }) {
    final digits = localNumber.replaceAll(RegExp(r'\D'), '');
    final normalizedDialCode = dialCode.startsWith('+')
        ? dialCode
        : '+$dialCode';

    if (digits.isEmpty) return normalizedDialCode;

    if (digits.startsWith('0')) {
      return '$normalizedDialCode${digits.substring(1)}';
    }

    final dialDigits = normalizedDialCode.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith(dialDigits)) {
      return '+$digits';
    }

    return '$normalizedDialCode$digits';
  }

  static String? validate({
    required String value,
    required Country country,
    String? apiError,
    String emptyMessage = 'Please enter your mobile number.',
    String invalidMessage = 'Please enter a valid mobile number.',
  }) {
    var digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) return emptyMessage;

    if (country.countryCode.toUpperCase() == 'BD') {
      if (digits.length == 10 && digits.startsWith('1')) {
        digits = '0$digits';
      }

      if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(digits)) {
        return 'Bangladesh mobile number must be 11 digits and start with 01.';
      }

      return apiError;
    }

    if (digits.length < 6 || digits.length > 15) {
      return invalidMessage;
    }

    return apiError;
  }

  static String? validateForCountryCode({
    required String value,
    required String countryCode,
    String? apiError,
    String emptyMessage = 'Please enter your mobile number.',
    String invalidMessage = 'Please enter a valid mobile number.',
  }) {
    return validate(
      value: value,
      country: countryFromCode(countryCode),
      apiError: apiError,
      emptyMessage: emptyMessage,
      invalidMessage: invalidMessage,
    );
  }

  static Country countryFromCode(String code) {
    final normalizedCode = code.trim().toUpperCase();
    final normalizedPhoneCode = normalizedCode.replaceAll(RegExp(r'\D'), '');

    for (final country in CountryService().getAll()) {
      if (country.countryCode.toUpperCase() == normalizedCode ||
          country.phoneCode == normalizedPhoneCode) {
        return country;
      }
    }

    return _bangladesh;
  }

  static final Country _bangladesh = Country(
    phoneCode: '880',
    countryCode: 'BD',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Bangladesh',
    example: '1712345678',
    displayName: 'Bangladesh',
    displayNameNoCountryCode: 'Bangladesh',
    e164Key: '',
  );

  @override
  State<MobileNumberFormField> createState() => _MobileNumberFormFieldState();
}

class _MobileNumberFormFieldState extends State<MobileNumberFormField> {
  static const double _fieldHeight = 56;

  late Country _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = MobileNumberFormField.countryFromCode(
      widget.initialCountryCode,
    );
  }

  @override
  void didUpdateWidget(covariant MobileNumberFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialCountryCode != widget.initialCountryCode) {
      _selectedCountry = MobileNumberFormField.countryFromCode(
        widget.initialCountryCode,
      );
    }
  }

  MobileNumberValue get value => MobileNumberValue(
        country: _selectedCountry,
        localNumber: widget.controller.text.trim(),
        internationalNumber: MobileNumberFormField.toInternationalNumber(
          localNumber: widget.controller.text,
          dialCode: '+${_selectedCountry.phoneCode}',
        ),
      );

  void _openCountryPicker() {
    if (!widget.enabled) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetColor = isDark ? AppColors.darkCard : AppColors.surface;
    final fillColor = isDark ? AppColors.darkFill : AppColors.fill;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final hintColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.accent;

    showCountryPicker(
      context: context,
      showPhoneCode: true,
      favorite: const ['BD', 'IN', 'US', 'GB', 'AE', 'SA'],
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        backgroundColor: sheetColor,
        textStyle: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        searchTextStyle: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        inputDecoration: InputDecoration(
          hintText: 'Search country',
          hintStyle: TextStyle(color: hintColor),
          prefixIcon: Icon(Icons.search_rounded, color: hintColor),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accentColor, width: 1.4),
          ),
        ),
      ),
      onSelect: (country) {
        setState(() {
          _selectedCountry = country;
        });

        widget.onCountryChanged?.call(country);
        _handleChanged(widget.controller.text);
      },
    );
  }

  void _handleChanged(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');

    if (_selectedCountry.countryCode.toUpperCase() == 'BD' &&
        digits.startsWith('1')) {
      digits = '0$digits';
    }

    if (digits != value) {
      widget.controller.value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }

    widget.onChanged?.call(this.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final fillColor = isDark ? AppColors.darkFill : AppColors.fill;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final iconColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final disabledColor = isDark
        ? AppColors.darkTextDisabled
        : AppColors.textDisabled;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _fieldHeight,
          width: 128,
          child: InkWell(
            onTap: _openCountryPicker,
            canRequestFocus: false,
            borderRadius: BorderRadius.circular(14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Text(
                      _selectedCountry.flagEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '+${_selectedCountry.phoneCode}',
                          maxLines: 1,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.enabled ? iconColor : disabledColor,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: widget.enabled ? textColor : iconColor,
            ),
            keyboardType: TextInputType.phone,
            textInputAction: widget.textInputAction,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(
                _selectedCountry.countryCode.toUpperCase() == 'BD' ? 11 : 15,
              ),
            ],
            decoration: InputDecoration(
              hintText: widget.hintText ?? _hintText,
              errorText: widget.serverError,
              constraints: const BoxConstraints(minHeight: _fieldHeight),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
            ),
            validator: widget.validator,
            onChanged: _handleChanged,
            onFieldSubmitted: widget.onFieldSubmitted,
          ),
        ),
      ],
    );
  }

  String get _hintText {
    if (_selectedCountry.countryCode.toUpperCase() == 'BD') {
      return '017XXXXXXXX';
    }

    return 'Enter mobile number';
  }
}
