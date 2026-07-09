class BusinessSettingsEntity {
  const BusinessSettingsEntity({
    required this.business,
    required this.deliverySetting,
    required this.options,
  });

  final BusinessEntity business;
  final DeliverySettingEntity deliverySetting;
  final BusinessOptionsEntity options;
}

class BusinessEntity {
  const BusinessEntity({
    required this.id,
    required this.logo,
    required this.logoUrl,
    required this.businessName,
    required this.userName,
    required this.websiteUrl,
    required this.ownerName,
    required this.businessEmail,
    required this.businessMobileNumber,
    required this.mobileDialCode,
    required this.country,
    required this.countryLocked,
    required this.timezone,
    required this.currency,
    required this.currencyLocked,
    required this.websiteDefaultLanguage,
    required this.businessAddress,
    required this.deliveryOptions,
    required this.isAvailable,
  });

  final int id;
  final String? logo;
  final String? logoUrl;
  final String businessName;
  final String userName;
  final String websiteUrl;
  final String ownerName;
  final String businessEmail;
  final String businessMobileNumber;
  final String? mobileDialCode;
  final String country;
  final bool countryLocked;
  final String timezone;
  final String currency;
  final bool currencyLocked;
  final String websiteDefaultLanguage;
  final String? businessAddress;
  final List<String> deliveryOptions;
  final bool isAvailable;
}

class DeliverySettingEntity {
  const DeliverySettingEntity({
    required this.deliveryCharge,
    required this.instructions,
  });

  final double deliveryCharge;
  final String? instructions;
}

class BusinessOptionsEntity {
  const BusinessOptionsEntity({
    required this.countries,
    required this.currencies,
    required this.timezones,
    required this.languages,
    required this.deliveryOptions,
  });

  final Map<String, String> countries;
  final Map<String, String> currencies;
  final Map<String, String> timezones;
  final Map<String, LanguageOptionEntity> languages;
  final List<String> deliveryOptions;
}

class LanguageOptionEntity {
  const LanguageOptionEntity({
    required this.name,
    required this.key,
    required this.flag,
  });

  final String name;
  final String key;
  final String flag;
}
