import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/route/route_name.dart';
import 'package:menuloq/core/di/dependency_factory.dart';
import 'package:menuloq/features/auth/domain/enums/verify_email_type.dart';
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
import 'package:menuloq/features/dashboard/presentation/views/dashboard_view.dart';

class AppRoutes {
  const AppRoutes._();

  static final DependencyFactory _di = DependencyFactory.instance;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initial:
      case Routes.login:
        return _buildRoute(
          settings: settings,
          child: BlocProvider<AuthBloc>(
            create: (_) => _di.createAuthBloc(),
            child: const LoginView(),
          ),
        );

      case Routes.register:
        return _buildRoute(
          settings: settings,
          child: BlocProvider<RegisterBloc>(
            create: (_) => _di.createRegisterBloc(),
            child: const RegisterView(),
          ),
        );

      case Routes.verifyEmail:
        final args = settings.arguments;

        String email = '';
        VerifyEmailType type = VerifyEmailType.registration;

        if (args is String) {
          email = args.trim();
        } else if (args is Map<String, dynamic>) {
          email = (args['email'] as String? ?? '').trim();

          final rawType = args['type'];

          if (rawType is VerifyEmailType) {
            type = rawType;
          } else if (rawType == 'forgot_password') {
            type = VerifyEmailType.forgotPassword;
          } else {
            type = VerifyEmailType.registration;
          }
        }

        if (email.isEmpty) {
          return _buildRoute(
            settings: settings,
            child: const Scaffold(
              body: Center(child: Text('Email is required for verification.')),
            ),
          );
        }

        return _buildRoute(
          settings: settings,
          child: BlocProvider<VerifyEmailBloc>(
            create: (_) => _di.createVerifyEmailBloc(),
            child: VerifyEmailView(email: email, type: type),
          ),
        );

      case Routes.resetPassword:
        final args = settings.arguments;

        String email = '';
        String otp = '';

        if (args is Map<String, dynamic>) {
          email = (args['email'] as String? ?? '').trim();
          otp = (args['otp'] as String? ?? '').trim();
        }

        if (email.isEmpty || otp.isEmpty) {
          return _buildRoute(
            settings: settings,
            child: const Scaffold(
              body: Center(
                child: Text('Email and OTP are required for password reset.'),
              ),
            ),
          );
        }

        return _buildRoute(
          settings: settings,
          child: BlocProvider<ResetPasswordBloc>(
            create: (_) => _di.createResetPasswordBloc(),
            child: ResetPasswordView(initialEmail: email, otp: otp),
          ),
        );

      case Routes.forgotPassword:
        return _buildRoute(
          settings: settings,
          child: BlocProvider<ForgotPasswordBloc>(
            create: (_) => _di.createForgotPasswordBloc(),
            child: const ForgotPasswordView(),
          ),
        );

      case Routes.resetPassword:
        final email = settings.arguments as String?;

        if (email == null || email.trim().isEmpty) {
          return _buildRoute(
            settings: settings,
            child: const Scaffold(
              body: Center(
                child: Text('Email is required for password reset.'),
              ),
            ),
          );
        }

        return _buildRoute(
          settings: settings,
          child: BlocProvider<ResetPasswordBloc>(
            create: (_) => _di.createResetPasswordBloc(),
            child: ResetPasswordView(initialEmail: email),
          ),
        );

      case Routes.dashboard:
        return _buildRoute(settings: settings, child: const DashboardView());

      default:
        return _buildRoute(
          settings: settings,
          child: const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute({
    required RouteSettings settings,
    required Widget child,
  }) {
    return MaterialPageRoute(settings: settings, builder: (_) => child);
  }
}
