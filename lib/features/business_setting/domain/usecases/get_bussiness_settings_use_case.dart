
import 'package:menuloq/features/business_setting/domain/intities/business_settings_entity.dart';
import 'package:menuloq/features/business_setting/domain/repository/business_settings_repository.dart';

class GetBusinessSettingsUseCase {
  const GetBusinessSettingsUseCase(this._repository);

  final BusinessSettingsRepository _repository;

  Future<BusinessSettingsEntity> call({
    bool forceRefresh = false,
  }) {
    return _repository.getBusinessSettings(
      forceRefresh: forceRefresh,
    );
  }
}