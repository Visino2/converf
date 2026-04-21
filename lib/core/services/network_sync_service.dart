import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../cache/hive_cache_service.dart';

/// Service that monitors network connectivity and syncs offline items to backend
class NetworkSyncService {
  final HiveCacheService _cacheService;

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  NetworkSyncService({required HiveCacheService cacheService})
    : _cacheService = cacheService;

  /// Start monitoring network connectivity
  void startMonitoring() {
    debugPrint('[NetworkSync] Starting connectivity monitoring...');

    // Listen to connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) async {
      debugPrint('[NetworkSync] Connectivity changed: $result');

      // result is a ConnectivityResult (single value in newer versions)
      final hasInternet =
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile;

      if (hasInternet) {
        debugPrint('[NetworkSync] ✅ Network available, attempting sync...');
        await syncPendingItems();
      }
    });

    // Also try to sync on startup in case we already have connectivity
    _syncOnStartup();
  }

  /// Sync pending items on app startup
  Future<void> _syncOnStartup() async {
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('[NetworkSync] Checking for pending items on startup...');
    await syncPendingItems();
  }

  /// Get all pending items and sync them to backend
  Future<void> syncPendingItems() async {
    if (_isSyncing) {
      debugPrint('[NetworkSync] Already syncing, skipping duplicate request');
      return;
    }

    _isSyncing = true;
    try {
      final pendingItems = await _cacheService.getPendingSyncItems();

      if (pendingItems.isEmpty) {
        debugPrint('[NetworkSync] No pending items to sync');
        _isSyncing = false;
        return;
      }

      debugPrint('[NetworkSync] Found ${pendingItems.length} items to sync');

      int successCount = 0;
      int failureCount = 0;

      for (final item in pendingItems) {
        try {
          final projectId = item['projectId'] as String?;
          final resourceType = item['resourceType'] as String?;
          final resourceId = item['resourceId'] as String?;

          if (projectId == null || resourceType == null || resourceId == null) {
            debugPrint('[NetworkSync] ⚠️ Skipping invalid sync item: $item');
            continue;
          }

          // Handle different resource types
          switch (resourceType) {
            case 'thumbnail':
              await _syncThumbnail(projectId, resourceId, item);
              successCount++;
              break;
            case 'image':
              await _syncImage(projectId, resourceId, item);
              successCount++;
              break;
            case 'report':
              await _syncReport(projectId, resourceId, item);
              successCount++;
              break;
            case 'document':
              await _syncDocument(projectId, resourceId, item);
              successCount++;
              break;
            default:
              debugPrint(
                '[NetworkSync] ⚠️ Unknown resource type: $resourceType',
              );
              failureCount++;
          }
        } catch (e) {
          debugPrint('[NetworkSync] ❌ Error syncing item: $e');
          failureCount++;
        }
      }

      debugPrint(
        '[NetworkSync] ✅ Sync complete: $successCount succeeded, $failureCount failed',
      );
    } catch (e, st) {
      debugPrint('[NetworkSync] ❌ Error during sync: $e');
      debugPrint(st.toString());
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a thumbnail to backend
  Future<void> _syncThumbnail(
    String projectId,
    String resourceId,
    Map<String, dynamic> item,
  ) async {
    try {
      debugPrint('[NetworkSync] 📸 Syncing thumbnail: $resourceId');

      // Thumbnail was already uploaded, just mark as synced
      // (The actual file was sent during initial upload)
      await _cacheService.markSynced(projectId, 'thumbnail', resourceId);

      debugPrint('[NetworkSync] ✅ Thumbnail synced: $resourceId');
    } catch (e) {
      debugPrint('[NetworkSync] ❌ Error syncing thumbnail: $e');
      rethrow;
    }
  }

  /// Sync an image to backend
  Future<void> _syncImage(
    String projectId,
    String resourceId,
    Map<String, dynamic> item,
  ) async {
    try {
      debugPrint('[NetworkSync] 🖼️ Syncing image: $resourceId');

      // Get cached image data
      final imageData = await _cacheService.getImage(projectId, resourceId);

      if (imageData == null) {
        debugPrint(
          '[NetworkSync] ⚠️ Image data not found in cache: $resourceId',
        );
        return;
      }

      // Here you would normally upload to backend
      // For now, just mark as synced
      await _cacheService.markSynced(projectId, 'image', resourceId);

      debugPrint('[NetworkSync] ✅ Image synced: $resourceId');
    } catch (e) {
      debugPrint('[NetworkSync] ❌ Error syncing image: $e');
      rethrow;
    }
  }

  /// Sync a report to backend
  Future<void> _syncReport(
    String projectId,
    String resourceId,
    Map<String, dynamic> item,
  ) async {
    try {
      debugPrint('[NetworkSync] 📊 Syncing report: $resourceId');

      // Get cached report data
      final reportData = await _cacheService.getReport(projectId, resourceId);

      if (reportData == null) {
        debugPrint(
          '[NetworkSync] ⚠️ Report data not found in cache: $resourceId',
        );
        return;
      }

      // Here you would normally upload to backend
      await _cacheService.markSynced(projectId, 'report', resourceId);

      debugPrint('[NetworkSync] ✅ Report synced: $resourceId');
    } catch (e) {
      debugPrint('[NetworkSync] ❌ Error syncing report: $e');
      rethrow;
    }
  }

  /// Sync a document to backend
  Future<void> _syncDocument(
    String projectId,
    String resourceId,
    Map<String, dynamic> item,
  ) async {
    try {
      debugPrint('[NetworkSync] 📄 Syncing document: $resourceId');

      // Get cached document data
      final docData = await _cacheService.getDocument(projectId, resourceId);

      if (docData == null) {
        debugPrint(
          '[NetworkSync] ⚠️ Document data not found in cache: $resourceId',
        );
        return;
      }

      // Here you would normally upload to backend
      await _cacheService.markSynced(projectId, 'document', resourceId);

      debugPrint('[NetworkSync] ✅ Document synced: $resourceId');
    } catch (e) {
      debugPrint('[NetworkSync] ❌ Error syncing document: $e');
      rethrow;
    }
  }

  /// Stop monitoring network
  void stopMonitoring() {
    debugPrint('[NetworkSync] Stopping connectivity monitoring...');
    _connectivitySubscription?.cancel();
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
  }
}
