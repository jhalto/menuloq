import 'package:equatable/equatable.dart';
import 'package:menuloq/features/business_setting/domain/intities/business_settings_entity.dart';

class UpdateBusinessSettingsParams extends Equatable {
  const UpdateBusinessSettingsParams({
    required this.businessName,
    required this.ownerName,
    required this.businessEmail,
    required this.businessMobileNumber,
    required this.mobileDialCode,
    required this.country,
    required this.timezone,
    required this.currency,
    required this.websiteDefaultLanguage,
    required this.businessAddress,
    required this.deliveryOptions,
    required this.deliveryCharge,
    required this.instructions,
    required this.isAvailable,
  });

  final String businessName;
  final String ownerName;
  final String businessEmail;
  final String businessMobileNumber;
  final String mobileDialCode;
  final String country;
  final String timezone;
  final String currency;
  final String websiteDefaultLanguage;
  final String businessAddress;
  final List<String> deliveryOptions;
  final double deliveryCharge;
  final String instructions;
  final bool isAvailable;

  factory UpdateBusinessSettingsParams.fromSettings(
    BusinessSettingsEntity settings, {
    String? businessName,
    String? ownerName,
    String? businessEmail,
    String? businessMobileNumber,
    String? mobileDialCode,
    String? country,
    String? timezone,
    String? currency,
    String? websiteDefaultLanguage,
    String? businessAddress,
    List<String>? deliveryOptions,
    double? deliveryCharge,
    String? instructions,
    bool? isAvailable,
  }) {
    final business = settings.business;
    final delivery = settings.deliverySetting;

    return UpdateBusinessSettingsParams(
      businessName: businessName ?? business.businessName,
      ownerName: ownerName ?? business.ownerName,
      businessEmail: businessEmail ?? business.businessEmail,
      businessMobileNumber:
          businessMobileNumber ?? business.businessMobileNumber,
      mobileDialCode:
          mobileDialCode ??
          business.mobileDialCode ??
          _defaultDialCode(business.country),
      country: country ?? business.country,
      timezone: timezone ?? business.timezone,
      currency: currency ?? business.currency,
      websiteDefaultLanguage:
          websiteDefaultLanguage ?? business.websiteDefaultLanguage,
      businessAddress: businessAddress ?? business.businessAddress ?? '',
      deliveryOptions: deliveryOptions ?? business.deliveryOptions,
      deliveryCharge: deliveryCharge ?? delivery.deliveryCharge,
      instructions: instructions ?? delivery.instructions ?? '',
      isAvailable: isAvailable ?? business.isAvailable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_name': businessName,
      'owner_name': ownerName,
      'business_email': businessEmail,
      'business_mobile_number': businessMobileNumber,
      'mobile_dial_code': mobileDialCode,
      'country': country,
      'timezone': timezone,
      'currency': currency,
      'website_default_language': websiteDefaultLanguage,
      'business_address': businessAddress,
      'delivery_options[]': deliveryOptions,
      'delivery_charge': deliveryCharge,
      'instructions': instructions,
      'is_available': isAvailable ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [
        businessName,
        ownerName,
        businessEmail,
        businessMobileNumber,
        mobileDialCode,
        country,
        timezone,
        currency,
        websiteDefaultLanguage,
        businessAddress,
        deliveryOptions,
        deliveryCharge,
        instructions,
        isAvailable,
      ];
}

String _defaultDialCode(String countryCode) {
  switch (countryCode.trim().toUpperCase()) {
    case 'US':
    case 'CA':
      return '+1';
    case 'GB':
      return '+44';
    case 'IN':
      return '+91';
    case 'AE':
      return '+971';
    case 'SA':
      return '+966';
    case 'BD':
    default:
      return '+880';
  }
}
