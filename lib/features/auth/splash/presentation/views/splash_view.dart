import 'package:flutter/material.dart';
import 'package:menuloq/config/route/route_name.dart';
import 'package:menuloq/core/di/dependency_factory.dart';
import 'package:menuloq/core/utils/loader.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late final Future<bool> _sessionFuture = _checkSession();

  Future<bool> _checkSession() async {
    final di = DependencyFactory.instance;

    final hasToken = await di.authRepository.isLoggedIn();

    if (!hasToken) return false;

    final isExpired = await di.authLocalDataSource.isTokenExpired();

    if (!isExpired) return true;

    try {
      await di.authRepository.refreshToken();
      return true;
    } catch (_) {
      await di.logout();
      return false;
    }
  }

  void _redirect(bool isLoggedIn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        isLoggedIn ? Routes.dashboard : Routes.login,
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _redirect(snapshot.data == true);
        }

        return const Scaffold(body: Center(child: Loader()));
      },
    );
  }
}
