import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class ParsedAccountPhone {
  const ParsedAccountPhone({
    required this.isoCode,
    required this.dialCode,
    required this.localNumber,
  });

  final String isoCode;
  final String dialCode;
  final String localNumber;
}

class PhoneNumberHelper {
  const PhoneNumberHelper._();

  static ParsedAccountPhone parse(String value) {
    final phone = value.trim();

    if (phone.isEmpty) {
      return const ParsedAccountPhone(
        isoCode: 'BD',
        dialCode: '+880',
        localNumber: '',
      );
    }

    try {
      final parsed = PhoneNumber.parse(phone);

      final isoCode = parsed.isoCode.name;
      final dialCode = '+${parsed.countryCode}';

      var localNumber = parsed.nsn;

      if (isoCode == 'BD' && !localNumber.startsWith('0')) {
        localNumber = '0$localNumber';
      }

      return ParsedAccountPhone(
        isoCode: isoCode,
        dialCode: dialCode,
        localNumber: localNumber,
      );
    } catch (_) {
      final isBangladesh = phone.startsWith('+880');

      return ParsedAccountPhone(
        isoCode: 'BD',
        dialCode: '+880',
        localNumber: isBangladesh
            ? '0${phone.substring(4)}'
            
            : phone,
      );
    }
  }

  static String toInternational({
    required String localNumber,
    required String isoCode,
  }) {
    try {
      final iso = IsoCode.values.byName(
        isoCode.trim().toUpperCase(),
      );

      final phone = PhoneNumber.parse(
        localNumber.trim(),
        destinationCountry: iso,
      );

      return phone.international.replaceAll(
        RegExp(r'\s+'),
        '',
      );
    } catch (_) {
      return localNumber.trim();
    }
  }
}