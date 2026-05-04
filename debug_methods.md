# 🔍 Converf Mobile - Debugging Methods

## 1. **Console Logging (Real-time)**
✅ **Already Implemented** - Enhanced HTTP logging with chunked output
```bash
flutter run -d emulator-5554 2>&1 | grep -E '\[HTTP|AUTH|ERROR|Cache'
```
Shows real-time: HTTP requests, Auth logs, Errors, Cache operations

---

## 2. **Unit & Integration Tests**
✅ **Ready to Run** - Test auth flows, caching, API calls
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/auth_test.dart

# Run with coverage
flutter test --coverage
```

---

## 3. **Static Analysis & Lint Checks**
✅ **Built-in** - Catch errors before runtime
```bash
flutter analyze
dart analyze lib/
```

---

## 4. **Verbose Logging Mode**
```bash
flutter run -v -d emulator-5554 2>&1 | tee app_debug.log
# Saves full logs to app_debug.log
```

---

## 5. **Performance Profiling**
```bash
flutter run --profile -d emulator-5554
# Then use DevTools performance tab
```

---

## 6. **Network Inspection**
✅ **Implemented** - Custom logging in dio_provider.dart
- All HTTP requests logged with [HTTP] prefix
- All responses logged in chunks to avoid truncation
- Errors logged with [HTTP ERROR] prefix

---

## 7. **Database Inspection (Hive)**
```bash
# Connect to emulator shell
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"
adb shell

# Navigate to app data
cd /data/data/com.converf.app/files/
ls -la hive/

# Pull Hive database for inspection
adb pull /data/data/com.converf.app/files/hive/ ./hive_backup/
```

---

## 8. **Dart DevTools (Web Interface)**
```bash
# Start with DevTools support
flutter run -d emulator-5554 --observe

# Open DevTools (shown in console output)
# Example: http://localhost:9100?uri=ws://localhost:54321/...
```

---

## Current Test Coverage
- ✅ Auth provider (login, logout, signup)
- ✅ Dashboard repository API calls
- ✅ Hive caching service
- ✅ Project details and thumbnails
- ✅ Network sync service

