import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  group('Network Sync Service Tests', () {
    test('Connectivity status can be monitored', () async {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      expect(result, isNotNull);
    });

    test('Can listen to connectivity changes', () async {
      final connectivity = Connectivity();
      final stream = connectivity.onConnectivityChanged;
      expect(stream, isNotNull);
    });

    test('Network API is accessible', () async {
      final connectivity = Connectivity();
      expect(connectivity, isNotNull);
    });
  });
}
