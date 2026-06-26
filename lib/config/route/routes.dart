import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/route/route_name.dart';
import 'package:menuloq/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:menuloq/features/auth/data/repositories/auth_repository_impl.dart';
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
      case Routes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(),
            child: const LoginView(),
          ),
        );

      case Routes.register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => RegisterBloc(
              registerUseCase: RegisterUseCase(
                AuthRepositoryImpl(AuthRemoteDataSourceImpl()),
              ),
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
      // case Routes.attendance:
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => BlocProvider<AttendanceBloc>(
      //       create: (_) => AttendanceBloc(
      //         repository: AttendanceRepositoryImpl(
      //           localDataSource: AttendanceLocalDataSource(),
      //         ),
      //       )..add(const AttendanceStarted()),
      //       child: const AttendanceDashboardPage(),
      //     ),
      //   );
      // case Routes.individualAttendanceReport:
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => BlocProvider<IndividualAttendanceReportBloc>(
      //       create: (_) => IndividualAttendanceReportBloc(
      //         repository: IndividualAttendanceReportRepositoryImpl(
      //           localDataSource: IndividualAttendanceReportLocalDatasource(),
      //         ),
      //       )..add(const IndividualAttendanceReportStarted()),
      //       child: const IndividualAttendanceReportPage(),
      //     ),
      //   );
      // case Routes.detailedAttendanceReport:
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => BlocProvider<DetailedAttendanceReportBloc>(
      //       create: (_) => DetailedAttendanceReportBloc(
      //         repository: DetailedAttendanceReportRepositoryImpl(
      //           localDataSource: DetailedAttendanceLocalDataSource(),
      //         ),
      //       )..add(const DetailedAttendanceReportStarted()),
      //       child: const DetailedAttendanceReportPage(),
      //     ),
      //   );
      // case Routes.departmentReport:
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => BlocProvider<DepartmentAttendanceReportBloc>(
      //       create: (_) => DepartmentAttendanceReportBloc(
      //         repository: DepartmentAttendanceReportRepositoryImpl(
      //           localDataSource: DepartmentReportLocalDataSource(),
      //         ),
      //       )..add(const DepartmentReportStarted()),
      //       child: const DepartmentAttendanceReportPage(),
      //     ),
      //   );
      // case Routes.monthlyReport:
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => BlocProvider<MonthlyAttendanceReportBloc>(
      //       create: (_) => MonthlyAttendanceReportBloc(
      //         repository: MonthlyAttendanceReportRepositoryImpl(
      //           localDataSource: MonthlyAttendanceReportLocalDataSource(),
      //         ),
      //       )..add(const MonthlyAttendanceReportStarted()),
      //       child: const MonthlyAttendanceReportPage(),
      //     ),
      //   );

      // case Routes.detailedMonthlyAttendanceReport:
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => BlocProvider<DetailedMonthlyAttendanceReportBloc>(
      //       create: (_) => DetailedMonthlyAttendanceReportBloc(
      //         repository: DetailedMonthlyAttendanceReportRepositoryImpl(
      //           localDataSource:
      //               DetailedMonthlyAttendanceReportLocalDataSource(),
      //         ),
      //       )..add(const DetailedMonthlyAttendanceReportStarted()),
      //       child: const DetailedMonthlyAttendanceReportPage(),
      //     ),
      //   );
      // case Routes.dailyAttendanceReport:
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => BlocProvider<DailyAttendanceReportBloc>(
      //       create: (_) => DailyAttendanceReportBloc(
      //         repository: DailyAttendanceReportRepositoryImpl(
      //           localDataSource: DailyAttendanceReportLocalDataSource(),
      //         ),
      //       )..add(const DailyAttendanceReportStarted()),
      //       child: const DailyAttendanceReportPage(),
      //     ),
      //   );

      // case Routes.dailyAbsentReport:
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => BlocProvider<DailyAbsentReportBloc>(
      //       create: (_) => DailyAbsentReportBloc(
      //         repository: AbsentReportRepositoryImpl(
      //           localDataSource: AbsentReportLocalDataSource(),
      //         ),
      //       )..add(const DailyAbsentReportStarted()),
      //       child: const DailyAbsentReportPage(),
      //     ),
      //   );

      // case Routes.absentSummaryReport:
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => BlocProvider<AbsentSummaryReportBloc>(
      //       create: (_) => AbsentSummaryReportBloc(
      //         repository: AbsentReportRepositoryImpl(
      //           localDataSource: AbsentReportLocalDataSource(),
      //         ),
      //       )..add(const AbsentSummaryReportStarted()),
      //       child: const AbsentSummaryReportPage(),
      //     ),
      //   );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Page not found"))),
        );
    }
  }
}
