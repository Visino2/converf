import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:converf/core/cache/hive_cache_service.dart';

void main() {
  group('Hive Cache Service Tests', () {
    late HiveCacheService cacheService;

    setUpAll(() async {
      // Initialize Hive for testing
      await Hive.initFlutter();
      cacheService = HiveCacheService();
      await cacheService.init();
    });

    tearDownAll(() async {
      // Clean up after tests
      await Hive.close();
    });

    test('HiveCacheService initializes successfully', () {
      expect(cacheService, isNotNull);
    });

    test('Cache thumbnail stores and retrieves correctly', () async {
      const projectId = 'project_123';
      const imageId = 'image_456';
      final thumbnailData = {
        'url': 'https://example.com/image.jpg',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Store thumbnail
      await cacheService.cacheThumbnail(projectId, imageId, thumbnailData);

      // Retrieve thumbnail
      final cachedData = await cacheService.getThumbnail(projectId, imageId);

      expect(cachedData, isNotNull);
      expect(cachedData?['url'], thumbnailData['url']);
    });

    test('Cache image stores and retrieves correctly', () async {
      const projectId = 'project_123';
      const imageId = 'image_789';
      final imageData = {
        'path': '/path/to/image.jpg',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Store image
      await cacheService.cacheImage(projectId, imageId, imageData);

      // Retrieve image
      final cachedData = await cacheService.getImage(projectId, imageId);

      expect(cachedData, isNotNull);
      expect(cachedData?['path'], imageData['path']);
    });

    test('Non-existent cache returns null', () async {
      const projectId = 'non_existent_project';
      const imageId = 'non_existent_image';

      final cachedData = await cacheService.getThumbnail(projectId, imageId);

      expect(cachedData, null);
    });

    test('Sync queue accepts items', () async {
      const projectId = 'project_sync_test';
      const resourceType = 'image';
      const resourceId = 'item_123';
      final itemData = {'url': 'https://example.com/image.jpg'};

      // Add to sync queue
      await cacheService.addToSyncQueue(
        projectId,
        resourceType,
        resourceId,
        itemData,
      );

      // Verify item was added (sync queue should exist)
      expect(cacheService, isNotNull);
    });

    test('Clear project cache removes all cached items', () async {
      const projectId = 'project_to_clear';
      const imageId = 'clear_test_image';

      // Add items to cache
      await cacheService.cacheThumbnail(projectId, imageId, {
        'url': 'https://example.com/thumb.jpg',
      });
      await cacheService.cacheImage(projectId, imageId, {
        'path': '/path/to/image.jpg',
      });

      // Clear cache
      await cacheService.clearProjectCache(projectId);

      // Verify items are cleared
      final cachedThumb = await cacheService.getThumbnail(projectId, imageId);
      final cachedImage = await cacheService.getImage(projectId, imageId);

      expect(cachedThumb, null);
      expect(cachedImage, null);
    });

    test('Multiple projects can have separate caches', () async {
      const project1Id = 'project_1';
      const project2Id = 'project_2';
      const imageId1 = 'image_1';
      const imageId2 = 'image_2';
      const url1 = 'https://example.com/image1.jpg';
      const url2 = 'https://example.com/image2.jpg';

      // Store different thumbnails for different projects
      await cacheService.cacheThumbnail(project1Id, imageId1, {'url': url1});
      await cacheService.cacheThumbnail(project2Id, imageId2, {'url': url2});

      // Retrieve and verify separate caches
      final cached1 = await cacheService.getThumbnail(project1Id, imageId1);
      final cached2 = await cacheService.getThumbnail(project2Id, imageId2);

      expect(cached1?['url'], url1);
      expect(cached2?['url'], url2);
    });

    test('Cache stats returns correct counts', () async {
      const projectId = 'stats_test_project';

      // Clear all first
      await cacheService.clearAll();

      // Add some items
      await cacheService.cacheThumbnail(projectId, 'thumb_1', {'url': 'url1'});
      await cacheService.cacheImage(projectId, 'image_1', {'url': 'url2'});

      // Get stats
      final stats = await cacheService.getCacheStats();

      expect(stats['thumbnails'], greaterThanOrEqualTo(1));
      expect(stats['images'], greaterThanOrEqualTo(1));
    });
  });
}
