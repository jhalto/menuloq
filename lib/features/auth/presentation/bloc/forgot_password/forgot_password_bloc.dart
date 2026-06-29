import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/features/auth/domain/usecases/get_otp_use_case.dart';

import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc({required this.getOtpUseCase})
      : super(const ForgotPasswordState()) {
    on<ForgotPasswordOtpRequested>(_onOtpRequested);
  }

  final GetOtpUseCase getOtpUseCase;

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
      await getOtpUseCase(email: email);

      emit(
        state.copyWith(
          status: ForgotPasswordStatus.success,
          message: 'A 4-digit verification code has been sent.',
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          message: e.message,
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
