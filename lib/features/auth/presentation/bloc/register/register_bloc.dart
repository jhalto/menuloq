import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/features/auth/domain/usecases/get_otp_use_case.dart';
import 'package:menuloq/features/auth/domain/usecases/register_use_case.dart';

import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required RegisterUseCase registerUseCase,
    required GetOtpUseCase getOtpUseCase,
  }) : this._(registerUseCase: registerUseCase, getOtpUseCase: getOtpUseCase);

  RegisterBloc._({required this._registerUseCase, required this._getOtpUseCase})
    : super(const RegisterState()) {
    on<RegisterBusinessStepSubmitted>(_onBusinessStepSubmitted);
    on<RegisterBackToBusinessRequested>(_onBackToBusinessRequested);
    on<RegisterBusinessFieldsChanged>(_onBusinessFieldsChanged);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  final RegisterUseCase _registerUseCase;
  final GetOtpUseCase _getOtpUseCase;
  Future<void> _onBusinessStepSubmitted(
    RegisterBusinessStepSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(
      state.copyWith(
        status: RegisterStatus.loading,
        clearMessage: true,
        clearFieldErrors: true,
      ),
    );

    try {
      await _registerUseCase(
        businessName: event.businessName,
        userName: event.subdomain,
        ownerName: event.ownerName,
        email: event.email,
        mobileNumber: event.mobileNumber,
        password: '',
        passwordConfirmation: '',
      );
    } on AppException catch (e) {
      final errors = e.errors ?? {};

      final userNameError = errors['user_name']?.first;
      final emailError = errors['business_email']?.first;
      final mobileError = errors['business_mobile_number']?.first;

      final onlyPasswordError =
          errors.isNotEmpty &&
          errors.keys.every(
            (key) => key == 'password' || key == 'password_confirmation',
          );

      if (onlyPasswordError) {
        // allow continue
      } else {
        emit(
          state.copyWith(
            status: RegisterStatus.failure,
            subdomainError: userNameError,
            emailError: emailError,
            mobileError: mobileError,
            message: e.message,
          ),
        );
        return;
      }
    }

    emit(
      state.copyWith(
        step: RegisterStep.security,
        status: RegisterStatus.initial,
        clearMessage: true,
        businessName: event.businessName,
        subdomain: event.subdomain,
        ownerName: event.ownerName,
        email: event.email,
        mobileNumber: event.mobileNumber,
      ),
    );
  }

  Future<void> _onBackToBusinessRequested(
    RegisterBackToBusinessRequested event,
    Emitter<RegisterState> emit,
  ) async {
    emit(
      state.copyWith(
        step: RegisterStep.business,
        status: RegisterStatus.initial,
        clearMessage: true,
      ),
    );
  }

  void _onBusinessFieldsChanged(
    RegisterBusinessFieldsChanged event,
    Emitter<RegisterState> emit,
  ) {
    if (state.emailError == null &&
        state.subdomainError == null &&
        state.mobileError == null &&
        state.message == null) {
      return;
    }

    emit(
      state.copyWith(
        status: RegisterStatus.initial,
        clearMessage: true,
        clearFieldErrors: true,
      ),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: RegisterStatus.loading, clearMessage: true));

    try {
      // 1. Register
      await _registerUseCase(
        businessName: event.businessName,
        userName: event.userName,
        ownerName: event.ownerName,
        email: event.email,
        mobileNumber: event.mobileNumber,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );
    } on AppException catch (e) {
      emit(state.copyWith(status: RegisterStatus.failure, message: e.message));
      return;
    } catch (_) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          message: 'Registration failed. Please try again.',
        ),
      );
      return;
    }

    try {
      // 2. Send OTP (non-blocking — user can resend from verify screen)
      await _getOtpUseCase(email: event.email);
    } catch (_) {
      // OTP send failed, but registration succeeded.
      // User can request a new OTP from the verify email screen.
    }

    // 3. Navigate to verify email
    emit(state.copyWith(status: RegisterStatus.success, email: event.email));
  }
}
