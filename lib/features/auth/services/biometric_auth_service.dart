import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/shared_prefs_provider.dart';

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService(ref.read(sharedPreferencesProvider));
});

class BiometricAvailability {
  const BiometricAvailability({
    required this.isDeviceSupported,
    required this.canCheckBiometrics,
    required this.availableBiometrics,
    this.lastError,
  });

  final bool isDeviceSupported;
  final bool canCheckBiometrics;
  final List<BiometricType> availableBiometrics;
  final String? lastError;

  bool get hasEnrolledBiometrics => availableBiometrics.isNotEmpty;
  bool get canAuthenticate =>
      isDeviceSupported && canCheckBiometrics && hasEnrolledBiometrics;

  String get preferredLabel {
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    }
    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    }
    if (availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biometrics';
  }

  String get helperText {
    if (canAuthenticate) {
      return 'Use $preferredLabel to unlock your app after inactivity.';
    }
    if (lastError != null && lastError!.isNotEmpty) {
      return lastError!;
    }
    if (!isDeviceSupported) {
      return 'This device does not support biometric authentication.';
    }
    if (!canCheckBiometrics) {
      return 'Biometric authentication is currently unavailable.';
    }
    return 'Set up biometrics on this device to enable quick unlock.';
  }
}

class BiometricAuthService {
  BiometricAuthService(this._prefs, [LocalAuthentication? localAuthentication])
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  static const String biometricEnabledKey = 'biometric_login_enabled';
  static const String _biometricTokenKey = 'biometric_session_token';
  static const String _biometricUserKey = 'biometric_session_user';

  final SharedPreferences _prefs;
  final LocalAuthentication _localAuthentication;

  bool get isEnabledSync => _prefs.getBool(biometricEnabledKey) ?? false;

  bool get hasSavedCredentials =>
      (_prefs.getString(_biometricTokenKey) ?? '').isNotEmpty;

  Future<void> saveCredentials(String token, String userJson) async {
    try {
      debugPrint('[BiometricAuth] Saving credentials...');
      debugPrint('[BiometricAuth] Token length: ${token.length}');
      debugPrint('[BiometricAuth] User JSON length: ${userJson.length}');
      await _prefs.setString(_biometricTokenKey, token);
      await _prefs.setString(_biometricUserKey, userJson);
      debugPrint('[BiometricAuth] ✓ Credentials saved successfully');
    } catch (e) {
      debugPrint('[BiometricAuth] ✗ Failed to save credentials: $e');
      rethrow;
    }
  }

  String? getSavedToken() {
    try {
      final token = _prefs.getString(_biometricTokenKey);
      debugPrint(
        '[BiometricAuth] Retrieved token: ${token != null ? 'exists (${token.length} chars)' : 'NOT FOUND'}',
      );
      return token;
    } catch (e) {
      debugPrint('[BiometricAuth] ✗ Failed to retrieve token: $e');
      return null;
    }
  }

  String? getSavedUserJson() {
    try {
      final userJson = _prefs.getString(_biometricUserKey);
      debugPrint(
        '[BiometricAuth] Retrieved user JSON: ${userJson != null ? 'exists (${userJson.length} chars)' : 'NOT FOUND'}',
      );
      return userJson;
    } catch (e) {
      debugPrint('[BiometricAuth] ✗ Failed to retrieve user JSON: $e');
      return null;
    }
  }

  Future<void> clearCredentials() async {
    try {
      debugPrint('[BiometricAuth] Clearing saved credentials...');
      await _prefs.remove(_biometricTokenKey);
      await _prefs.remove(_biometricUserKey);
      debugPrint('[BiometricAuth] ✓ Credentials cleared');
    } catch (e) {
      debugPrint('[BiometricAuth] ✗ Failed to clear credentials: $e');
      rethrow;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(biometricEnabledKey, enabled);
  }

  Future<BiometricAvailability> getAvailability() async {
    try {
      debugPrint('[BiometricAuth] Checking availability...');
      final isDeviceSupported = await _localAuthentication.isDeviceSupported();
      final canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      final availableBiometrics = (isDeviceSupported || canCheckBiometrics)
          ? await _localAuthentication.getAvailableBiometrics()
          : const <BiometricType>[];

      debugPrint('[BiometricAuth] Device supported: $isDeviceSupported');
      debugPrint('[BiometricAuth] Can check biometrics: $canCheckBiometrics');
      debugPrint(
        '[BiometricAuth] Available types: ${availableBiometrics.map((t) => t.toString()).join(', ')}',
      );

      return BiometricAvailability(
        isDeviceSupported: isDeviceSupported,
        canCheckBiometrics: canCheckBiometrics,
        availableBiometrics: availableBiometrics,
      );
    } catch (e) {
      debugPrint('[BiometricAuth] ✗ Availability check failed: $e');
      return BiometricAvailability(
        isDeviceSupported: false,
        canCheckBiometrics: false,
        availableBiometrics: const <BiometricType>[],
        lastError: 'Biometric authentication is not available right now.',
      );
    }
  }

  Future<bool> canProtectSession() async {
    debugPrint('[BiometricAuth] Checking if can protect session...');
    if (!isEnabledSync) {
      debugPrint('[BiometricAuth] Biometric not enabled');
      return false;
    }
    final result = (await getAvailability()).canAuthenticate;
    debugPrint('[BiometricAuth] Can protect session: $result');
    return result;
  }

  Future<bool> authenticate({required String reason}) async {
    try {
      debugPrint(
        '[BiometricAuth] Starting authentication with reason: "$reason"',
      );
      final result = await _localAuthentication.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          sensitiveTransaction: true,
          useErrorDialogs: true,
        ),
      );
      debugPrint('[BiometricAuth] ✓ Authentication result: $result');
      return result;
    } catch (e) {
      debugPrint('[BiometricAuth] ✗ Authentication failed: $e');
      return false;
    }
  }
}
