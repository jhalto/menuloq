import 'package:menuloq/features/account/domain/entities/my_account_entitry.dart';

class MyAccountModel extends MyAccountEntity {
  const MyAccountModel({
    required super.user,
    required super.business,
  });

  factory MyAccountModel.fromJson(Map<String, dynamic> json) {
    final data = _toMap(json['data']);
    final userJson = _toMap(data['user']).isNotEmpty
        ? _toMap(data['user'])
        : data;
    final businessJson = _toMap(data['business']);

    return MyAccountModel(
      user: AccountUserModel.fromJson(userJson),
      business: AccountBusinessModel.fromJson(businessJson),
    );
  }
}

class AccountUserModel extends AccountUserEntity {
  const AccountUserModel({
    required super.id,
    required super.uid,
    required super.name,
    required super.email,
    required super.mobileNumber,
    required super.address,
    required super.designation,
    required super.type,
  });

  factory AccountUserModel.fromJson(Map<String, dynamic> json) {
    return AccountUserModel(
      id: _toInt(json['id']),
      uid: _toInt(json['uid']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobileNumber: json['mobile_number']?.toString() ?? '',
      address: json['address']?.toString(),
      designation: json['designation']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}

class AccountBusinessModel extends AccountBusinessEntity {
  const AccountBusinessModel({
    required super.id,
    required super.businessName,
    required super.userName,
    required super.logo,
    required super.logoUrl,
  });

  factory AccountBusinessModel.fromJson(Map<String, dynamic> json) {
    return AccountBusinessModel(
      id: _toInt(json['id']),
      businessName: json['business_name']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      logo: json['logo']?.toString(),
      logoUrl: json['logo_url']?.toString(),
    );
  }
}

Map<String, dynamic> _toMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
