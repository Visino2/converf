import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../features/projects/models/project.dart';
import '../../../../features/projects/providers/project_providers.dart';

class SiteCoordinatesTab extends ConsumerStatefulWidget {
  final Project project;
  final bool canEdit;

  const SiteCoordinatesTab({
    super.key,
    required this.project,
    this.canEdit = false,
  });

  @override
  ConsumerState<SiteCoordinatesTab> createState() => _SiteCoordinatesTabState();
}

class _SiteCoordinatesTabState extends ConsumerState<SiteCoordinatesTab> {
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _radiusController;
  final MapController _mapController = MapController();

  static const LatLng _defaultCenter = LatLng(6.5244, 3.3792); // Lagos

  @override
  void initState() {
    super.initState();
    _latController = TextEditingController(
      text: widget.project.siteLatitude?.toString() ?? '',
    );
    _lngController = TextEditingController(
      text: widget.project.siteLongitude?.toString() ?? '',
    );
    _radiusController = TextEditingController(
      text: (widget.project.siteGeofenceRadiusM ?? 150).toString(),
    );
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  LatLng get _currentLatLng {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
    return _defaultCenter;
  }

  double get _currentRadius {
    return double.tryParse(_radiusController.text) ?? 150.0;
  }

  Future<void> _useCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _lngController.text = position.longitude.toStringAsFixed(6);
      });
      _mapController.move(LatLng(position.latitude, position.longitude), 15);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _onSave() async {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    final radius = int.tryParse(_radiusController.text);

    if (lat == null || lat < -90 || lat > 90) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Latitude')),
      );
      return;
    }
    if (lng == null || lng < -180 || lng > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Longitude')),
      );
      return;
    }
    if (radius == null || radius < 30 || radius > 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Radius must be between 30m and 10,000m')),
      );
      return;
    }

    try {
      await ref.read(projectSiteProvider.notifier).updateSiteCoordinates(
            widget.project.id,
            latitude: lat,
            longitude: lng,
            geofenceRadiusM: radius,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Site coordinates updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final siteState = ref.watch(projectSiteProvider);
    final hasCoordinates = double.tryParse(_latController.text) != null &&
        double.tryParse(_lngController.text) != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.canEdit) ...[
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: _useCurrentLocation,
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text('Use My Current Location'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF276572),
                  side: const BorderSide(color: Color(0xFFD0D5DD)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD0D5DD)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: hasCoordinates ? _currentLatLng : _defaultCenter,
                  initialZoom: 13,
                  onTap: widget.canEdit
                      ? (tapPosition, point) {
                          setState(() {
                            _latController.text = point.latitude.toStringAsFixed(6);
                            _lngController.text = point.longitude.toStringAsFixed(6);
                          });
                        }
                      : null,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.converf.app',
                  ),
                  if (hasCoordinates) ...[
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _currentLatLng,
                          radius: _currentRadius,
                          useRadiusInMeter: true,
                          color: const Color(0xFF276572).withValues(alpha: 0.2),
                          borderColor: const Color(0xFF276572),
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLatLng,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFFD42620),
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (widget.canEdit) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: 'Latitude',
                          controller: _latController,
                          placeholder: 'e.g., 6.5244',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInputField(
                          label: 'Longitude',
                          controller: _lngController,
                          placeholder: 'e.g., 3.3792',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Geofence Radius (m)',
                    controller: _radiusController,
                    placeholder: '150',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: siteState.isLoading ? null : _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF276572),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: siteState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Coordinates'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType keyboardType = const TextInputType.numberWithOptions(decimal: true),
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF344054),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: placeholder,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF276572), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
