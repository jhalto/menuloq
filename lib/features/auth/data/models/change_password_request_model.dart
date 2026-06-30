class ResetPasswordRequestModel {
  const ResetPasswordRequestModel({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.passwordConfirmation,
  });
  final String email;
  final String otp;
  final String newPassword;
  final String passwordConfirmation;

  Map<String, dynamic> toJson() => {
         
        'email': email,
        'otp': otp,
        'password': newPassword,
        'password_confirmation': passwordConfirmation,
      };
}