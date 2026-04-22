import 'dart:convert';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:converf/core/config/shared_prefs_provider.dart';

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(ref.read(sharedPreferencesProvider));
});

final sessionRefreshProvider = StreamProvider<int>((ref) {
  return SessionManager.sessionChanges;
});

class SessionManager {
  final SharedPreferences _prefs;

  SessionManager(this._prefs);

  static const String _tokenKey = 'token';
  static const String _userKey = 'user';
  static const String _welcomePrefix = 'welcome_seen_';
  static final StreamController<int> _sessionChangesController =
      StreamController<int>.broadcast();
  static int _sessionVersion = 0;

  static Stream<int> get sessionChanges => _sessionChangesController.stream;

  Future<void> saveSession(
    String token,
    Map<String, dynamic> user, {
    bool notifySessionChange = true,
  }) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userKey, jsonEncode(user));
    if (notifySessionChange) {
      _notifySessionChanged();
    }
  }

  Future<void> saveUser(
    Map<String, dynamic> user, {
    bool notifySessionChange = true,
  }) async {
    await _prefs.setString(_userKey, jsonEncode(user));
    if (notifySessionChange) {
      _notifySessionChanged();
    }
  }

  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  String? getTokenSync() {
    return _prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final userJson = _prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearSession({bool notifySessionChange = true}) async {
    final hadSessionData =
        _prefs.containsKey(_tokenKey) || _prefs.containsKey(_userKey);
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
    // Note: we intentionally keep welcome flags so returning users still skip welcome screens.
    if (notifySessionChange && hadSessionData) {
      _notifySessionChanged();
    }
  }

  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  bool hasSessionSync() {
    final token = getTokenSync();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasSeenWelcome(String userId) async {
    if (userId.isEmpty) {
      return true; // default to seen to avoid blocking navigation
    }
    return _prefs.getBool('$_welcomePrefix$userId') ?? false;
  }

  Future<void> setWelcomeSeen(
    String userId, {
    bool notifySessionChange = true,
  }) async {
    if (userId.isEmpty) {
      return;
    }
    await _prefs.setBool('$_welcomePrefix$userId', true);
    if (notifySessionChange) {
      _notifySessionChanged();
    }
  }

  void _notifySessionChanged() {
    if (_sessionChangesController.isClosed) return;
    _sessionChangesController.add(++_sessionVersion);
  }
}
