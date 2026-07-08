import 'package:flutter/foundation.dart';
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
        businessAddress: event.businessAddress,
        termsAccepted: false,
        password: '',
        passwordConfirmation: '',
      );
    } on AppException catch (e) {
      final errors = e.errors ?? {};

      if (kDebugMode) {
        debugPrint('========== REGISTER FIRST STEP ERROR ==========');
        debugPrint('Bloc Message: ${e.message}');
        debugPrint('Bloc Errors: $errors');
        debugPrint('===============================================');
      }

      final userNameError = errors['user_name']?.first;
      final emailError =
          errors['email']?.first ?? errors['business_email']?.first;
      final mobileError =
          errors['mobile_number']?.first ??
          errors['business_mobile_number']?.first;
      final businessNameError = errors['business_name']?.first;
      final ownerNameError = errors['owner_name']?.first;
      final businessAddressError = errors['business_address']?.first;
      final hasBusinessFieldError =
          businessNameError != null ||
          userNameError != null ||
          ownerNameError != null ||
          emailError != null ||
          mobileError != null ||
          businessAddressError != null;
      final hasSecurityFieldError =
          errors.containsKey('password') ||
          errors.containsKey('password_confirmation') ||
          errors.containsKey('terms_accepted');
      if (hasBusinessFieldError || !hasSecurityFieldError) {
        emit(
          state.copyWith(
            status: RegisterStatus.failure,
            subdomainError: userNameError,
            emailError: emailError,
            mobileError: mobileError,
            businessAddressError: businessAddressError,
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
        businessAddress: event.businessAddress,
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
      if (kDebugMode) {
        debugPrint('========== REGISTER FINAL SUBMIT ==========');
        debugPrint('businessName: ${event.businessName}');
        debugPrint('userName: ${event.userName}');
        debugPrint('ownerName: ${event.ownerName}');
        debugPrint('email: ${event.email}');
        debugPrint('mobileNumber: ${event.mobileNumber}');
        debugPrint('businessAddress: ${event.businessAddress}');
        debugPrint('termsAccepted: ${event.termsAccepted}');
        debugPrint('password: ***');
        debugPrint('passwordConfirmation: ***');
        debugPrint('===========================================');
      }

      // 1. Register
      await _registerUseCase(
        businessName: event.businessName,
        userName: event.userName,
        ownerName: event.ownerName,
        email: event.email,
        mobileNumber: event.mobileNumber,
        businessAddress: event.businessAddress,
        termsAccepted: event.termsAccepted,
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
