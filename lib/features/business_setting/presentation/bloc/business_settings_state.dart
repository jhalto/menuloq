
import 'package:menuloq/features/business_setting/domain/intities/business_settings_entity.dart';

enum BusinessSettingsStatus {
  initial,
  loading,
  success,
  failure,
  saving,
}

enum BusinessSettingsTab {
  profile,
  regional,
  orderDelivery,
  availability,
}

class BusinessSettingsState {
  const BusinessSettingsState({
    this.status = BusinessSettingsStatus.initial,
    this.selectedTab = BusinessSettingsTab.profile,
    this.settings,
    this.message,
  });

  final BusinessSettingsStatus status;
  final BusinessSettingsTab selectedTab;
  final BusinessSettingsEntity? settings;
  final String? message;

  bool get isLoading => status == BusinessSettingsStatus.loading;
  bool get isSaving => status == BusinessSettingsStatus.saving;
  bool get hasSettings => settings != null;

  BusinessSettingsState copyWith({
    BusinessSettingsStatus? status,
    BusinessSettingsTab? selectedTab,
    BusinessSettingsEntity? settings,
    String? message,
    bool clearMessage = false,
  }) {
    return BusinessSettingsState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      settings: settings ?? this.settings,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}