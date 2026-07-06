class LoginResponseModel {
  const LoginResponseModel({
    required this.success,
    required this.message,
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
    required this.business,
  });

  final bool success;
  final String message;
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final LoginUserModel user;
  final LoginBusinessModel business;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return LoginResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      accessToken: data['access_token']?.toString() ?? '',
      tokenType: data['token_type']?.toString() ?? 'Bearer',
      expiresIn: data['expires_in'] as int? ?? 0,
      user: LoginUserModel.fromJson(
        data['user'] as Map<String, dynamic>? ?? {},
      ),
      business: LoginBusinessModel.fromJson(
        data['business'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class LoginUserModel {
  const LoginUserModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.designation,
    required this.type,
    required this.isVerified,
    required this.isActive,
  });

  final int id;
  final int uid;
  final String name;
  final String email;
  final String mobileNumber;
  final String designation;
  final String type;
  final bool isVerified;
  final bool isActive;

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      id: json['id'] as int? ?? 0,
      uid: json['uid'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobileNumber: json['mobile_number']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}

class LoginBusinessModel {
  const LoginBusinessModel({
    required this.id,
    required this.businessName,
    required this.userName,
  });

  final int id;
  final String businessName;
  final String userName;

  factory LoginBusinessModel.fromJson(Map<String, dynamic> json) {
    return LoginBusinessModel(
      id: json['id'] as int? ?? 0,
      businessName: json['business_name']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
    );
  }
}