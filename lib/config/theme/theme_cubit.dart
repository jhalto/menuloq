import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_getInitialThemeMode(_prefs));

  final SharedPreferences _prefs;

  static const String _themeKey = 'app_theme_mode';

  static ThemeMode _getInitialThemeMode(SharedPreferences prefs) {
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme == 'light') return ThemeMode.light;
    if (savedTheme == 'dark') return ThemeMode.dark;

    // SharedPreferences null হলে phone/system theme follow করবে
    return ThemeMode.system;
  }

  Future<void> setLightTheme() async {
    await _prefs.setString(_themeKey, 'light');
    emit(ThemeMode.light);
  }

  Future<void> setDarkTheme() async {
    await _prefs.setString(_themeKey, 'dark');
    emit(ThemeMode.dark);
  }

  Future<void> setSystemTheme() async {
    await _prefs.remove(_themeKey);
    emit(ThemeMode.system);
  }

  Future<void> toggleTheme(BuildContext context) async {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    if (isDark) {
      await setLightTheme();
    } else {
      await setDarkTheme();
    }
  }
}