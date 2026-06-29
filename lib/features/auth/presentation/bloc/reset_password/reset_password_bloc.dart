import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/features/auth/domain/usecases/change_password_use_case.dart';
import 'package:menuloq/features/auth/domain/usecases/get_otp_use_case.dart';

import 'reset_password_event.dart';
import 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc({
    required this.changePasswordUseCase,
    required this.getOtpUseCase,
  }) : super(const ResetPasswordState()) {
    on<ResetPasswordStarted>(_onStarted);
    on<ResetPasswordSubmitted>(_onSubmitted);
    on<ResetPasswordOtpRequested>(_onOtpRequested);
  }

  final ChangePasswordUseCase changePasswordUseCase;
  final GetOtpUseCase getOtpUseCase;

  Future<void> _onStarted(
    ResetPasswordStarted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(
      state.copyWith(
        email: event.email,
        status: ResetPasswordStatus.initial,
        clearMessage: true,
      ),
    );
  }

  Future<void> _onSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ResetPasswordStatus.loading,
        email: event.email.trim(),
        clearMessage: true,
      ),
    );

    try {
      if (event.password != event.confirmPassword) {
        emit(
          state.copyWith(
            status: ResetPasswordStatus.passwordMismatch,
            message: 'Password confirmation does not match.',
          ),
        );
        return;
      }

      await changePasswordUseCase(
        email: event.email.trim(),
        otp: event.code.trim(),
        password: event.password,
        passwordConfirmation: event.confirmPassword,
      );

      emit(
        state.copyWith(
          status: ResetPasswordStatus.success,
          message: 'Password reset successfully.',
        ),
      );
    } on AppException catch (e) {
      final msg = e.message.toLowerCase();

      if (msg.contains('expired') || msg.contains('expire')) {
        emit(
          state.copyWith(
            status: ResetPasswordStatus.expired,
            message: e.message,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: ResetPasswordStatus.failure,
          message: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ResetPasswordStatus.failure,
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onOtpRequested(
    ResetPasswordOtpRequested event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ResetPasswordStatus.loading,
        email: event.email.trim(),
        clearMessage: true,
      ),
    );

    try {
      await getOtpUseCase(email: event.email.trim());

      emit(
        state.copyWith(
          status: ResetPasswordStatus.initial,
          message: 'A new OTP has been sent.',
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: ResetPasswordStatus.failure,
          message: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ResetPasswordStatus.failure,
          message: 'Could not request a new OTP. Please try again.',
        ),
      );
    }
  }
}
