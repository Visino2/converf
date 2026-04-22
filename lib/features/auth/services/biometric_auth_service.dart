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

  final SharedPreferences _prefs;
  final LocalAuthentication _localAuthentication;

  bool get isEnabledSync => _prefs.getBool(biometricEnabledKey) ?? false;

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(biometricEnabledKey, enabled);
  }

  Future<BiometricAvailability> getAvailability() async {
    try {
      final isDeviceSupported = await _localAuthentication.isDeviceSupported();
      final canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      final availableBiometrics = (isDeviceSupported || canCheckBiometrics)
          ? await _localAuthentication.getAvailableBiometrics()
          : const <BiometricType>[];

      return BiometricAvailability(
        isDeviceSupported: isDeviceSupported,
        canCheckBiometrics: canCheckBiometrics,
        availableBiometrics: availableBiometrics,
      );
    } catch (e) {
      debugPrint('[BiometricAuth] Availability check failed: $e');
      return BiometricAvailability(
        isDeviceSupported: false,
        canCheckBiometrics: false,
        availableBiometrics: const <BiometricType>[],
        lastError: 'Biometric authentication is not available right now.',
      );
    }
  }

  Future<bool> canProtectSession() async {
    if (!isEnabledSync) {
      return false;
    }
    return (await getAvailability()).canAuthenticate;
  }

  Future<bool> authenticate({required String reason}) async {
    try {
      return await _localAuthentication.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          sensitiveTransaction: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      debugPrint('[BiometricAuth] Authentication failed: $e');
      return false;
    }
  }
}
