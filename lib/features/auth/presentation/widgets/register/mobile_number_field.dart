import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:menuloq/config/theme/app_colors.dart';

class MobileNumberField extends StatefulWidget {
  const MobileNumberField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.validator,
    this.onCountryChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final FormFieldValidator<String> validator;
  final ValueChanged<Country>? onCountryChanged;

  @override
  State<MobileNumberField> createState() => _MobileNumberFieldState();
}

class _MobileNumberFieldState extends State<MobileNumberField> {
  Country _selectedCountry = Country(
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

  void _openCountryPicker() {
    if (!widget.enabled) return;

    showCountryPicker(
      context: context,
      showPhoneCode: true,
      favorite: const ['BD', 'IN', 'US', 'GB', 'AE', 'SA'],
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        inputDecoration: InputDecoration(
          hintText: 'Search country',
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
          ),
        ),
      ),
      onSelect: (country) {
        setState(() {
          _selectedCountry = country;
        });

        widget.onCountryChanged?.call(country);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor.withAlpha(140);
    final fillColor = Theme.of(context).inputDecorationTheme.fillColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56,
          width: 132,
          child: InkWell(
            onTap: _openCountryPicker,
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
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.enabled
                          ? AppColors.textSecondary
                          : AppColors.textDisabled,
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
            enabled: widget.enabled,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Enter mobile number',
            ),
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}