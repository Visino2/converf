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
  // Web OAuth client ID for the web app (project 165586994124).
  // ID tokens issued on iOS/web will carry this as their audience.
  // Backend MUST accept this as valid audience for web/iOS tokens.
  static const String _webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '165586994124-hflca443nfirdase4vj76vkakfs7pvq9.apps.googleusercontent.com',
  );

  // Mobile OAuth client (type 3) from the native Android Firebase project
  // (project number 897727755110). The Android google-services.json belongs
  // to this project, so serverClientId on Android MUST use this client ID —
  // using a client from a different project causes sign_in_failed on Android.
  // ID tokens issued on Android will carry this value as their audience.
  // Backend MUST accept this as valid audience for Android tokens.
  static const String _mobileClientId = String.fromEnvironment(
    'GOOGLE_MOBILE_CLIENT_ID',
    defaultValue:
        '897727755110-f345u25o6888kq6nsrrvv6n1s0cuu6hf.apps.googleusercontent.com',
  );

  // iOS OAuth client ID (project 165586994124 — same as web).
  static const String _iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue:
        '165586994124-5tiu5dl7hn1q56lqp5edq2gbeujbcgts.apps.googleusercontent.com',
  );

  /// Both audiences the backend must accept: web tokens use _webClientId,
  /// Android tokens use _mobileClientId.
  static const List<String> validTokenAudiences = [
    _webClientId,
    _mobileClientId,
  ];

  /// The audience expected for the current platform's token.
  String get expectedTokenAudience {
    return defaultTargetPlatform == TargetPlatform.android
        ? _mobileClientId
        : _webClientId;
  }

  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    _googleSignIn = GoogleSignIn(
      // iOS needs an explicit clientId to identify which OAuth client to use.
      // Android leaves this null — the SDK resolves it from google-services.json.
      clientId: defaultTargetPlatform == TargetPlatform.iOS
          ? _iosClientId
          : null,
      // serverClientId MUST be a Web OAuth client from the SAME Firebase project
      // as the platform's config file (google-services.json / GoogleService-Info.plist).
      // Using a client ID from a different project causes sign_in_failed on Android.
      // Android → mobile project (431938083961), iOS/other → web project (165586994124).
      serverClientId: defaultTargetPlatform == TargetPlatform.android
          ? _mobileClientId
          : _webClientId,
      scopes: ['email', 'profile'],
    );
  }

  /// Triggers the native Google Sign-In flow and returns the ID Token.
  Future<String?> signIn() async {
    try {
      debugPrint(
        '[GoogleSignIn] signIn() called on ${defaultTargetPlatform.name} '
        'with serverClientId=$expectedTokenAudience.',
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
