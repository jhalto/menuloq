import 'package:menuloq/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:menuloq/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:menuloq/features/auth/domain/usecases/change_password_use_case.dart';
import 'package:menuloq/features/auth/domain/usecases/get_otp_use_case.dart';
import 'package:menuloq/features/auth/domain/usecases/login_use_case.dart';
import 'package:menuloq/features/auth/domain/usecases/register_use_case.dart';
import 'package:menuloq/features/auth/domain/usecases/verify_otp_use_case.dart';
import 'package:menuloq/features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:menuloq/features/auth/presentation/bloc/login/auth_bloc.dart';
import 'package:menuloq/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:menuloq/features/auth/presentation/bloc/reset_password/reset_password_bloc.dart';
import 'package:menuloq/features/auth/presentation/bloc/verify_email/verify_email_bloc.dart';

/// Manual Dependency Injection
///
/// Data Source → Repository → Use Case → Bloc
///
/// Shared objects:
/// - DataSource
/// - Repository
/// - UseCases
///
/// New object per screen:
/// - Bloc
class DependencyFactory {
  DependencyFactory._();

  static final DependencyFactory instance = DependencyFactory._();

  // ──────────────────────────────────────────
  // Data Sources
  // ──────────────────────────────────────────

  late final AuthRemoteDataSource authRemoteDataSource =
      AuthRemoteDataSourceImpl();

  // ──────────────────────────────────────────
  // Repositories
  // ──────────────────────────────────────────

  late final AuthRepositoryImpl authRepository = AuthRepositoryImpl(
    authRemoteDataSource,
  );

  // ──────────────────────────────────────────
  // Use Cases
  // ──────────────────────────────────────────

  late final GetOtpUseCase getOtpUseCase = GetOtpUseCase(authRepository);

  late final LoginUseCase loginUseCase = LoginUseCase(authRepository);
  late final RegisterUseCase registerUseCase = RegisterUseCase(authRepository);
  late final VerifyOtpUseCase verifyOtpUseCase = VerifyOtpUseCase(
    authRepository,
  );
  late final ChangePasswordUseCase changePasswordUseCase =
      ChangePasswordUseCase(authRepository);

  // ──────────────────────────────────────────
  // Blocs
  // ──────────────────────────────────────────

  AuthBloc createAuthBloc() {
    return AuthBloc(
      loginUseCase: loginUseCase,
      getOtpUseCase: getOtpUseCase,
    );
  }

  ForgotPasswordBloc createForgotPasswordBloc() {
    return ForgotPasswordBloc(
      getOtpUseCase: getOtpUseCase,
    );
  }

  ResetPasswordBloc createResetPasswordBloc() {
    return ResetPasswordBloc(
      changePasswordUseCase: changePasswordUseCase,
      getOtpUseCase: getOtpUseCase,
    );
  }

  VerifyEmailBloc createVerifyEmailBloc() {
    return VerifyEmailBloc(
      getOtpUseCase: getOtpUseCase,
      verifyOtpUseCase: verifyOtpUseCase,
    );
  }

  RegisterBloc createRegisterBloc() {
    return RegisterBloc(
      getOtpUseCase: getOtpUseCase,
      registerUseCase: registerUseCase,
    );
  }
}
