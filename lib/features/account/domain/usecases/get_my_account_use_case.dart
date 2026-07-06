import 'package:menuloq/features/account/domain/entities/my_account_entitry.dart';
import 'package:menuloq/features/account/domain/repositories/my_account_repository.dart';

class GetMyAccountUseCase {
  const GetMyAccountUseCase(this._repository);

  final MyAccountRepository _repository;

  Future<MyAccountEntity> call({bool forceRefresh = false}) {
    return _repository.getMyAccount(forceRefresh: forceRefresh);
  }
}
