class RegisterRequestModel {
  const RegisterRequestModel({
    required this.businessName,
    required this.userName,
    required this.ownerName,
    required this.email,
    required this.mobileNumber,
    required this.password,
    required this.passwordConfirmation,
  });

  final String businessName;
  final String userName;
  final String ownerName;
  final String email;
  final String mobileNumber;
  final String password;
  final String passwordConfirmation;

  Map<String, dynamic> toJson() {
    return {
      'business_name': businessName,
      'user_name': userName,
      'owner_name': ownerName,
      'email': email,
      'mobile_number': mobileNumber,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}