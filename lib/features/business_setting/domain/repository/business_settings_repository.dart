
import 'package:menuloq/features/business_setting/domain/intities/business_settings_entity.dart';

abstract class BusinessSettingsRepository {
  Future<BusinessSettingsEntity> getBusinessSettings({
    bool forceRefresh = false,
  });
}