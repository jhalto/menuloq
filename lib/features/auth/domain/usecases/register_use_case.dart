import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String businessName,
    required String userName,
    required String ownerName,
    required String email,
    required String mobileNumber,
    required String password,
    required String passwordConfirmation,
  }) {
    return _repository.register(
      businessName: businessName,
      userName: userName,
      ownerName: ownerName,
      email: email,
      mobileNumber: mobileNumber,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}