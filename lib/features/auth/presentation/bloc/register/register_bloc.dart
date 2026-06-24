import 'package:flutter_bloc/flutter_bloc.dart';

import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(const RegisterState()) {
    on<RegisterBusinessStepSubmitted>(_onBusinessStepSubmitted);
    on<RegisterBackToBusinessRequested>(_onBackToBusinessRequested);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  // final RegisterUseCase registerUseCase;

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
        businessSlug: event.businessSlug,
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
      // final result = await registerUseCase(
      //   businessName: state.businessName,
      //   businessSlug: state.businessSlug,
      //   ownerName: state.ownerName,
      //   email: state.email,
      //   mobileNumber: state.mobileNumber,
      //   password: event.password,
      // );

      await Future.delayed(const Duration(seconds: 1));

      if (state.email == 'exist@menuloq.com') {
        emit(
          state.copyWith(
            status: RegisterStatus.failure,
            message: 'This email address is already registered.',
          ),
        );
        return;
      }

      emit(state.copyWith(status: RegisterStatus.success));
    } catch (_) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}