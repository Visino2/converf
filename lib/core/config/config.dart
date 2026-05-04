/// Centralised runtime configuration with dart-define overrides.
///
/// Use `--dart-define` when building/running to point the mobile app at the
/// same backend as the web app, for example:
///
/// flutter run --dart-define=API_BASE_URL=https://api.converf.com \
///            --dart-define=PUSHER_HOST=wss-prod.converf.com \
///            --dart-define=PUSHER_KEY=xxxx \
///            --dart-define=PUSHER_PORT=443 \
///            --dart-define=PUSHER_AUTH=https://api.converf.com/broadcasting/auth
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api-dev.converf.com',
  );

  // Pusher / Real-time Configuration
  static const String pusherHost = String.fromEnvironment(
    'PUSHER_HOST',
    defaultValue: 'ws-dev.converf.com',
  );
  static const String pusherKey = String.fromEnvironment(
    'PUSHER_KEY',
    defaultValue: 'puagxyxv2ddo6kiznzzy',
  );
  static const int pusherPort = int.fromEnvironment(
    'PUSHER_PORT',
    defaultValue: 443,
  );
  // Fallback (dev) websocket settings
  static const int pusherFallbackPort = int.fromEnvironment(
    'PUSHER_FALLBACK_PORT',
    defaultValue: 6001,
  );
  static const String pusherFallbackScheme = String.fromEnvironment(
    'PUSHER_FALLBACK_SCHEME',
    defaultValue: 'ws',
  );
  static const String pusherAuthEndpoint = String.fromEnvironment(
    'PUSHER_AUTH',
    defaultValue: '$apiBaseUrl/broadcasting/auth',
  );

  // Environment helper
  static const bool isDevelopment = bool.fromEnvironment(
    'IS_DEV',
    defaultValue: true,
  );
}
