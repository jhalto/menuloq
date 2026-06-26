class Routes {
  const Routes._();
  static const String initial = "/";
  static const String login = "/login";
  static const String register = "/register";
  static const String veriflyEmail = "/verify-email";
  static const String forgotPassword = "/forgot-password";
  static const String resetPassword = "/reset-password";
  static const String attendance = "/attendance";
  static const String individualAttendanceReport =
      '/reports/individual-attendance';
  static const String detailedAttendanceReport = '/reports/detailed-attendance';
  static const String departmentReport = '/reports/department-report';
  static const String monthlyReport = '/reports/monthly-report';
  static const String detailedMonthlyAttendanceReport =
      '/reports/detailed-monthly-attendance-report';
  static const String dailyAttendanceReport =
      '/reports/daily-attendance-report';
  static const String dailyAbsentReport = '/reports/daily-absent-report';
  static const String absentSummaryReport = '/reports/absent-summary-report';
}
