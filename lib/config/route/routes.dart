import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/route/route_name.dart';
import 'package:menuloq/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:menuloq/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:menuloq/features/auth/domain/usecases/get_otp_use_case.dart';
import 'package:menuloq/features/auth/domain/usecases/register_use_case.dart';
import 'package:menuloq/features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:menuloq/features/auth/presentation/bloc/login/auth_bloc.dart';
import 'package:menuloq/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:menuloq/features/auth/presentation/bloc/reset_password/reset_password_bloc.dart';
import 'package:menuloq/features/auth/presentation/bloc/verify_email/verify_email_bloc.dart';
import 'package:menuloq/features/auth/presentation/views/forgot_password_view.dart';
import 'package:menuloq/features/auth/presentation/views/login_view.dart';
import 'package:menuloq/features/auth/presentation/views/register_view.dart';
import 'package:menuloq/features/auth/presentation/views/reset_password_view.dart';
import 'package:menuloq/features/auth/presentation/views/verify_email_view.dart';

class AppRoutes {
  const AppRoutes._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initial:
      case Routes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(),
            child: const LoginView(),
          ),
        );

      case Routes.register:
        final remoteDataSource = AuthRemoteDataSourceImpl();
        final repository = AuthRepositoryImpl(remoteDataSource);

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => RegisterBloc(
              registerUseCase: RegisterUseCase(repository),
              getOtpUseCase: GetOtpUseCase(repository),
            ),
            child: const RegisterView(),
          ),
        );
      case Routes.veriflyEmail:
        final email = settings.arguments as String?;

        if (email == null || email.trim().isEmpty) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const Scaffold(
              body: Center(child: Text('Email is required for verification.')),
            ),
          );
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider<VerifyEmailBloc>(
            create: (_) => VerifyEmailBloc(),
            child: VerifyEmailView(email: email),
          ),
        );

      case Routes.forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider<ForgotPasswordBloc>(
            create: (_) => ForgotPasswordBloc(),
            child: const ForgotPasswordView(),
          ),
        );
      case Routes.resetPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider<ResetPasswordBloc>(
            create: (_) => ResetPasswordBloc(),
            child: const ResetPasswordView(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Page not found"))),
        );
    }
  }
}
