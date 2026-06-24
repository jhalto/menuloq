import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<VerifyEmailRequested>(_onVerifyEmailRequested);
  }

  // final LoginUseCase loginUseCase;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.loading));

    try {
      // final result = await loginUseCase(
      //   email: event.email,
      //   password: event.password,
      // );

      await Future.delayed(const Duration(seconds: 1));

      // Demo logic. Replace with real API/usecase result.
      if (event.email == 'inactive@test.com') {
        emit(
          const AuthState(
            status: AuthStatus.inactive,
            message: 'Your account is inactive. Please contact support.',
          ),
        );
        return;
      }

      if (event.email == 'verify@test.com') {
        emit(
          const AuthState(
            status: AuthStatus.emailNotVerified,
            message: 'Please verify your email address before signing in.',
          ),
        );
        return;
      }

      if (event.email == 'admin@menuloq.com' && event.password == '123456') {
        emit(const AuthState(status: AuthStatus.success));
        return;
      }

      emit(
        const AuthState(
          status: AuthStatus.failure,
          message: 'Email or password is incorrect.',
        ),
      );
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