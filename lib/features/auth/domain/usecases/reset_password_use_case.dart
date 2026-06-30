import 'package:menuloq/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String email,
    required String otp,
    required String newPassword,
    required String passwordConfirmation,
  }) {
    return _repository.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
