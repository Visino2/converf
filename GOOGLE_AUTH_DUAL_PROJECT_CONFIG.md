# Google Auth - Dual Firebase Project Configuration

## Overview

The Converf mobile app uses **TWO Firebase projects** for Google authentication due to Android security restrictions:

1. **Web/iOS Project**: `165586994124`
   - Client ID: `165586994124-hflca443nfirdase4vj76vkakfs7pvq9.apps.googleusercontent.com`
   - Used for: Web app and iOS mobile app

2. **Android Project**: `431938083961`
   - Client ID: `431938083961-5uc5ipu2svekl6cc19qso01upl748jvt.apps.googleusercontent.com`
   - Used for: Native Android mobile app only

## Why Two Projects?

Android's Google SDK requires:
- `serverClientId` must be from the **same Firebase project** as the app's `google-services.json`
- Using a Web Client ID from a different project causes: **`sign_in_failed` error**
- We cannot use the Web Client ID (165586994124) on Android

## Backend Configuration Required

### Google ID Token Validation

Your backend's Google ID token verification must accept **BOTH** Client IDs as valid audiences:

```python
# Example (Python with google-auth library)
from google.oauth2 import id_token
from google.auth.transport import requests

VALID_AUDIENCES = [
    "165586994124-hflca443nfirdase4vj76vkakfs7pvq9.apps.googleusercontent.com",  # Web/iOS
    "431938083961-5uc5ipu2svekl6cc19qso01upl748jvt.apps.googleusercontent.com",   # Android
]

def verify_google_id_token(token):
    try:
        idinfo = id_token.verify_oauth2_token(
            token, 
            requests.Request(),
            audience=None  # Don't validate audience initially
        )
        
        # Manually check if audience is in our valid list
        if idinfo['aud'] not in VALID_AUDIENCES:
            raise ValueError(f"Invalid audience: {idinfo['aud']}")
            
        return idinfo
    except ValueError as e:
        raise Exception(f"Invalid token: {e}")
```

### Node.js Example
```javascript
const {OAuth2Client} = require('google-auth-library');

const VALID_AUDIENCES = [
    "165586994124-hflca443nfirdase4vj76vkakfs7pvq9.apps.googleusercontent.com", // Web/iOS
    "431938083961-5uc5ipu2svekl6cc19qso01upl748jvt.apps.googleusercontent.com"  // Android
];

const client = new OAuth2Client(); // Don't pass clientId

async function verifyToken(token) {
    const ticket = await client.verifyIdToken({token});
    const payload = ticket.getPayload();
    
    if (!VALID_AUDIENCES.includes(payload.aud)) {
        throw new Error(`Invalid audience: ${payload.aud}`);
    }
    
    return payload;
}
```

### PHP Example
```php
<?php
require_once 'vendor/autoload.php';

$VALID_AUDIENCES = [
    "165586994124-hflca443nfirdase4vj76vkakfs7pvq9.apps.googleusercontent.com", // Web/iOS
    "431938083961-5uc5ipu2svekl6cc19qso01upl748jvt.apps.googleusercontent.com"  // Android
];

function verifyGoogleToken($token) {
    global $VALID_AUDIENCES;
    
    $client = new \Google_Client();
    // Don't set specific client ID - we accept multiple projects
    
    try {
        $payload = $client->verifyIdToken($token);
        
        if (!in_array($payload['aud'], $VALID_AUDIENCES)) {
            throw new Exception("Invalid audience: " . $payload['aud']);
        }
        
        return $payload;
    } catch (Exception $e) {
        throw new Exception("Invalid token: " . $e->getMessage());
    }
}
```

## Mobile Client Configuration

### Updated Google Auth Service

File: `lib/features/auth/services/google_auth_service.dart`

```dart
class GoogleAuthService {
  // Web OAuth client (project 165586994124)
  static const String _webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '165586994124-hflca443nfirdase4vj76vkakfs7pvq9.apps.googleusercontent.com',
  );

  // Mobile OAuth client (project 431938083961)
  static const String _mobileClientId = String.fromEnvironment(
    'GOOGLE_MOBILE_CLIENT_ID',
    defaultValue:
        '431938083961-5uc5ipu2svekl6cc19qso01upl748jvt.apps.googleusercontent.com',
  );

  // iOS OAuth client (project 165586994124)
  static const String _iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue:
        '165586994124-5tiu5dl7hn1q56lqp5edq2gbeujbcgts.apps.googleusercontent.com',
  );

  /// Backend must accept both audiences
  static const List<String> validTokenAudiences = [_webClientId, _mobileClientId];

  String get expectedTokenAudience {
    return defaultTargetPlatform == TargetPlatform.android
        ? _mobileClientId
        : _webClientId;
  }
}
```

## Token Audience by Platform

| Platform | Audience (aud claim) | Firebase Project |
|----------|---------------------|-----------------|
| Android Mobile | `431938083961-5uc5ipu2svekl6cc19qso01upl748jvt.apps.googleusercontent.com` | 431938083961 |
| iOS Mobile | `165586994124-hflca443nfirdase4vj76vkakfs7pvq9.apps.googleusercontent.com` | 165586994124 |
| Web | `165586994124-hflca443nfirdase4vj76vkakfs7pvq9.apps.googleusercontent.com` | 165586994124 |

## Deployment Steps

1. **Update Mobile App Configuration** ✅ (Already done)
   - Android uses Firebase project: `431938083961`
   - iOS uses Firebase project: `165586994124`

2. **Update Backend Token Validation**
   - Accept both Client IDs as valid audiences
   - Do NOT validate against a specific client ID
   - Simply check that the audience is in the `VALID_AUDIENCES` list

3. **Test Integration**
   - Sign in on Android → should receive token with audience `431938083961-5uc5ipu2svekl6cc19qso01upl748jvt...`
   - Sign in on iOS → should receive token with audience `165586994124-hflca443nfirdase4vj76vkakfs7pvq9...`
   - Both should be accepted by backend

## Troubleshooting

**Issue**: Android sign-in shows `sign_in_failed`
- **Cause**: Wrong Firebase project in `google-services.json`
- **Solution**: Ensure `google-services.json` is from project `431938083961`

**Issue**: Backend rejects Android tokens
- **Cause**: Backend only accepts Web Client ID audience
- **Solution**: Add Android Client ID to valid audiences list

**Issue**: iOS sign-in fails
- **Cause**: Wrong Firebase project in `GoogleService-Info.plist`
- **Solution**: Ensure iOS config is from project `165586994124`

## Files Modified

- ✅ `lib/features/auth/services/google_auth_service.dart` - Updated with correct Client IDs
- ⏳ `android/app/google-services.json` - Must be from project `431938083961`
- ✅ `ios/Runner/GoogleService-Info.plist` - Already configured for project `165586994124`

## Next Steps

1. ✅ Update mobile app code (DONE)
2. ⏳ Update backend token validation logic
3. ⏳ Update `android/app/google-services.json` if not already from project 431938083961
4. ⏳ Test end-to-end on all platforms
