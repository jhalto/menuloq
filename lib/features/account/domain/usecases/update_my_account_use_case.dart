import 'package:menuloq/features/account/domain/entities/my_account_entitry.dart';
import 'package:menuloq/features/account/domain/params/update_my_account_params.dart';

import '../repositories/my_account_repository.dart';

class UpdateMyAccountUseCase {
  const UpdateMyAccountUseCase(
    this._repository,
  );

  final MyAccountRepository _repository;

  Future<MyAccountEntity> call(
    UpdateMyAccountParams params,
  ) {
    return _repository.updateMyAccount(params);
  }
}
