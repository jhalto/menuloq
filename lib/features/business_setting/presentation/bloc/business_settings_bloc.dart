import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/features/business_setting/domain/usecases/get_bussiness_settings_use_case.dart';
import 'package:menuloq/features/business_setting/domain/usecases/update_business_settings_use_case.dart';

import 'business_settings_event.dart';
import 'business_settings_state.dart';

class BusinessSettingsBloc
    extends Bloc<BusinessSettingsEvent, BusinessSettingsState> {
  BusinessSettingsBloc({
    required GetBusinessSettingsUseCase getBusinessSettingsUseCase,
    required UpdateBusinessSettingsUseCase updateBusinessSettingsUseCase,
  })  : _getBusinessSettingsUseCase = getBusinessSettingsUseCase,
        _updateBusinessSettingsUseCase = updateBusinessSettingsUseCase,
        super(const BusinessSettingsState()) {
    on<BusinessSettingsStarted>(_onStarted);
    on<BusinessSettingsRefreshRequested>(_onRefreshRequested);
    on<BusinessSettingsTabChanged>(_onTabChanged);
    on<BusinessSettingsSaveRequested>(_onSaveRequested);
  }

  final GetBusinessSettingsUseCase _getBusinessSettingsUseCase;
  final UpdateBusinessSettingsUseCase _updateBusinessSettingsUseCase;

  bool _isRequestRunning = false;
  bool _isSaveRunning = false;

  Future<void> _onStarted(
    BusinessSettingsStarted event,
    Emitter<BusinessSettingsState> emit,
  ) async {
    await _loadSettings(emit);
  }

  Future<void> _onRefreshRequested(
    BusinessSettingsRefreshRequested event,
    Emitter<BusinessSettingsState> emit,
  ) async {
    await _loadSettings(
      emit,
      forceRefresh: true,
    );
  }

  void _onTabChanged(
    BusinessSettingsTabChanged event,
    Emitter<BusinessSettingsState> emit,
  ) {
    emit(
      state.copyWith(
        selectedTab: event.tab,
        clearMessage: true,
      ),
    );
  }

  Future<void> _onSaveRequested(
    BusinessSettingsSaveRequested event,
    Emitter<BusinessSettingsState> emit,
  ) async {
    if (_isSaveRunning) return;

    _isSaveRunning = true;
    emit(
      state.copyWith(
        status: BusinessSettingsStatus.saving,
        clearMessage: true,
      ),
    );

    try {
      final settings = await _updateBusinessSettingsUseCase(event.params);

      emit(
        state.copyWith(
          status: BusinessSettingsStatus.success,
          settings: settings,
          message: 'Business settings updated successfully.',
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: BusinessSettingsStatus.failure,
          message: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: BusinessSettingsStatus.failure,
          message: 'Something went wrong. Please try again.',
        ),
      );
    } finally {
      _isSaveRunning = false;
    }
  }

  Future<void> _loadSettings(
    Emitter<BusinessSettingsState> emit, {
    bool forceRefresh = false,
  }) async {
    if (_isRequestRunning) return;

    if (!forceRefresh && state.settings != null) return;

    _isRequestRunning = true;

    emit(
      state.copyWith(
        status: BusinessSettingsStatus.loading,
        clearMessage: true,
      ),
    );

    try {
      final settings = await _getBusinessSettingsUseCase(
        forceRefresh: forceRefresh,
      );

      emit(
        state.copyWith(
          status: BusinessSettingsStatus.success,
          settings: settings,
          clearMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BusinessSettingsStatus.failure,
          message: e.toString(),
        ),
      );
    } finally {
      _isRequestRunning = false;
    }
  }
}
