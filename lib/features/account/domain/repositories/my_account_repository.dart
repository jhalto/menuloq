import 'package:menuloq/features/account/domain/entities/my_account_entitry.dart';
import 'package:menuloq/features/account/domain/params/change_password_params.dart';
import 'package:menuloq/features/account/domain/params/update_my_account_params.dart';


abstract class MyAccountRepository {
  Future<MyAccountEntity> getMyAccount({bool forceRefresh = false});

  Future<MyAccountEntity> updateMyAccount(UpdateMyAccountParams params);

  Future<String> changePassword(ChangePasswordParams params);

  void clearCache();
}
