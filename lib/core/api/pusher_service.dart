import 'dart:async';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/session_manager.dart';
import '../config/config.dart';

final pusherServiceProvider = Provider<PusherService>((ref) {
  return PusherService(ref);
});

class PusherService {
  final Ref _ref;
  PusherChannelsClient? _client;
  bool _isInitialized = false;
  bool _fallbackTried = false;
  final Map<String, Channel> _channels = {};

  PusherService(this._ref);

  Future<void> init() async {
    if (_isInitialized) return;
    await _connect(
      scheme: 'wss',
      host: AppConfig.pusherHost,
      port: AppConfig.pusherPort,
      allowFallback: AppConfig.isDevelopment,
    );
  }

  Future<void> _connect({
    required String scheme,
    required String host,
    required int port,
    bool allowFallback = false,
  }) async {
    try {
      debugPrint(
        "[PusherService] Initializing (scheme=$scheme, host=$host, port=$port)...",
      );

      final options = PusherChannelsOptions.fromHost(
        scheme: scheme,
        host: host,
        key: AppConfig.pusherKey,
        port: port,
      );

      _client = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (exception, trace, stream) async {
          debugPrint("[PusherService] Connection error: $exception");
          if (allowFallback && !_fallbackTried) {
            _fallbackTried = true;
            debugPrint(
              "[PusherService] Trying fallback websocket (${AppConfig.pusherFallbackScheme}://$host:${AppConfig.pusherFallbackPort})...",
            );
            _client?.disconnect();
            await _connect(
              scheme: AppConfig.pusherFallbackScheme,
              host: host,
              port: AppConfig.pusherFallbackPort,
              allowFallback: false,
            );
          }
        },
      );

      _client!.lifecycleStream.listen((event) {
        debugPrint("[PusherService] Lifecycle state: $event");
      });

      _client!.connect();
      _isInitialized = true;
      debugPrint("[PusherService] Client initialized and connecting...");
    } catch (e) {
      debugPrint("[PusherService] Failed to initialize/connect: $e");
    }
  }

  Future<PrivateChannel> subscribeToProject(String projectId) async {
    if (!_isInitialized) {
      await init();
    }

    final token = await _ref.read(sessionManagerProvider).getToken();
    if (token == null) {
      throw Exception("No token found for Pusher authentication");
    }

    final channelName = 'private-project.$projectId';
    debugPrint("[PusherService] Subscribing to $channelName");

    if (_channels.containsKey(channelName)) {
      return _channels[channelName] as PrivateChannel;
    }

    final channel = _client!.privateChannel(
      channelName,
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
            authorizationEndpoint: Uri.parse(AppConfig.pusherAuthEndpoint),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ),
    );

    channel.subscribe();
    _channels[channelName] = channel;
    return channel;
  }

  void unsubscribe(String channelName) {
    debugPrint("[PusherService] Unsubscribing from $channelName");
    final channel = _channels.remove(channelName);
    if (channel != null) {
      channel.unsubscribe();
    }
  }

  void disconnect() {
    debugPrint("[PusherService] Disconnecting...");
    _channels.forEach((name, channel) {
      channel.unsubscribe();
    });
    _channels.clear();
    _client?.disconnect();
    _isInitialized = false;
  }
}
