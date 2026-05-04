import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// Central service for all Hive caching operations
/// Handles thumbnails, images, reports, documents, and other offline storage
class HiveCacheService {
  static const String _thumbnailBox = 'thumbnails';
  static const String _imagesBox = 'images';
  static const String _reportsBox = 'reports';
  static const String _documentsBox = 'documents';
  static const String _syncQueueBox = 'sync_queue';

  static final HiveCacheService _instance = HiveCacheService._internal();

  factory HiveCacheService() {
    return _instance;
  }

  HiveCacheService._internal();

  /// Initialize Hive and all boxes
  Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Open all boxes
      await Hive.openBox<Map>(_thumbnailBox);
      await Hive.openBox<Map>(_imagesBox);
      await Hive.openBox<Map>(_reportsBox);
      await Hive.openBox<Map>(_documentsBox);
      await Hive.openBox<Map>(_syncQueueBox);

      debugPrint('[HiveCache] ✅ Hive initialized and all boxes opened');
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error initializing Hive: $e');
      rethrow;
    }
  }

  /// Cache a thumbnail
  Future<void> cacheThumbnail(
    String projectId,
    String imageId,
    Map<String, dynamic> data,
  ) async {
    try {
      final box = Hive.box<Map>(_thumbnailBox);
      final key = '${projectId}_$imageId';
      await box.put(key, Map<String, dynamic>.from(data));
      debugPrint('[HiveCache] 📸 Thumbnail cached: $key');
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error caching thumbnail: $e');
    }
  }

  /// Get cached thumbnail
  Future<Map<String, dynamic>?> getThumbnail(
    String projectId,
    String imageId,
  ) async {
    try {
      final box = Hive.box<Map>(_thumbnailBox);
      final key = '${projectId}_$imageId';
      final data = box.get(key);
      if (data != null) {
        debugPrint('[HiveCache] 📸 Thumbnail retrieved: $key');
      }
      return data != null ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error retrieving thumbnail: $e');
      return null;
    }
  }

  /// Get all thumbnails for a project
  Future<List<Map<String, dynamic>>> getThumbnailsByProject(
    String projectId,
  ) async {
    try {
      final box = Hive.box<Map>(_thumbnailBox);
      final results = <Map<String, dynamic>>[];

      for (final key in box.keys) {
        if (key is String && key.startsWith('${projectId}_')) {
          final data = box.get(key);
          if (data != null) {
            results.add(Map<String, dynamic>.from(data));
          }
        }
      }

      debugPrint(
        '[HiveCache] 📸 Retrieved ${results.length} thumbnails for project $projectId',
      );
      return results;
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error retrieving project thumbnails: $e');
      return [];
    }
  }

  /// Cache an image
  Future<void> cacheImage(
    String projectId,
    String imageId,
    Map<String, dynamic> data,
  ) async {
    try {
      final box = Hive.box<Map>(_imagesBox);
      final key = '${projectId}_$imageId';
      await box.put(key, Map<String, dynamic>.from(data));
      debugPrint('[HiveCache] 🖼️ Image cached: $key');
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error caching image: $e');
    }
  }

  /// Get cached image
  Future<Map<String, dynamic>?> getImage(
    String projectId,
    String imageId,
  ) async {
    try {
      final box = Hive.box<Map>(_imagesBox);
      final key = '${projectId}_$imageId';
      final data = box.get(key);
      if (data != null) {
        debugPrint('[HiveCache] 🖼️ Image retrieved: $key');
      }
      return data != null ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error retrieving image: $e');
      return null;
    }
  }

  /// Get all images for a project
  Future<List<Map<String, dynamic>>> getImagesByProject(
    String projectId,
  ) async {
    try {
      final box = Hive.box<Map>(_imagesBox);
      final results = <Map<String, dynamic>>[];

      for (final key in box.keys) {
        if (key is String && key.startsWith('${projectId}_')) {
          final data = box.get(key);
          if (data != null) {
            results.add(Map<String, dynamic>.from(data));
          }
        }
      }

      debugPrint(
        '[HiveCache] 🖼️ Retrieved ${results.length} images for project $projectId',
      );
      return results;
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error retrieving project images: $e');
      return [];
    }
  }

  /// Cache a report
  Future<void> cacheReport(
    String projectId,
    String reportId,
    Map<String, dynamic> data,
  ) async {
    try {
      final box = Hive.box<Map>(_reportsBox);
      final key = '${projectId}_$reportId';
      await box.put(key, Map<String, dynamic>.from(data));
      debugPrint('[HiveCache] 📊 Report cached: $key');
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error caching report: $e');
    }
  }

  /// Get cached report
  Future<Map<String, dynamic>?> getReport(
    String projectId,
    String reportId,
  ) async {
    try {
      final box = Hive.box<Map>(_reportsBox);
      final key = '${projectId}_$reportId';
      final data = box.get(key);
      if (data != null) {
        debugPrint('[HiveCache] 📊 Report retrieved: $key');
      }
      return data != null ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error retrieving report: $e');
      return null;
    }
  }

  /// Cache a document
  Future<void> cacheDocument(
    String projectId,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final box = Hive.box<Map>(_documentsBox);
      final key = '${projectId}_$documentId';
      await box.put(key, Map<String, dynamic>.from(data));
      debugPrint('[HiveCache] 📄 Document cached: $key');
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error caching document: $e');
    }
  }

  /// Get cached document
  Future<Map<String, dynamic>?> getDocument(
    String projectId,
    String documentId,
  ) async {
    try {
      final box = Hive.box<Map>(_documentsBox);
      final key = '${projectId}_$documentId';
      final data = box.get(key);
      if (data != null) {
        debugPrint('[HiveCache] 📄 Document retrieved: $key');
      }
      return data != null ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error retrieving document: $e');
      return null;
    }
  }

  /// Add to sync queue (items pending sync to backend)
  Future<void> addToSyncQueue(
    String projectId,
    String resourceType, // 'thumbnail', 'image', 'report', 'document'
    String resourceId,
    Map<String, dynamic> data,
  ) async {
    try {
      final box = Hive.box<Map>(_syncQueueBox);
      final key = '${projectId}_${resourceType}_$resourceId';
      final syncItem = {
        'projectId': projectId,
        'resourceType': resourceType,
        'resourceId': resourceId,
        'data': data,
        'createdAt': DateTime.now().toIso8601String(),
        'synced': false,
      };
      await box.put(key, Map<String, dynamic>.from(syncItem));
      debugPrint('[HiveCache] 📤 Added to sync queue: $key');
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error adding to sync queue: $e');
    }
  }

  /// Get all pending sync items
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    try {
      final box = Hive.box<Map>(_syncQueueBox);
      final results = <Map<String, dynamic>>[];

      for (final key in box.keys) {
        final data = box.get(key);
        if (data != null) {
          final syncData = Map<String, dynamic>.from(data);
          if (syncData['synced'] != true) {
            results.add(syncData);
          }
        }
      }

      debugPrint(
        '[HiveCache] 📤 Retrieved ${results.length} pending sync items',
      );
      return results;
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error retrieving sync queue: $e');
      return [];
    }
  }

  /// Mark sync item as synced
  Future<void> markSynced(
    String projectId,
    String resourceType,
    String resourceId,
  ) async {
    try {
      final box = Hive.box<Map>(_syncQueueBox);
      final key = '${projectId}_${resourceType}_$resourceId';
      final data = box.get(key);

      if (data != null) {
        final syncData = Map<String, dynamic>.from(data);
        syncData['synced'] = true;
        syncData['syncedAt'] = DateTime.now().toIso8601String();
        await box.put(key, syncData);
        debugPrint('[HiveCache] ✅ Marked as synced: $key');
      }
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error marking as synced: $e');
    }
  }

  /// Clear cache for a specific project
  Future<void> clearProjectCache(String projectId) async {
    try {
      await _clearBoxByProjectId(_thumbnailBox, projectId);
      await _clearBoxByProjectId(_imagesBox, projectId);
      await _clearBoxByProjectId(_reportsBox, projectId);
      await _clearBoxByProjectId(_documentsBox, projectId);
      debugPrint('[HiveCache] 🗑️ Cleared all cache for project $projectId');
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error clearing project cache: $e');
    }
  }

  /// Helper to clear a box by project ID
  Future<void> _clearBoxByProjectId(String boxName, String projectId) async {
    try {
      final box = Hive.box<Map>(boxName);
      final keysToDelete = <dynamic>[];

      for (final key in box.keys) {
        if (key is String && key.startsWith('${projectId}_')) {
          keysToDelete.add(key);
        }
      }

      for (final key in keysToDelete) {
        await box.delete(key);
      }

      debugPrint('[HiveCache] 🗑️ Cleared $boxName for project $projectId');
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error clearing box: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    try {
      await Hive.box<Map>(_thumbnailBox).clear();
      await Hive.box<Map>(_imagesBox).clear();
      await Hive.box<Map>(_reportsBox).clear();
      await Hive.box<Map>(_documentsBox).clear();
      await Hive.box<Map>(_syncQueueBox).clear();
      debugPrint('[HiveCache] 🗑️ Cleared all cache');
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error clearing all cache: $e');
    }
  }

  /// Get cache stats
  Future<Map<String, int>> getCacheStats() async {
    try {
      return {
        'thumbnails': Hive.box<Map>(_thumbnailBox).length,
        'images': Hive.box<Map>(_imagesBox).length,
        'reports': Hive.box<Map>(_reportsBox).length,
        'documents': Hive.box<Map>(_documentsBox).length,
        'syncQueue': Hive.box<Map>(_syncQueueBox).length,
      };
    } catch (e) {
      debugPrint('[HiveCache] ❌ Error getting cache stats: $e');
      return {};
    }
  }
}
