# Android Firebase Configuration Update

## Current Status
❌ Android `google-services.json` is from old project: `722564350724` (converf-f4cc2)
✅ Mobile code updated to use new project: `431938083961`
✅ iOS already configured correctly: `165586994124`

## What You Need to Do

### Step 1: Download New google-services.json

1. Go to Firebase Console: https://console.firebase.google.com/
2. **Select project: `431938083961`** (the mobile/Android project)
3. Click ⚙️ **Settings** → **Project Settings**
4. Go to **"Your apps"** section
5. Find the Android app with package: **`com.converf.mobile`**
6. Click on the app and select **"google-services.json"** download button
7. This file will contain the credentials from project `431938083961`

### Step 2: Replace File

Replace: `/Users/mac/converf/android/app/google-services.json`

With the downloaded file from project 431938083961

### Step 3: Verify Contents

The new `google-services.json` should have:

```json
{
  "project_info": {
    "project_number": "431938083961",
    "project_id": "YOUR_PROJECT_ID",
    ...
  },
  "client": [
    {
      "client_info": {
        "android_client_info": {
          "package_name": "com.converf.mobile"
        }
      },
      "oauth_client": [
        {
          "client_id": "431938083961-5uc5ipu2svekl6cc19qso01upl748jvt.apps.googleusercontent.com",
          "client_type": 3
        }
      ]
    }
  ]
}
```

Key points:
- ✅ `project_number` should be `431938083961`
- ✅ `package_name` should be `com.converf.mobile`
- ✅ OAuth client ID should start with `431938083961-...`

### Step 4: Clean and Rebuild

```bash
cd /Users/mac/converf
flutter clean
flutter pub get
flutter analyze
```

### Step 5: Test

```bash
flutter run -d emulator-5554
```

---

## Why This Matters

- ✅ Android will use the correct Firebase project credentials
- ✅ Google Sign-In will work without `sign_in_failed` error
- ✅ Backend can validate tokens with correct audience
- ✅ Push notifications will work properly

---

## Quick Summary

| Item | Current | Should Be |
|------|---------|-----------|
| Project Number | 722564350724 ❌ | 431938083961 ✅ |
| Project ID | converf-f4cc2 ❌ | 431938083961 ✅ |
| Package Name | com.converf.mobile ✅ | com.converf.mobile ✅ |
| Mobile Code | Updated ✅ | Updated ✅ |

Only `google-services.json` needs to be updated!
