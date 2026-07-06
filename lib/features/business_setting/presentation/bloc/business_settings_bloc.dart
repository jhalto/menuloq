import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/features/business_setting/domain/usecases/get_bussiness_settings_use_case.dart';

import 'business_settings_event.dart';
import 'business_settings_state.dart';

class BusinessSettingsBloc
    extends Bloc<BusinessSettingsEvent, BusinessSettingsState> {
  BusinessSettingsBloc({
    required GetBusinessSettingsUseCase getBusinessSettingsUseCase,
  })  : _getBusinessSettingsUseCase = getBusinessSettingsUseCase,
        super(const BusinessSettingsState()) {
    on<BusinessSettingsStarted>(_onStarted);
    on<BusinessSettingsRefreshRequested>(_onRefreshRequested);
    on<BusinessSettingsTabChanged>(_onTabChanged);
  }

  final GetBusinessSettingsUseCase _getBusinessSettingsUseCase;

  bool _isRequestRunning = false;

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