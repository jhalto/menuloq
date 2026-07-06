import 'package:menuloq/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  const CheckAuthStatusUseCase(this._repository);

  final AuthRepository _repository;

  Future<bool> call() {
    return _repository.isLoggedIn();
  }
}