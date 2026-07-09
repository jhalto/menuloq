
import 'package:menuloq/features/business_setting/domain/intities/business_settings_entity.dart';
import 'package:menuloq/features/business_setting/domain/params/update_business_settings_params.dart';

abstract class BusinessSettingsRepository {
  Future<BusinessSettingsEntity> getBusinessSettings({
    bool forceRefresh = false,
  });

  Future<BusinessSettingsEntity> updateBusinessSettings(
    UpdateBusinessSettingsParams params,
  );
}
