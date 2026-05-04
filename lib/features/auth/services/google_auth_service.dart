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
  // iOS OAuth client (client_type: 2, onverf-v2 project).
  static const String _iosClientId =
      '215124506289-9jbqenrlgjbqj9cagk5k54tu1oa9mp4d.apps.googleusercontent.com';

  // Web OAuth client (client_type: 3, auto-created by Firebase, onverf-v2 project).
  // Used as serverClientId on both platforms so GMS issues an ID token
  // with aud = this client ID, which the backend validates.
  static const String _webClientId =
      '215124506289-9blp8h59q5k9v48dh45ngnhbva494tcf.apps.googleusercontent.com';

  String get expectedTokenAudience => _webClientId;

  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    _googleSignIn = GoogleSignIn(
      // iOS needs an explicit clientId; Android resolves it from google-services.json.
      clientId: defaultTargetPlatform == TargetPlatform.iOS ? _iosClientId : null,
      // serverClientId must be the web client (client_type: 3).
      // GMS issues an ID token with aud = _webClientId for backend validation.
      serverClientId: _webClientId,
      scopes: ['email', 'profile'],
    );
  }

  /// Triggers the native Google Sign-In flow and returns the ID token.
  /// Returns null if the user cancels.
  Future<String?> signIn() async {
    try {
      debugPrint(
        '[GoogleSignIn] signIn() on ${defaultTargetPlatform.name} '
        'serverClientId=$_webClientId',
      );

      // Disconnect so the account picker always appears.
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        debugPrint('[GoogleSignIn] User cancelled.');
        return null;
      }

      debugPrint('[GoogleSignIn] Signed in as ${account.email}');

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('Google Sign-In succeeded but ID token is null.');
      }

      logIdTokenClaims(idToken);
      return idToken;
    } on PlatformException catch (e) {
      debugPrint(
        '[GoogleSignIn] PlatformException: code=${e.code} message=${e.message}',
      );
      rethrow;
    } catch (e, st) {
      debugPrint('[GoogleSignIn] Error: $e\n$st');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('[GoogleSignIn] Sign-out error: $e');
    }
  }

  GoogleIdTokenClaims? parseIdTokenClaims(String idToken) {
    try {
      final segments = idToken.split('.');
      if (segments.length < 2) return null;

      final decodedPayload = utf8.decode(
        base64Url.decode(base64Url.normalize(segments[1])),
      );
      final dynamic payload = jsonDecode(decodedPayload);
      if (payload is! Map) return null;

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
      debugPrint('[GoogleSignIn] Failed to parse ID token: $e');
      return null;
    }
  }

  void logIdTokenClaims(String idToken) {
    final claims = parseIdTokenClaims(idToken);
    if (claims == null) {
      debugPrint('[GoogleSignIn] Could not decode ID token claims.');
      return;
    }
    debugPrint(
      '[GoogleSignIn] Token claims — '
      'aud=${claims.audience}, '
      'azp=${claims.authorizedParty}, '
      'iss=${claims.issuer}, '
      'exp=${claims.expiresAt?.toIso8601String()}',
    );
    if (claims.audience != null && claims.audience != expectedTokenAudience) {
      debugPrint(
        '[GoogleSignIn] WARNING: aud mismatch — '
        'got=${claims.audience}, expected=$expectedTokenAudience',
      );
    }
  }
}
