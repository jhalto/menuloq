import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/features/account/domain/entities/my_account_validation_exception.dart';
import 'package:menuloq/features/account/domain/usecases/get_my_account_use_case.dart';
import 'package:menuloq/features/account/domain/usecases/update_my_account_use_case.dart';

import 'my_account_event.dart';
import 'my_account_state.dart';

class MyAccountBloc extends Bloc<MyAccountEvent, MyAccountState> {
  MyAccountBloc({
    required GetMyAccountUseCase getMyAccountUseCase,
    required UpdateMyAccountUseCase updateMyAccountUseCase,
  })  : _getMyAccountUseCase = getMyAccountUseCase,
        _updateMyAccountUseCase = updateMyAccountUseCase,
        super(const MyAccountState()) {
    on<MyAccountStarted>(_onStarted);
    on<MyAccountRefreshRequested>(_onRefreshRequested);
    on<MyAccountSaveRequested>(_onSaveRequested);
    on<MyAccountMessageDismissed>(_onMessageDismissed);
    on<MyAccountFieldsChanged>(_onFieldsChanged);
  }

  final GetMyAccountUseCase _getMyAccountUseCase;
  final UpdateMyAccountUseCase _updateMyAccountUseCase;

  bool _isLoadRunning = false;
  bool _isSaveRunning = false;

  Future<void> _onStarted(
    MyAccountStarted event,
    Emitter<MyAccountState> emit,
  ) async {
    await _loadAccount(emit);
  }

  Future<void> _onRefreshRequested(
    MyAccountRefreshRequested event,
    Emitter<MyAccountState> emit,
  ) async {
    await _loadAccount(emit, forceRefresh: true);
  }

  Future<void> _onSaveRequested(
    MyAccountSaveRequested event,
    Emitter<MyAccountState> emit,
  ) async {
    if (_isSaveRunning) return;

    _isSaveRunning = true;

    emit(
      state.copyWith(
        status: MyAccountStatus.saving,
        clearErrorMessage: true,
        clearSuccessMessage: true,
        clearFieldErrors: true,
      ),
    );

    try {
      final account = await _updateMyAccountUseCase(event.params);

      emit(
        state.copyWith(
          status: MyAccountStatus.success,
          account: account,
          successMessage: 'Account details updated successfully.',
          clearErrorMessage: true,
          clearFieldErrors: true,
        ),
      );
    } on MyAccountValidationException catch (error) {
      emit(
        state.copyWith(
          status: MyAccountStatus.failure,
          errorMessage: error.message,
          fieldErrors: error.errors,
          clearSuccessMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: MyAccountStatus.failure,
          errorMessage: error.toString(),
          clearSuccessMessage: true,
          clearFieldErrors: true,
        ),
      );
    } finally {
      _isSaveRunning = false;
    }
  }

  void _onMessageDismissed(
    MyAccountMessageDismissed event,
    Emitter<MyAccountState> emit,
  ) {
    emit(
      state.copyWith(
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );
  }

  void _onFieldsChanged(
    MyAccountFieldsChanged event,
    Emitter<MyAccountState> emit,
  ) {
    if (state.fieldErrors.isEmpty) return;
    emit(
      state.copyWith(
        clearErrorMessage: true,
        clearFieldErrors: true,
      ),
    );
  }

  Future<void> _loadAccount(
    Emitter<MyAccountState> emit, {
    bool forceRefresh = false,
  }) async {
    if (_isLoadRunning) return;
    if (!forceRefresh && state.account != null) return;

    _isLoadRunning = true;

    emit(
      state.copyWith(
        status: MyAccountStatus.loading,
        clearErrorMessage: true,
        clearSuccessMessage: true,
        clearFieldErrors: true,
      ),
    );

    try {
      final account = await _getMyAccountUseCase(forceRefresh: forceRefresh);

      emit(
        state.copyWith(
          status: MyAccountStatus.success,
          account: account,
          clearErrorMessage: true,
          clearSuccessMessage: true,
          clearFieldErrors: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: MyAccountStatus.failure,
          errorMessage: error.toString(),
          clearSuccessMessage: true,
          clearFieldErrors: true,
        ),
      );
    } finally {
      _isLoadRunning = false;
    }
  }
}
