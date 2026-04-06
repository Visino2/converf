import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../features/projects/models/project.dart';
import '../../../features/projects/providers/site_checkin_provider.dart';

/// Mobile-optimised GPS tab for contractors.
/// Shows real-time distance, "Navigate", and "Check-in" functionality.
class SiteGpsTab extends ConsumerStatefulWidget {
  final Project project;

  const SiteGpsTab({super.key, required this.project});

  @override
  ConsumerState<SiteGpsTab> createState() => _SiteGpsTabState();
}

class _SiteGpsTabState extends ConsumerState<SiteGpsTab>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  Position? _currentPosition;
  double? _distanceM;
  bool _locationReady = false;
  bool _locationError = false;
  String _locationErrorMsg = '';
  bool _checkInLoading = false;
  SiteCheckIn? _lastCheckIn;
  late AnimationController _pulseController;

  static const LatLng _defaultCenter = LatLng(6.5244, 3.3792); // Lagos

  LatLng? get _siteLatLng {
    final lat = widget.project.siteLatitude;
    final lng = widget.project.siteLongitude;
    if (lat != null && lng != null) return LatLng(lat, lng);
    return null;
  }

  double get _geofenceRadius =>
      (widget.project.siteGeofenceRadiusM ?? 150).toDouble();

  bool get _isInsideGeofence =>
      _distanceM != null && _distanceM! <= _geofenceRadius;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _initLocationStream();
    _loadCheckInHistory();
  }

  Future<void> _loadCheckInHistory() async {
    final history =
        await SiteCheckInService.loadHistory(widget.project.id);
    if (mounted && history.isNotEmpty) {
      setState(() => _lastCheckIn = history.first);
    }
  }

  Future<void> _initLocationStream() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = true;
          _locationErrorMsg = 'Location services are disabled. '
              'Please enable GPS in your device settings.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = true;
            _locationErrorMsg = 'Location permission denied.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = true;
          _locationErrorMsg =
              'Location permissions are permanently denied. '
              'Please enable them in your device settings.';
        });
        return;
      }

      // Get initial position
      final initial = await Geolocator.getCurrentPosition();
      _onPositionUpdate(initial);

      // Start listening for updates
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // update every 5 meters
        ),
      ).listen(
        _onPositionUpdate,
        onError: (e) {
          debugPrint('[SiteGpsTab] Position stream error: $e');
        },
      );
    } catch (e) {
      setState(() {
        _locationError = true;
        _locationErrorMsg = e.toString();
      });
    }
  }

  void _onPositionUpdate(Position position) {
    if (!mounted) return;

    double? dist;
    final site = _siteLatLng;
    if (site != null) {
      dist = haversineDistanceM(
        position.latitude,
        position.longitude,
        site.latitude,
        site.longitude,
      );
    }

    setState(() {
      _currentPosition = position;
      _distanceM = dist;
      _locationReady = true;
    });
  }

  String get _formattedDistance {
    if (_distanceM == null) return '--';
    if (_distanceM! >= 1000) {
      return '${(_distanceM! / 1000).toStringAsFixed(1)} km';
    }
    return '${_distanceM!.toInt()} m';
  }

  Future<void> _navigateToSite() async {
    final site = _siteLatLng;
    if (site == null) return;

    // Try Google Maps first, then Apple Maps, then web fallback
    final googleUrl = Uri.parse(
      'google.navigation:q=${site.latitude},${site.longitude}&mode=d',
    );
    final appleUrl = Uri.parse(
      'https://maps.apple.com/?daddr=${site.latitude},${site.longitude}&dirflg=d',
    );
    final webUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${site.latitude},${site.longitude}&travelmode=driving',
    );

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl);
    } else if (await canLaunchUrl(appleUrl)) {
      await launchUrl(appleUrl);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _performCheckIn() async {
    final site = _siteLatLng;
    if (site == null) return;

    setState(() => _checkInLoading = true);

    try {
      final record = await SiteCheckInService.checkIn(
        projectId: widget.project.id,
        siteLat: site.latitude,
        siteLng: site.longitude,
        radiusM: _geofenceRadius,
      );
      if (mounted) {
        setState(() {
          _checkInLoading = false;
          _lastCheckIn = record;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Site check-in successful!'),
              ],
            ),
            backgroundColor: const Color(0xFF12B76A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _checkInLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFD42620),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _centerOnUser() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15,
      );
    }
  }

  void _centerOnSite() {
    final site = _siteLatLng;
    if (site != null) {
      _mapController.move(site, 15);
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ───────────────────────────── BUILD ─────────────────────────────

  @override
  Widget build(BuildContext context) {
    final site = _siteLatLng;

    return Stack(
      children: [
        // ── Map ──
        _buildMap(site),

        // ── Distance Banner ──
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildDistanceBanner(),
        ),

        // ── Map controls ──
        Positioned(
          right: 16,
          top: 80,
          child: Column(
            children: [
              _buildMapButton(Icons.my_location, _centerOnUser),
              const SizedBox(height: 8),
              if (site != null)
                _buildMapButton(Icons.location_on, _centerOnSite),
            ],
          ),
        ),

        // ── Bottom Panel ──
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomPanel(site),
        ),
      ],
    );
  }

  Widget _buildMap(LatLng? site) {
    final center = site ?? _defaultCenter;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: center, initialZoom: 14),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.converf.app',
        ),

        // Geofence circle
        if (site != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: site,
                radius: _geofenceRadius,
                useRadiusInMeter: true,
                color: _isInsideGeofence
                    ? const Color(0xFF12B76A).withValues(alpha: 0.15)
                    : const Color(0xFFD42620).withValues(alpha: 0.1),
                borderColor: _isInsideGeofence
                    ? const Color(0xFF12B76A)
                    : const Color(0xFFD42620),
                borderStrokeWidth: 2,
              ),
            ],
          ),

        // Site pin
        if (site != null)
          MarkerLayer(
            markers: [
              Marker(
                point: site,
                width: 44,
                height: 44,
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFFD42620),
                  size: 44,
                ),
              ),
            ],
          ),

        // User position — animated pulsing dot
        if (_currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                width: 28,
                height: 28,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.35);
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF276572),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF276572).withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDistanceBanner() {
    Color bgColor;
    IconData icon;
    String text;

    if (_locationError) {
      bgColor = const Color(0xFFFEF3F2);
      icon = Icons.location_off;
      text = _locationErrorMsg;
    } else if (!_locationReady) {
      bgColor = const Color(0xFFF9FAFB);
      icon = Icons.gps_not_fixed;
      text = 'Acquiring GPS signal...';
    } else if (_siteLatLng == null) {
      bgColor = const Color(0xFFFFFAEB);
      icon = Icons.warning_amber_rounded;
      text = 'No site coordinates set for this project.';
    } else if (_isInsideGeofence) {
      bgColor = const Color(0xFFECFDF3);
      icon = Icons.check_circle;
      text = 'You are on site • $_formattedDistance away';
    } else {
      bgColor = const Color(0xFFF9FAFB);
      icon = Icons.navigation_outlined;
      text = '$_formattedDistance from site';
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: _isInsideGeofence
                ? const Color(0xFF12B76A)
                : const Color(0xFF344054),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _isInsideGeofence
                    ? const Color(0xFF027A48)
                    : const Color(0xFF344054),
              ),
            ),
          ),
          if (!_locationReady && !_locationError)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onTap) {
    return Material(
      elevation: 3,
      shape: const CircleBorder(),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: const Color(0xFF344054)),
        ),
      ),
    );
  }

  Widget _buildBottomPanel(LatLng? site) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Site Info Row ──
              _buildSiteInfoRow(site),

              const SizedBox(height: 16),

              // ── Action Buttons ──
              Row(
                children: [
                  // Navigate button
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.navigation_rounded,
                      label: 'Navigate',
                      color: const Color(0xFF276572),
                      textColor: Colors.white,
                      onTap: site != null ? _navigateToSite : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Check-in button
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.login_rounded,
                      label: _isInsideGeofence ? 'Check In' : 'Too Far',
                      color: _isInsideGeofence
                          ? const Color(0xFF12B76A)
                          : const Color(0xFFE4E7EC),
                      textColor: _isInsideGeofence
                          ? Colors.white
                          : const Color(0xFF98A2B3),
                      onTap: _isInsideGeofence ? _performCheckIn : null,
                      isLoading: _checkInLoading,
                    ),
                  ),
                ],
              ),

              // ── Last Check-in ──
              if (_lastCheckIn != null) ...[
                const SizedBox(height: 12),
                _buildLastCheckIn(_lastCheckIn!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiteInfoRow(LatLng? site) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF276572).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFF276572),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project.formattedLocation,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 2),
                if (site != null)
                  Text(
                    '${site.latitude.toStringAsFixed(5)}, ${site.longitude.toStringAsFixed(5)}  •  '
                    '${_geofenceRadius.toInt()}m radius',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF667085),
                    ),
                  )
                else
                  const Text(
                    'No coordinates set',
                    style: TextStyle(fontSize: 12, color: Color(0xFF98A2B3)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textColor,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: textColor),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLastCheckIn(SiteCheckIn checkIn) {
    final formatter = DateFormat('MMM d, yyyy • h:mm a');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFF12B76A)),
          const SizedBox(width: 8),
          Text(
            'Last check-in: ${formatter.format(checkIn.timestamp)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF027A48),
            ),
          ),
        ],
      ),
    );
  }
}
