import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cache/hive_cache_service.dart';
import '../services/network_sync_service.dart';

// Singleton provider for HiveCacheService
final hiveCacheServiceProvider = Provider<HiveCacheService>((ref) {
  return HiveCacheService();
});

// Network sync service provider
final networkSyncServiceProvider = Provider<NetworkSyncService>((ref) {
  final cacheService = ref.watch(hiveCacheServiceProvider);

  final syncService = NetworkSyncService(cacheService: cacheService);

  // Start monitoring on creation
  syncService.startMonitoring();

  // Cleanup on disposal
  ref.onDispose(() {
    syncService.dispose();
  });

  return syncService;
});
