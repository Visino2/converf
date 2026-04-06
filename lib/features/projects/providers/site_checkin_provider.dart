import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A single site check-in record.
class SiteCheckIn {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double distanceToSiteM;

  SiteCheckIn({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.distanceToSiteM,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'distance_to_site_m': distanceToSiteM,
      };

  factory SiteCheckIn.fromJson(Map<String, dynamic> json) => SiteCheckIn(
        timestamp: DateTime.parse(json['timestamp'] as String),
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        distanceToSiteM: (json['distance_to_site_m'] as num).toDouble(),
      );
}

/// Calculates Haversine distance in meters between two lat/lng points.
double haversineDistanceM(
    double lat1, double lon1, double lat2, double lon2) {
  const R = 6371000.0; // Earth radius in meters
  final dLat = _degToRad(lat2 - lat1);
  final dLon = _degToRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) *
          cos(_degToRad(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _degToRad(double deg) => deg * (pi / 180);

/// Utility service for managing site check-ins via SharedPreferences.
class SiteCheckInService {
  static String _storageKey(String projectId) => 'site_checkins_$projectId';

  /// Load check-in history for a project (most recent first).
  static Future<List<SiteCheckIn>> loadHistory(String projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey(projectId));
      if (raw != null) {
        final list = (jsonDecode(raw) as List)
            .map((e) => SiteCheckIn.fromJson(e as Map<String, dynamic>))
            .toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      }
    } catch (_) {
      // Fresh install — no data
    }
    return [];
  }

  /// Save check-in history for a project.
  static Future<void> _saveHistory(
      String projectId, List<SiteCheckIn> history) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey(projectId), encoded);
  }

  /// Perform a GPS check-in. Throws if the user is outside the geofence.
  static Future<SiteCheckIn> checkIn({
    required String projectId,
    required double siteLat,
    required double siteLng,
    required double radiusM,
  }) async {
    final position = await Geolocator.getCurrentPosition();
    final distance = haversineDistanceM(
      position.latitude,
      position.longitude,
      siteLat,
      siteLng,
    );

    if (distance > radiusM) {
      throw Exception(
        'You are ${(distance / 1000).toStringAsFixed(1)} km from the site. '
        'You must be within ${radiusM.toInt()}m to check in.',
      );
    }

    final record = SiteCheckIn(
      timestamp: DateTime.now(),
      latitude: position.latitude,
      longitude: position.longitude,
      distanceToSiteM: distance,
    );

    final history = await loadHistory(projectId);
    final updated = [record, ...history];
    await _saveHistory(projectId, updated);
    return record;
  }
}
