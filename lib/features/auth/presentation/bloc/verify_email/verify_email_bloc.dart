import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'verify_email_event.dart';
import 'verify_email_state.dart';

class VerifyEmailBloc extends Bloc<VerifyEmailEvent, VerifyEmailState> {
  VerifyEmailBloc() : super(const VerifyEmailState()) {
    on<VerifyEmailStarted>(_onStarted);
    on<VerifyEmailTimerTicked>(_onTimerTicked);
    on<VerifyEmailOtpSubmitted>(_onOtpSubmitted);
    on<VerifyEmailResendRequested>(_onResendRequested);
  }

  Timer? _timer;

  // final VerifyEmailUseCase verifyEmailUseCase;
  // final ResendOtpUseCase resendOtpUseCase;

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const VerifyEmailTimerTicked());
    });
  }

  Future<void> _onStarted(
    VerifyEmailStarted event,
    Emitter<VerifyEmailState> emit,
  ) async {
    emit(
      VerifyEmailState(
        email: event.email,
        status: VerifyEmailStatus.initial,
        expiresIn: 600,
        resendIn: 60,
      ),
    );

    _startTimer();
  }

  Future<void> _onTimerTicked(
    VerifyEmailTimerTicked event,
    Emitter<VerifyEmailState> emit,
  ) async {
    final nextExpiresIn = state.expiresIn > 0 ? state.expiresIn - 1 : 0;
    final nextResendIn = state.resendIn > 0 ? state.resendIn - 1 : 0;

    if (nextExpiresIn == 0 &&
        state.status != VerifyEmailStatus.success &&
        state.status != VerifyEmailStatus.expired) {
      emit(
        state.copyWith(
          expiresIn: nextExpiresIn,
          resendIn: nextResendIn,
          status: VerifyEmailStatus.expired,
          message: 'OTP has expired. Please request a new OTP.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        expiresIn: nextExpiresIn,
        resendIn: nextResendIn,
      ),
    );

    if (nextExpiresIn == 0 && nextResendIn == 0) {
      _timer?.cancel();
    }
  }

  Future<void> _onOtpSubmitted(
    VerifyEmailOtpSubmitted event,
    Emitter<VerifyEmailState> emit,
  ) async {
    final code = event.code.trim();

    if (state.isExpired) {
      emit(
        state.copyWith(
          status: VerifyEmailStatus.expired,
          message: 'OTP has expired. Please request a new OTP.',
        ),
      );
      return;
    }

    if (code.length != 4) {
      emit(
        state.copyWith(
          status: VerifyEmailStatus.failure,
          message: 'Please enter the 4-digit OTP code.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: VerifyEmailStatus.loading,
        clearMessage: true,
      ),
    );

    try {
      // final result = await verifyEmailUseCase(
      //   email: state.email,
      //   code: code,
      // );

      await Future.delayed(const Duration(seconds: 1));

      // Demo OTP. Replace with API response.
      if (code == '3810') {
        _timer?.cancel();

        emit(
          state.copyWith(
            status: VerifyEmailStatus.success,
            message: 'Email verified successfully.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: VerifyEmailStatus.failure,
          message: 'The OTP code is invalid.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: VerifyEmailStatus.failure,
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onResendRequested(
    VerifyEmailResendRequested event,
    Emitter<VerifyEmailState> emit,
  ) async {
    if (!state.canResend) return;

    emit(
      state.copyWith(
        status: VerifyEmailStatus.resendLoading,
        clearMessage: true,
      ),
    );

    try {
      // await resendOtpUseCase(email: state.email);

      await Future.delayed(const Duration(seconds: 1));

      emit(
        state.copyWith(
          status: VerifyEmailStatus.resendSuccess,
          message: 'A new OTP code has been sent.',
          expiresIn: 600,
          resendIn: 60,
        ),
      );

      _startTimer();
    } catch (_) {
      emit(
        state.copyWith(
          status: VerifyEmailStatus.failure,
          message: 'Could not resend OTP. Please try again.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}