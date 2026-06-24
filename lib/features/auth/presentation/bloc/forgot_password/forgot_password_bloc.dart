import 'package:flutter_bloc/flutter_bloc.dart';

import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(const ForgotPasswordState()) {
    on<ForgotPasswordOtpRequested>(_onOtpRequested);
  }

  // final SendForgotPasswordOtpUseCase sendForgotPasswordOtpUseCase;

  Future<void> _onOtpRequested(
    ForgotPasswordOtpRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final email = event.email.trim();

    emit(
      state.copyWith(
        status: ForgotPasswordStatus.loading,
        email: email,
        clearMessage: true,
      ),
    );

    try {
      // await sendForgotPasswordOtpUseCase(email: email);

      await Future.delayed(const Duration(seconds: 1));

      // Demo validation. Remove after API integration.
      if (email == 'notfound@menuloq.com') {
        emit(
          state.copyWith(
            status: ForgotPasswordStatus.failure,
            message: 'No account found with this email address.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: ForgotPasswordStatus.success,
          message: 'A 4-digit verification code has been sent.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}