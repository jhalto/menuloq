import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  bool hasToken() {
    return _prefs.containsKey(_tokenKey) &&
        (_prefs.getString(_tokenKey)?.isNotEmpty ?? false);
  }
}
