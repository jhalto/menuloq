import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'access_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresInKey = 'expires_in';
  static const String _tokenSavedAtKey = 'token_saved_at';

  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  static const String _businessIdKey = 'business_id';
  static const String _businessNameKey = 'business_name';
  static const String _businessUserNameKey = 'business_user_name';

  Future<void> saveToken({
    required String accessToken,
    required String tokenType,
    required int expiresIn,
  }) async {
    final savedAt = DateTime.now().millisecondsSinceEpoch;

    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _tokenTypeKey, value: tokenType);
    await _storage.write(key: _expiresInKey, value: expiresIn.toString());
    await _storage.write(key: _tokenSavedAtKey, value: savedAt.toString());
  }

  Future<void> saveAuthData({
    required String accessToken,
    required String tokenType,
    required int expiresIn,
    required int userId,
    required String userName,
    required String userEmail,
    required int businessId,
    required String businessName,
    required String businessUserName,
  }) async {
    await saveToken(
      accessToken: accessToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
    );

    await _storage.write(key: _userIdKey, value: userId.toString());
    await _storage.write(key: _userNameKey, value: userName);
    await _storage.write(key: _userEmailKey, value: userEmail);

    await _storage.write(key: _businessIdKey, value: businessId.toString());
    await _storage.write(key: _businessNameKey, value: businessName);
    await _storage.write(key: _businessUserNameKey, value: businessUserName);
  }

  Future<String?> getAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String> getTokenType() async {
    return await _storage.read(key: _tokenTypeKey) ?? 'Bearer';
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.trim().isNotEmpty;
  }

  Future<bool> isTokenExpired() async {
    final expiresInText = await _storage.read(key: _expiresInKey);
    final savedAtText = await _storage.read(key: _tokenSavedAtKey);

    final expiresIn = int.tryParse(expiresInText ?? '');
    final savedAt = int.tryParse(savedAtText ?? '');

    if (expiresIn == null || savedAt == null) return true;

    final savedAtDate = DateTime.fromMillisecondsSinceEpoch(savedAt);
    final expiryDate = savedAtDate.add(Duration(seconds: expiresIn));

    return DateTime.now().isAfter(expiryDate);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _tokenTypeKey);
    await _storage.delete(key: _expiresInKey);
    await _storage.delete(key: _tokenSavedAtKey);
  }

  Future<void> clearAuthData() async {
    await clearToken();

    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _userEmailKey);

    await _storage.delete(key: _businessIdKey);
    await _storage.delete(key: _businessNameKey);
    await _storage.delete(key: _businessUserNameKey);
  }

  Future<void> clearAllLocalData() async {
    await _storage.deleteAll();

    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  Future<String?> getUserName() {
    return _storage.read(key: _userNameKey);
  }

  Future<String?> getUserEmail() {
    return _storage.read(key: _userEmailKey);
  }

  Future<String?> getBusinessName() {
    return _storage.read(key: _businessNameKey);
  }

  Future<String?> getBusinessUserName() {
    return _storage.read(key: _businessUserNameKey);
  }
}
