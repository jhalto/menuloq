import 'package:menuloq/features/account/data/data_sources/remote/my_account_remote_data_source.dart';
import 'package:menuloq/features/account/domain/entities/my_account_entitry.dart';
import 'package:menuloq/features/account/domain/params/change_password_params.dart';
import 'package:menuloq/features/account/domain/params/update_my_account_params.dart';
import 'package:menuloq/features/account/domain/repositories/my_account_repository.dart';

class MyAccountRepositoryImpl implements MyAccountRepository {
  MyAccountRepositoryImpl(this._remoteDataSource);

  final MyAccountRemoteDataSource _remoteDataSource;

  MyAccountEntity? _cachedAccount;
  Future<MyAccountEntity>? _runningRequest;

  @override
  Future<MyAccountEntity> getMyAccount({bool forceRefresh = false}) {
    if (!forceRefresh && _cachedAccount != null) {
      return Future.value(_cachedAccount);
    }

    if (!forceRefresh && _runningRequest != null) {
      return _runningRequest!;
    }

    final request = _remoteDataSource.getMyAccount().then((account) {
      _cachedAccount = account;
      return account;
    }).whenComplete(() {
      _runningRequest = null;
    });

    _runningRequest = request;

    return request;
  }

  @override
  Future<MyAccountEntity> updateMyAccount(UpdateMyAccountParams params) async {
    final updatedAccount = await _remoteDataSource.updateMyAccount(params);

    if (updatedAccount != null) {
      _cachedAccount = updatedAccount;
      return updatedAccount;
    }

    return getMyAccount(forceRefresh: true);
  }

  @override
  Future<String> changePassword(ChangePasswordParams params) {
    return _remoteDataSource.changePassword(params);
  }
}
