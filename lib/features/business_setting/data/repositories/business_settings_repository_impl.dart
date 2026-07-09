
import 'package:menuloq/features/business_setting/domain/intities/business_settings_entity.dart';
import 'package:menuloq/features/business_setting/domain/params/update_business_settings_params.dart';
import 'package:menuloq/features/business_setting/domain/repository/business_settings_repository.dart';

import '../data_sources/remote/business_settings_remote_data_source.dart';

class BusinessSettingsRepositoryImpl implements BusinessSettingsRepository {
  BusinessSettingsRepositoryImpl(this._remoteDataSource);

  final BusinessSettingsRemoteDataSource _remoteDataSource;

  BusinessSettingsEntity? _cachedSettings;
  Future<BusinessSettingsEntity>? _runningRequest;
  int _cacheGeneration = 0;

  @override
  Future<BusinessSettingsEntity> getBusinessSettings({
    bool forceRefresh = false,
  }) {
    if (!forceRefresh && _cachedSettings != null) {
      return Future.value(_cachedSettings);
    }

    if (!forceRefresh && _runningRequest != null) {
      return _runningRequest!;
    }

    final generation = _cacheGeneration;
    final request = _remoteDataSource.getBusinessSettings().then((settings) {
      if (generation == _cacheGeneration) {
        _cachedSettings = settings;
      }
      return settings;
    }).whenComplete(() {
      _runningRequest = null;
    });

    _runningRequest = request;

    return request;
  }

  @override
  Future<BusinessSettingsEntity> updateBusinessSettings(
    UpdateBusinessSettingsParams params,
  ) async {
    final updatedSettings = await _remoteDataSource.updateBusinessSettings(
      params,
    );

    if (updatedSettings != null) {
      _cachedSettings = updatedSettings;
      return updatedSettings;
    }

    return getBusinessSettings(forceRefresh: true);
  }

  @override
  void clearCache() {
    _cacheGeneration++;
    _cachedSettings = null;
    _runningRequest = null;
  }
}
