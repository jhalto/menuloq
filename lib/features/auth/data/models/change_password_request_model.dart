class ChangePasswordRequestModel {
  const ChangePasswordRequestModel({
    required this.oldPassword,
    required this.newPassword,
    required this.passwordConfirmation,
  });

  final String oldPassword;
  final String newPassword;
  final String passwordConfirmation;

  Map<String, dynamic> toJson() => {
        'current_password': oldPassword,
        'password': newPassword,
        'password_confirmation': passwordConfirmation,
      };
}