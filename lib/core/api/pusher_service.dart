import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/session_manager.dart';

final pusherServiceProvider = Provider<PusherService>((ref) {
  return PusherService(ref);
});

class PusherService {
  final Ref _ref;
  PusherChannelsClient? _client;
  bool _isInitialized = false;

  PusherService(this._ref);

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      print("[PusherService] Initializing (pure Dart)...");
      
      final options = PusherChannelsOptions.fromHost(
        scheme: 'wss',
        host: 'ws-dev.converf.com',
        key: 'puagxyxv2ddo6kiznzzy',
        port: 443,
      );

      _client = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (exception, trace, stream) {
          print("[PusherService] Connection error: $exception");
        },
      );

      _client!.lifecycleStream.listen((event) {
        print("[PusherService] Lifecycle state: $event");
      });

      _client!.connect();
      _isInitialized = true;
      print("[PusherService] Client initialized and connecting...");
    } catch (e) {
      print("[PusherService] Failed to initialize/connect: $e");
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
    print("[PusherService] Subscribing to $channelName");

    final channel = _client!.privateChannel(
      channelName,
      authorizationDelegate: EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('https://api-dev.converf.com/broadcasting/auth'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    channel.subscribe();
    return channel;
  }

  void unsubscribe(String channelName) {
    print("[PusherService] Unsubscribing from $channelName");
    // In dart_pusher_channels, you usually shut down the channel or it's handled by dispose
  }

  void disconnect() {
    print("[PusherService] Disconnecting...");
    _client?.disconnect();
    _isInitialized = false;
  }
}
