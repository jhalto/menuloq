import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/features/auth/domain/usecases/get_otp_use_case.dart';
import 'package:menuloq/features/auth/domain/usecases/login_use_case.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required GetOtpUseCase getOtpUseCase,
  }) : this._(loginUseCase: loginUseCase, getOtpUseCase: getOtpUseCase);

  AuthBloc._({required this._loginUseCase, required this._getOtpUseCase})
    : super(const AuthState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<VerifyEmailRequested>(_onVerifyEmailRequested);
  }

  final LoginUseCase _loginUseCase;
  final GetOtpUseCase _getOtpUseCase;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.loading));

    try {
      final result = await _loginUseCase(
        email: event.email,
        password: event.password,
      );

      emit(
        AuthState(
          status: AuthStatus.success,
          message: result.message,
          token: result.accessToken,
        
        ),
      );
    } on AppException catch (e) {
      final message = e.message.toLowerCase();

      if (message.contains('not verified') ||
          message.contains('verify your email') ||
          message.contains('email not verified')) {
        try {
          await _getOtpUseCase(email: event.email);
        } catch (_) {
          // Ignore OTP send failure; user can resend from verify screen
        }

        emit(
          AuthState(
            status: AuthStatus.emailNotVerified,
            message: e.message,
            email: event.email,
          ),
        );
        return;
      }

      if (message.contains('inactive') ||
          message.contains('deactivated') ||
          message.contains('suspended')) {
        emit(AuthState(status: AuthStatus.inactive, message: e.message));
        return;
      }

      emit(AuthState(status: AuthStatus.failure, message: e.message));
    } catch (_) {
      emit(
        const AuthState(
          status: AuthStatus.failure,
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onVerifyEmailRequested(
    VerifyEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Call resend verification email usecase here.
  }
}
