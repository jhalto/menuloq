import 'business_settings_state.dart';
import 'package:menuloq/features/business_setting/domain/params/update_business_settings_params.dart';

abstract class BusinessSettingsEvent {
  const BusinessSettingsEvent();
}

class BusinessSettingsStarted extends BusinessSettingsEvent {
  const BusinessSettingsStarted();
}

class BusinessSettingsRefreshRequested extends BusinessSettingsEvent {
  const BusinessSettingsRefreshRequested();
}

class BusinessSettingsTabChanged extends BusinessSettingsEvent {
  const BusinessSettingsTabChanged(this.tab);

  final BusinessSettingsTab tab;
}

class BusinessSettingsSaveRequested extends BusinessSettingsEvent {
  const BusinessSettingsSaveRequested(this.params);

  final UpdateBusinessSettingsParams params;
}

class BusinessSettingsFieldsChanged extends BusinessSettingsEvent {
  const BusinessSettingsFieldsChanged();
}
