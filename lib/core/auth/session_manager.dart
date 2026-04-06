import 'dart:convert';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager();
});

final sessionRefreshProvider = StreamProvider<int>((ref) {
  return SessionManager.sessionChanges;
});

class SessionManager {
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';
  static const String _welcomePrefix = 'welcome_seen_';
  static final StreamController<int> _sessionChangesController =
      StreamController<int>.broadcast();
  static int _sessionVersion = 0;

  static Stream<int> get sessionChanges => _sessionChangesController.stream;

  Future<void> saveSession(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
    _notifySessionChanged();
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
    _notifySessionChanged();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    // Note: we intentionally keep welcome flags so returning users still skip welcome screens.
    _notifySessionChanged();
  }

  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasSeenWelcome(String userId) async {
    if (userId.isEmpty) {
      return true; // default to seen to avoid blocking navigation
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_welcomePrefix$userId') ?? false;
  }

  Future<void> setWelcomeSeen(String userId) async {
    if (userId.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_welcomePrefix$userId', true);
    _notifySessionChanged();
  }

  void _notifySessionChanged() {
    if (_sessionChangesController.isClosed) return;
    _sessionChangesController.add(++_sessionVersion);
  }
}
