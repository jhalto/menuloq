import 'package:menuloq/features/auth/domain/repositories/auth_repository.dart';

class GetOtpUseCase {
  const GetOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email}) async {
    return _repository.getOtp(email: email);
  }
}
