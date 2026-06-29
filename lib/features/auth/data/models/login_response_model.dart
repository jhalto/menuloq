class LoginResponseModel {
  const LoginResponseModel({
    required this.token,
    required this.message,
  });

  final String token;
  final String message;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String? ?? '',
      message: json['message'] as String? ?? 'Login successful.',
    );
  }
}