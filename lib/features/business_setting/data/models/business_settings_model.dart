
import 'package:menuloq/features/business_setting/domain/intities/business_settings_entity.dart';

class BusinessSettingsModel extends BusinessSettingsEntity {
  const BusinessSettingsModel({
    required super.business,
    required super.deliverySetting,
    required super.options,
  });

  factory BusinessSettingsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return BusinessSettingsModel(
      business: BusinessModel.fromJson(
        data['business'] as Map<String, dynamic>? ?? {},
      ),
      deliverySetting: DeliverySettingModel.fromJson(
        data['delivery_setting'] as Map<String, dynamic>? ?? {},
      ),
      options: BusinessOptionsModel.fromJson(
        data['options'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class BusinessModel extends BusinessEntity {
  const BusinessModel({
    required super.id,
    required super.logo,
    required super.logoUrl,
    required super.businessName,
    required super.userName,
    required super.websiteUrl,
    required super.ownerName,
    required super.businessEmail,
    required super.businessMobileNumber,
    required super.country,
    required super.countryLocked,
    required super.timezone,
    required super.currency,
    required super.currencyLocked,
    required super.websiteDefaultLanguage,
    required super.businessAddress,
    required super.deliveryOptions,
    required super.isAvailable,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: _toInt(json['id']),
      logo: json['logo']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      businessName: json['business_name']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      websiteUrl: json['website_url']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      businessEmail: json['business_email']?.toString() ?? '',
      businessMobileNumber: json['business_mobile_number']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      countryLocked: json['country_locked'] == true,
      timezone: json['timezone']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      currencyLocked: json['currency_locked'] == true,
      websiteDefaultLanguage: json['website_default_language']?.toString() ?? '',
      businessAddress: json['business_address']?.toString(),
      deliveryOptions: _toStringList(json['delivery_options']),
      isAvailable: json['is_available'] == true,
    );
  }
}

class DeliverySettingModel extends DeliverySettingEntity {
  const DeliverySettingModel({
    required super.deliveryCharge,
    required super.instructions,
  });

  factory DeliverySettingModel.fromJson(Map<String, dynamic> json) {
    return DeliverySettingModel(
      deliveryCharge: _toDouble(json['delivery_charge']),
      instructions: json['instructions']?.toString(),
    );
  }
}

class BusinessOptionsModel extends BusinessOptionsEntity {
  const BusinessOptionsModel({
    required super.countries,
    required super.currencies,
    required super.timezones,
    required super.languages,
    required super.deliveryOptions,
  });

  factory BusinessOptionsModel.fromJson(Map<String, dynamic> json) {
    return BusinessOptionsModel(
      countries: _toStringMap(json['countries']),
      currencies: _toStringMap(json['currencies']),
      timezones: _toStringMap(json['timezones']),
      languages: _toLanguageMap(json['languages']),
      deliveryOptions: _toStringList(json['delivery_options']),
    );
  }
}

class LanguageOptionModel extends LanguageOptionEntity {
  const LanguageOptionModel({
    required super.name,
    required super.key,
    required super.flag,
  });

  factory LanguageOptionModel.fromJson(Map<String, dynamic> json) {
    return LanguageOptionModel(
      name: json['name']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      flag: json['flag']?.toString() ?? '',
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

List<String> _toStringList(dynamic value) {
  if (value is! List) return [];
  return value.map((item) => item.toString()).toList();
}

Map<String, String> _toStringMap(dynamic value) {
  if (value is! Map) return {};

  return value.map(
    (key, value) => MapEntry(
      key.toString(),
      value.toString(),
    ),
  );
}

Map<String, LanguageOptionModel> _toLanguageMap(dynamic value) {
  if (value is! Map) return {};

  return value.map(
    (key, value) => MapEntry(
      key.toString(),
      LanguageOptionModel.fromJson(
        value is Map<String, dynamic> ? value : {},
      ),
    ),
  );
}