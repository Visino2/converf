import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

class GoogleIdTokenClaims {
  const GoogleIdTokenClaims({
    this.audience,
    this.authorizedParty,
    this.issuer,
    this.expiresAt,
  });

  final String? audience;
  final String? authorizedParty;
  final String? issuer;
  final DateTime? expiresAt;
}

class GoogleAuthService {
  // Platform-specific client IDs from google-services.json configuration.
  // These are used to generate the ID token with the correct 'aud' claim.
  // The backend expects to validate against these specific client IDs
  // for the Android and iOS apps.
  static const String _androidClientId = String.fromEnvironment(
    'GOOGLE_ANDROID_CLIENT_ID',
    defaultValue:
        '165586994124-etvi2qfifm6labfj7hdgf13f820kkv3v.apps.googleusercontent.com',
  );
  static const String _iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue:
        '165586994124-5tiu5dl7hn1q56lqp5edq2gbeujbcgts.apps.googleusercontent.com',
  );

  // Web client ID used as fallback for non-native platforms
  static const String _webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '165586994124-ehinqf0siepk2ioifu13kkv3oc901t9f.apps.googleusercontent.com',
  );

  /// Returns the native OAuth client configured for the current platform.
  String get expectedPlatformClientId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidClientId;
      case TargetPlatform.iOS:
        return _iosClientId;
      default:
        return _webClientId;
    }
  }

  /// Native Google Sign-In returns an ID token whose audience matches the
  /// configured Web OAuth client when `serverClientId` is used.
  String get expectedTokenAudience => _webClientId;

  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    _googleSignIn = GoogleSignIn(
      // On iOS: Set clientId to get proper ID token
      // On Android: Leave clientId null - the Google SDK will use the package name
      // to determine which OAuth client to use from google-services.json
      clientId: defaultTargetPlatform == TargetPlatform.iOS
          ? _iosClientId
          : null,
      // serverClientId MUST be the Web OAuth client ID (client_type: 3).
      // Google's native SDK requires a Web client here to issue a valid ID token.
      // Android/iOS client IDs cannot be used as serverClientId — it causes sign_in_failed.
      // The resulting token will have aud = Web client ID.
      // The backend must accept this Web client ID as a valid audience.
      serverClientId: _webClientId,
      scopes: ['email', 'profile'],
    );
  }

  /// Triggers the native Google Sign-In flow and returns the ID Token.
  Future<String?> signIn() async {
    try {
      debugPrint(
        '[GoogleSignIn] signIn() called on ${defaultTargetPlatform.name} '
        'with platformClientId=$expectedPlatformClientId '
        'and serverClientId=$_webClientId.',
      );
      // Clear any previous session to ensure the "Choose Account" popup appears
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // User cancelled the sign-in
        debugPrint('[GoogleSignIn] User cancelled account selection.');
        return null;
      }

      debugPrint('[GoogleSignIn] Selected account: ${account.email}');

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('Failed to obtain Google ID Token.');
      }

      logIdTokenClaims(idToken);
      return idToken;
    } catch (e, st) {
      debugPrint('[GoogleSignIn] Error during signIn(): $e');
      debugPrint('[GoogleSignIn] Stack trace: $st');
      if (e is PlatformException) {
        debugPrint(
          '[GoogleSignIn] PlatformException - code: ${e.code}, message: ${e.message}, details: ${e.details}',
        );
      }
      rethrow;
    }
  }

  /// Signs out the user from Google.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google Sign-Out Error: $e');
    }
  }

  GoogleIdTokenClaims? parseIdTokenClaims(String idToken) {
    try {
      final segments = idToken.split('.');
      if (segments.length < 2) {
        return null;
      }

      final decodedPayload = utf8.decode(
        base64Url.decode(base64Url.normalize(segments[1])),
      );
      final dynamic payload = jsonDecode(decodedPayload);
      if (payload is! Map) {
        return null;
      }

      final claims = Map<String, dynamic>.from(payload);
      final expValue = claims['exp'];
      final expiresAt = expValue is num
          ? DateTime.fromMillisecondsSinceEpoch(
              expValue.toInt() * 1000,
              isUtc: true,
            )
          : null;

      return GoogleIdTokenClaims(
        audience: claims['aud']?.toString(),
        authorizedParty: claims['azp']?.toString(),
        issuer: claims['iss']?.toString(),
        expiresAt: expiresAt,
      );
    } catch (e) {
      debugPrint('[GoogleSignIn] Failed to decode ID token claims: $e');
      return null;
    }
  }

  void logIdTokenClaims(String idToken) {
    final claims = parseIdTokenClaims(idToken);
    if (claims == null) {
      debugPrint('[GoogleSignIn] Unable to decode Google ID token claims.');
      return;
    }

    debugPrint(
      '[GoogleSignIn] ID token claims: '
      'aud=${claims.audience ?? 'unknown'}, '
      'azp=${claims.authorizedParty ?? 'unknown'}, '
      'iss=${claims.issuer ?? 'unknown'}, '
      'exp=${claims.expiresAt?.toIso8601String() ?? 'unknown'}',
    );

    if (claims.audience != null && claims.audience != expectedTokenAudience) {
      debugPrint(
        '[GoogleSignIn] Token audience differs from expected client ID. '
        'token aud=${claims.audience}, expected=$expectedTokenAudience',
      );
    }
  }
}
