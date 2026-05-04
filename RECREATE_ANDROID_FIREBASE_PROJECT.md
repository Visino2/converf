# Recreate Android Firebase Project - Complete Guide

Since project 431938083961 was permanently deleted, you need to create a new Firebase project for Android. This guide will walk you through the entire process.

## Step 1: Create New Firebase Project

1. Go to: https://console.firebase.google.com/
2. Click **"Add project"** or **"Create a project"**
3. **Project name**: `converf-android-mobile` (or similar)
4. Click **Continue**
5. Toggle **"Enable Google Analytics"** OFF (you don't need it)
6. Click **Create project**
7. Wait for project creation to complete

## Step 2: Get Your New Project Number

Once created:
1. Go to **Project Settings** (gear icon ⚙️ in top left)
2. Click **Project Settings**
3. Look for **"Project number"** - copy this value
4. Also note your **"Project ID"**

**Save these:**
- New Project Number: `_________________`
- New Project ID: `_________________`

## Step 3: Add Android App to Firebase Project

1. In Firebase console, click **Add app** → **Android**
2. **Android package name**: `com.converf.mobile` (must match your build.gradle.kts)
3. **App nickname**: `Converf Mobile` (optional)
4. Click **Register app**
5. Click **Download google-services.json**
6. **Keep this file safe** - you'll need it in Step 5

## Step 4: Configure OAuth Consent Screen (Important!)

This step is critical for Google Sign-In to work:

1. Go to: https://console.cloud.google.com/
2. Select your **new Android Firebase project** from the dropdown
3. Left sidebar → **APIs & Services** → **OAuth consent screen**
4. Choose **External** (if not already selected)
5. Click **Create**
6. Fill in the form:
   - **App name**: `Converf Mobile`
   - **User support email**: your-email@converf.com
   - **Developer contact**: your-email@converf.com
7. Click **Save and Continue**
8. Skip scopes (click **Save and Continue**)
9. Review and click **Back to Dashboard**

## Step 5: Create OAuth 2.0 Client ID for Android

1. Still in Google Cloud Console, go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth client ID**
3. **Application type**: Select **Android**
4. **Name**: `Converf Android Mobile`
5. **Package name**: `com.converf.mobile`
6. **SHA-1 certificate fingerprint**: [See instructions below]
7. Click **Create**
8. A dialog will show your new **Client ID** - copy it

### Getting Your SHA-1 Certificate Fingerprint

Run this command in your project directory:

```bash
cd /Users/mac/converf/android
./gradlew signingReport
```

Look for the output showing SHA1 fingerprint. Copy the SHA1 value (looks like: `AB:CD:EF:...`)

Paste it in the Firebase Android Client ID creation form.

## Step 6: Update Android Configuration Files

### Update `android/app/build.gradle.kts`

Your package name should already be `com.converf.mobile` (from earlier changes). Verify:

```kotlin
android {
    namespace = "com.converf.mobile"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.converf.mobile"
        // ... rest of config
    }
}
```

### Replace `android/app/google-services.json`

1. Delete: `/Users/mac/converf/android/app/google-services.json`
2. Replace with: The `google-services.json` file you downloaded in Step 3
3. Move it to: `/Users/mac/converf/android/app/google-services.json`

**Verify the file contains:**
- Your new project number
- Package name: `com.converf.mobile`
- Android client info with your new OAuth Client ID

## Step 7: Update Flutter Code

### Update `lib/features/auth/services/google_auth_service.dart`

Replace the `_mobileClientId` with your new Client ID from Step 5:

```dart
// OLD (REPLACE THIS):
// const String _mobileClientId = '431938083961-5uc5ipu2svekl6cc19qso01upl748jvt.apps.googleusercontent.com';

// NEW (USE THIS):
const String _mobileClientId = 'YOUR-NEW-CLIENT-ID.apps.googleusercontent.com';
```

Also update `_mobileProjectNumber`:

```dart
const String _mobileProjectNumber = 'YOUR-NEW-PROJECT-NUMBER';
```

### Update `validTokenAudiences`

Make sure it includes both Client IDs:

```dart
final validTokenAudiences = [
  _webClientId,  // 165586994124-hflca443nfirdase4vj76vkakfs7pvq9.apps.googleusercontent.com
  _mobileClientId,  // YOUR-NEW-CLIENT-ID.apps.googleusercontent.com
];
```

## Step 8: Verify Configuration

Run these commands:

```bash
cd /Users/mac/converf

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Analyze code
flutter analyze
```

All should complete without errors.

## Step 9: Test on Android Emulator

```bash
# List available devices
flutter devices

# Run on Android emulator
flutter run -d emulator-5554
```

Test Google Sign-In:
1. Launch app on emulator
2. Try signing in with Google
3. If it works, you're good!
4. If it fails, check the logs for errors

## Step 10: Update Backend

**Share with your backend team:**

The new Android Client ID:
```
NEW-CLIENT-ID: YOUR-NEW-CLIENT-ID.apps.googleusercontent.com
```

Backend needs to accept **BOTH** Client IDs as valid token audiences:

```
Web/iOS: 165586994124-hflca443nfirdase4vj76vkakfs7pvq9.apps.googleusercontent.com
Android: YOUR-NEW-CLIENT-ID.apps.googleusercontent.com
```

Backend validation should check if the token's `aud` (audience) claim matches either of these Client IDs.

## Troubleshooting

### "Sign in failed" error
- Verify SHA-1 fingerprint is correct in OAuth Client ID
- Verify package name matches exactly: `com.converf.mobile`
- Check that google-services.json is in the correct location

### "Invalid client" error
- Backend is not accepting your new Client ID
- Share the new Client ID with backend team
- They need to update their token validation logic

### gradle build fails
- Run `flutter clean`
- Delete `/Users/mac/converf/build/` folder
- Run `flutter pub get`
- Try again

## Summary

After completing these steps:
- ✅ New Android Firebase project created
- ✅ New OAuth Client ID generated
- ✅ Google Sign-In configured for Android
- ✅ Flutter app updated with new credentials
- ✅ Backend ready to validate new Client ID
- ✅ App ready for testing on Android emulator

Your app will now use:
- **Web/iOS**: Project 165586994124
- **Android**: New project (your new project number)

Both projects work independently, and the backend accepts both Client IDs for authentication.
