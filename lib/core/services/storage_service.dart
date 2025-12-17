import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> setAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> setUserId(String userId) async {
    final prefs = await _prefs;
    await prefs.setString(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_userIdKey);
  }

  Future<void> setUserRole(String role) async {
    final prefs = await _prefs;
    await prefs.setString(_userRoleKey, role);
  }

  Future<String?> getUserRole() async {
    final prefs = await _prefs;
    return prefs.getString(_userRoleKey);
  }

  Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await _prefs;
    await prefs.setBool(_onboardingCompleteKey, complete);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await _prefs;
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await _prefs;
    await prefs.setString(_themeKey, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await _prefs;
    return prefs.getString(_themeKey) ?? 'system';
  }

  Future<void> setLocale(String locale) async {
    final prefs = await _prefs;
    await prefs.setString(_localeKey, locale);
  }

  Future<String> getLocale() async {
    final prefs = await _prefs;
    return prefs.getString(_localeKey) ?? 'ar';
  }

  Future<void> saveObject(String key, Map<String, dynamic> object) async {
    final prefs = await _prefs;
    await prefs.setString(key, jsonEncode(object));
  }

  Future<Map<String, dynamic>?> getObject(String key) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> saveList(String key, List<Map<String, dynamic>> list) async {
    final prefs = await _prefs;
    await prefs.setString(key, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>?> getList(String key) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> remove(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
    await _secureStorage.delete(key: key);
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
    await _secureStorage.deleteAll();
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    final prefs = await _prefs;
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
  }
}
