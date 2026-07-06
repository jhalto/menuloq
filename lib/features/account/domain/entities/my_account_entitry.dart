import 'package:equatable/equatable.dart';

class MyAccountEntity extends Equatable {
  const MyAccountEntity({
    required this.user,
    required this.business,
  });

  final AccountUserEntity user;
  final AccountBusinessEntity business;

  @override
  List<Object> get props => [
        user,
        business,
      ];
}

class AccountUserEntity extends Equatable {
  const AccountUserEntity({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.address,
    required this.designation,
    required this.type,
  });

  final int id;
  final int uid;
  final String name;
  final String email;
  final String mobileNumber;
  final String? address;
  final String designation;
  final String type;

  String get initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'ML';

    if (words.length == 1) {
      final word = words.first;

      return word
          .substring(
            0,
            word.length >= 2 ? 2 : 1,
          )
          .toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        uid,
        name,
        email,
        mobileNumber,
        address,
        designation,
        type,
      ];
}

class AccountBusinessEntity extends Equatable {
  const AccountBusinessEntity({
    required this.id,
    required this.businessName,
    required this.userName,
    required this.logo,
    required this.logoUrl,
  });

  final int id;
  final String businessName;
  final String userName;
  final String? logo;
  final String? logoUrl;

  String get websiteUrl {
    if (userName.trim().isEmpty) return '';

    return 'https://$userName.menuloq.com';
  }

  @override
  List<Object?> get props => [
        id,
        businessName,
        userName,
        logo,
        logoUrl,
      ];
}