import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:menuloq/core/network/dio_client.dart';
import 'package:menuloq/features/account/data/data_sources/remote/my_account_remote_data_source.dart';
import 'package:menuloq/features/account/data/repositories/my_account_repository_impl.dart';
import 'package:menuloq/features/account/domain/repositories/my_account_repository.dart';
import 'package:menuloq/features/account/domain/usecases/change_password_use_case.dart';
import 'package:menuloq/features/account/domain/usecases/get_my_account_use_case.dart';
import 'package:menuloq/features/account/domain/usecases/update_my_account_use_case.dart';
import 'package:menuloq/features/account/presentation/bloc/change_password/change_password_bloc.dart';
import 'package:menuloq/features/account/presentation/bloc/my_account_bloc.dart';
import 'package:menuloq/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:menuloq/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:menuloq/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:menuloq/features/auth/domain/repositories/auth_repository.dart';
import 'package:menuloq/features/auth/domain/usecases/reset_password_use_case.dart';
import 'package:menuloq/features/auth/domain/usecases/get_otp_use_case.dart';
import 'package:menuloq/features/auth/domain/usecases/login_use_case.dart';
import 'package:menuloq/features/auth/domain/usecases/register_use_case.dart';
import 'package:menuloq/features/auth/domain/usecases/verify_otp_use_case.dart';
import 'package:menuloq/features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:menuloq/features/auth/presentation/bloc/login/auth_bloc.dart';
import 'package:menuloq/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:menuloq/features/auth/presentation/bloc/reset_password/reset_password_bloc.dart';
import 'package:menuloq/features/auth/presentation/bloc/verify_email/verify_email_bloc.dart';
import 'package:menuloq/features/business_setting/data/data_sources/remote/business_settings_remote_data_source.dart';
import 'package:menuloq/features/business_setting/data/repositories/business_settings_repository_impl.dart';
import 'package:menuloq/features/business_setting/domain/repository/business_settings_repository.dart';
import 'package:menuloq/features/business_setting/domain/usecases/get_bussiness_settings_use_case.dart';
import 'package:menuloq/features/business_setting/domain/usecases/update_business_settings_use_case.dart';
import 'package:menuloq/features/business_setting/presentation/bloc/business_settings_bloc.dart';
import 'package:menuloq/features/categories/data/data_sources/remote/categories_remote_data_source.dart';
import 'package:menuloq/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:menuloq/features/categories/domain/repositories/categories_repository.dart';
import 'package:menuloq/features/categories/domain/usecases/create_category_use_case.dart';
import 'package:menuloq/features/categories/domain/usecases/get_categories_use_case.dart';
import 'package:menuloq/features/categories/presentation/cubit/categories_cubit.dart';

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
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  // ──────────────────────────────────────────
  // Data Sources
  // ──────────────────────────────────────────

  late final AuthRemoteDataSource authRemoteDataSource =
      AuthRemoteDataSourceImpl();

  late final AuthLocalDataSource authLocalDataSource = AuthLocalDataSource(
    secureStorage,
  );

  late final MyAccountRemoteDataSource myAccountRemoteDataSource =
      MyAccountRemoteDataSourceImpl(dio: DioClient.dio);

  late final CategoriesRemoteDataSource categoriesRemoteDataSource =
      CategoriesRemoteDataSourceImpl(DioClient.dio);

  // ──────────────────────────────────────────
  // Repositories
  // ──────────────────────────────────────────

  late final AuthRepository authRepository = AuthRepositoryImpl(
    authRemoteDataSource,
    authLocalDataSource,
  );

  late final MyAccountRepository myAccountRepository =
      MyAccountRepositoryImpl(myAccountRemoteDataSource);

  late final CategoriesRepository categoriesRepository =
      CategoriesRepositoryImpl(categoriesRemoteDataSource);

  // ──────────────────────────────────────────
  // Use Cases
  // ──────────────────────────────────────────

  late final GetOtpUseCase getOtpUseCase = GetOtpUseCase(authRepository);

  late final LoginUseCase loginUseCase = LoginUseCase(authRepository);
  late final RegisterUseCase registerUseCase = RegisterUseCase(authRepository);
  late final VerifyOtpUseCase verifyOtpUseCase = VerifyOtpUseCase(
    authRepository,
  );
  late final ResetPasswordUseCase resetPasswordUseCase = ResetPasswordUseCase(
    authRepository,
  );

  late final GetMyAccountUseCase getMyAccountUseCase =
      GetMyAccountUseCase(myAccountRepository);

  late final UpdateMyAccountUseCase updateMyAccountUseCase =
      UpdateMyAccountUseCase(myAccountRepository);
  late final ChangePasswordUseCase changePasswordUseCase =
      ChangePasswordUseCase(myAccountRepository);

  late final GetCategoriesUseCase getCategoriesUseCase =
      GetCategoriesUseCase(categoriesRepository);
  late final CreateCategoryUseCase createCategoryUseCase =
      CreateCategoryUseCase(categoriesRepository);

  // ──────────────────────────────────────────
  // Blocs
  // ──────────────────────────────────────────

  AuthBloc createAuthBloc() {
    return AuthBloc(loginUseCase: loginUseCase, getOtpUseCase: getOtpUseCase);
  }

  ForgotPasswordBloc createForgotPasswordBloc() {
    return ForgotPasswordBloc(getOtpUseCase: getOtpUseCase);
  }

  ResetPasswordBloc createResetPasswordBloc() {
    return ResetPasswordBloc(
      resetPasswordUseCase: resetPasswordUseCase,
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

  MyAccountBloc createMyAccountBloc() {
    return MyAccountBloc(
      getMyAccountUseCase: getMyAccountUseCase,
      updateMyAccountUseCase: updateMyAccountUseCase,
    );
  }

  Future<void> logout() async {
    try {
      await authRepository.logout();
    } finally {
      myAccountRepository.clearCache();
      businessSettingsRepository.clearCache();
    }
  }

  ChangePasswordBloc createChangePasswordBloc() {
    return ChangePasswordBloc(changePasswordUseCase: changePasswordUseCase);
  }

  CategoriesCubit createCategoriesCubit() {
    return CategoriesCubit(
      getCategoriesUseCase: getCategoriesUseCase,
      createCategoryUseCase: createCategoryUseCase,
    );
  }

  // business settings

  late final BusinessSettingsRemoteDataSource businessSettingsRemoteDataSource =
      BusinessSettingsRemoteDataSourceImpl(DioClient.dio);

  late final BusinessSettingsRepository businessSettingsRepository =
      BusinessSettingsRepositoryImpl(businessSettingsRemoteDataSource);

  late final GetBusinessSettingsUseCase getBusinessSettingsUseCase =
      GetBusinessSettingsUseCase(businessSettingsRepository);
  late final UpdateBusinessSettingsUseCase updateBusinessSettingsUseCase =
      UpdateBusinessSettingsUseCase(businessSettingsRepository);

  BusinessSettingsBloc createBusinessSettingsBloc() {
    return BusinessSettingsBloc(
      getBusinessSettingsUseCase: getBusinessSettingsUseCase,
      updateBusinessSettingsUseCase: updateBusinessSettingsUseCase,
    );
  }
}
