import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/features/account/domain/params/change_password_params.dart';
import 'package:menuloq/features/account/domain/usecases/change_password_use_case.dart';

import 'change_password_event.dart';
import 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc({required ChangePasswordUseCase changePasswordUseCase})
      : _changePasswordUseCase = changePasswordUseCase,
        super(const ChangePasswordState()) {
    on<ChangePasswordSubmitted>(_onSubmitted);
  }

  final ChangePasswordUseCase _changePasswordUseCase;

  Future<void> _onSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    if (state.status == ChangePasswordStatus.loading) return;

    emit(
      state.copyWith(
        status: ChangePasswordStatus.loading,
        clearMessage: true,
      ),
    );

    try {
      final message = await _changePasswordUseCase(
        ChangePasswordParams(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
          newPasswordConfirmation: event.newPasswordConfirmation,
        ),
      );

      emit(
        state.copyWith(
          status: ChangePasswordStatus.success,
          message: message,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          message: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
