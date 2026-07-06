import 'package:menuloq/features/account/domain/entities/my_account_entitry.dart';


abstract class MyAccountRepository {
  Future<MyAccountEntity> getMyAccount({bool forceRefresh = false});
}
