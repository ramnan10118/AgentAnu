import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';

  // Singleton
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token operations
  Future<void> saveToken(String token) async {
    await _prefs?.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs?.getString(_keyToken);
  }

  Future<void> removeToken() async {
    await _prefs?.remove(_keyToken);
  }

  // User operations
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs?.setString(_keyUser, json.encode(user));
  }

  Map<String, dynamic>? getUser() {
    final userJson = _prefs?.getString(_keyUser);
    if (userJson != null) {
      return json.decode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> removeUser() async {
    await _prefs?.remove(_keyUser);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // Check if logged in
  bool isLoggedIn() {
    return getToken() != null;
  }
}

