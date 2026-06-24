import 'package:flutter_bloc/flutter_bloc.dart';

import 'reset_password_event.dart';
import 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc() : super(const ResetPasswordState()) {
    on<ResetPasswordStarted>(_onStarted);
    on<ResetPasswordSubmitted>(_onSubmitted);
    on<ResetPasswordOtpRequested>(_onOtpRequested);
  }

  // final ResetPasswordUseCase resetPasswordUseCase;
  // final ResendOtpUseCase resendOtpUseCase;

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

      // await resetPasswordUseCase(
      //   email: event.email,
      //   otp: event.code,
      //   password: event.password,
      // );

      await Future.delayed(const Duration(seconds: 1));

      // Demo cases. Replace with API response.
      if (event.code == '0000') {
        emit(
          state.copyWith(
            status: ResetPasswordStatus.expired,
            message: 'OTP has expired. Please request a new OTP.',
          ),
        );
        return;
      }

      if (event.code != '3810') {
        emit(
          state.copyWith(
            status: ResetPasswordStatus.failure,
            message: 'The OTP code is invalid.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: ResetPasswordStatus.success,
          message: 'Password reset successfully.',
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
      // await resendOtpUseCase(email: event.email);

      await Future.delayed(const Duration(seconds: 1));

      emit(
        state.copyWith(
          status: ResetPasswordStatus.initial,
          message: 'A new OTP has been sent.',
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