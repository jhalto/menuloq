import 'package:menuloq/features/account/domain/params/change_password_params.dart';
import 'package:menuloq/features/account/domain/repositories/my_account_repository.dart';

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);

  final MyAccountRepository _repository;

  Future<String> call(ChangePasswordParams params) {
    return _repository.changePassword(params);
  }
}
