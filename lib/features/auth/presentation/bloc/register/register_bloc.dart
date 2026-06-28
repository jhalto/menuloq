import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/features/auth/domain/usecases/get_otp_use_case.dart';
import 'package:menuloq/features/auth/domain/usecases/register_use_case.dart';

import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required RegisterUseCase registerUseCase,
    required GetOtpUseCase getOtpUseCase,
  }) : _registerUseCase = registerUseCase,
       _getOtpUseCase = getOtpUseCase,
       super(const RegisterState()) {
    on<RegisterBusinessStepSubmitted>(_onBusinessStepSubmitted);
    on<RegisterBackToBusinessRequested>(_onBackToBusinessRequested);
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

      // 2. Send OTP
      await _getOtpUseCase(email: event.email);

      // 3. Success
      emit(state.copyWith(status: RegisterStatus.success, email: event.email));
    } catch (e) {
      emit(
        state.copyWith(status: RegisterStatus.failure, message: e.toString()),
      );
    }
  }
}
