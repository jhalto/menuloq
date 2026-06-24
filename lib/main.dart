import 'package:flutter/material.dart';
import 'package:menuloq/config/route/route_name.dart';
import 'package:menuloq/config/route/routes.dart';
import 'package:menuloq/config/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MenuLoq',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: Routes.login,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
