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
    if (availableBiometrics.contains(BiometricType.face)) return 'Face ID';
    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    }
    if (availableBiometrics.contains(BiometricType.iris)) return 'Iris';
    return 'Biometrics';
  }

  String get helperText {
    if (canAuthenticate) {
      return 'Use $preferredLabel to unlock your app after inactivity.';
    }
    if (lastError != null && lastError!.isNotEmpty) return lastError!;
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

  // Backend-issued long-lived token used exclusively for biometric re-login.
  // Stored separately from the session token so it survives regular logouts.
  static const String _biometricDeviceTokenKey = 'biometric_device_token';
  static const String _biometricSetupPromptedKey = 'biometric_setup_prompted';

  final SharedPreferences _prefs;
  final LocalAuthentication _localAuthentication;

  // ── State ────────────────────────────────────────────────────────────────────

  bool get isEnabledSync => _prefs.getBool(biometricEnabledKey) ?? false;

  bool get hasDeviceToken =>
      (_prefs.getString(_biometricDeviceTokenKey) ?? '').isNotEmpty;

  bool get hasBeenSetupPrompted =>
      _prefs.getBool(_biometricSetupPromptedKey) ?? false;

  String? getDeviceToken() => _prefs.getString(_biometricDeviceTokenKey);

  // ── Persistence ──────────────────────────────────────────────────────────────

  Future<void> saveDeviceToken(String token) =>
      _prefs.setString(_biometricDeviceTokenKey, token);

  Future<void> clearDeviceToken() =>
      _prefs.remove(_biometricDeviceTokenKey);

  Future<void> setEnabled(bool enabled) =>
      _prefs.setBool(biometricEnabledKey, enabled);

  Future<void> markSetupPrompted() =>
      _prefs.setBool(_biometricSetupPromptedKey, true);

  Future<void> resetSetupPrompt() =>
      _prefs.remove(_biometricSetupPromptedKey);

  Future<void> disable() async {
    await _prefs.setBool(biometricEnabledKey, false);
    await _prefs.remove(_biometricDeviceTokenKey);
    await _prefs.remove(_biometricSetupPromptedKey);
  }

  // ── Device capabilities ──────────────────────────────────────────────────────

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
    if (!isEnabledSync) return false;
    return (await getAvailability()).canAuthenticate;
  }

  // ── Authentication ───────────────────────────────────────────────────────────

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
