class AppConfig {
  static const String apiBaseUrl = 'https://api-dev.converf.com';

  // Pusher / Real-time Configuration
  static const String pusherHost = 'ws-dev.converf.com';
  static const String pusherKey = 'puagxyxv2ddo6kiznzzy';
  static const int pusherPort = 443;
  // Fallback (dev) websocket settings
  static const int pusherFallbackPort = 6001;
  static const String pusherFallbackScheme = 'ws';
  static const String pusherAuthEndpoint = '$apiBaseUrl/broadcasting/auth';

  // Environment
  static const bool isDevelopment = true;
}
