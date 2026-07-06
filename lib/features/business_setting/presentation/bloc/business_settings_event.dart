import 'business_settings_state.dart';

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