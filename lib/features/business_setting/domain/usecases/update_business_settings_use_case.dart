import 'package:menuloq/features/business_setting/domain/intities/business_settings_entity.dart';
import 'package:menuloq/features/business_setting/domain/params/update_business_settings_params.dart';
import 'package:menuloq/features/business_setting/domain/repository/business_settings_repository.dart';

class UpdateBusinessSettingsUseCase {
  const UpdateBusinessSettingsUseCase(this._repository);

  final BusinessSettingsRepository _repository;

  Future<BusinessSettingsEntity> call(UpdateBusinessSettingsParams params) {
    return _repository.updateBusinessSettings(params);
  }
}
