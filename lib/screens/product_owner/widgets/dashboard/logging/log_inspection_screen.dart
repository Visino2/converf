import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:converf/core/media/app_image_picker.dart';
import '../../../../../../features/inspections/models/inspection_models.dart';
import '../../../../../../features/inspections/providers/inspection_providers.dart';
import '../../../../../../features/phases/providers/phase_providers.dart';
import '../../../../../../features/profile/providers/profile_providers.dart';

class LogInspectionScreen extends ConsumerStatefulWidget {
  final String projectId;

  const LogInspectionScreen({super.key, required this.projectId});

  @override
  ConsumerState<LogInspectionScreen> createState() =>
      _LogInspectionScreenState();
}

class _LogInspectionScreenState extends ConsumerState<LogInspectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();
  final _findingsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedPhase;
  final List<File> _images = [];
  String? _locationCoordinates;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _findingsController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _locationCoordinates =
              '${position.latitude},${position.longitude}';
        });
      }
    } catch (_) {
      // Location unavailable — continue without it
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await ref
        .read(appImagePickerProvider)
        .pickImage(source: source, imageQuality: 70, maxWidth: 1920, maxHeight: 1080);
    if (image != null) {
      setState(() => _images.add(File(image.path)));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAECF0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF0F9FF),
                  child: Icon(Icons.camera_alt_outlined, color: Color(0xFF276572)),
                ),
                title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Open camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF0F9FF),
                  child: Icon(Icons.photo_library_outlined, color: Color(0xFF276572)),
                ),
                title: const Text('Upload from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Choose from your phone'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPhase == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a related phase')),
      );
      return;
    }

    final payload = CreateInspectionPayload(
      inspectionDate: _selectedDate.toIso8601String(),
      summary: _summaryController.text.trim(),
      findings: _findingsController.text.trim(),
      status: 'completed',
      phase: _selectedPhase,
      locationCoordinates: _locationCoordinates,
      images: _images.map((f) => f.path).toList(),
    );

    try {
      await ref
          .read(inspectionActionProvider.notifier)
          .createInspection(widget.projectId, payload);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inspection logged successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phasesAsync = ref.watch(phasesProvider(widget.projectId));
    final profileAsync = ref.watch(profileProvider);
    final isSubmitting = ref.watch(inspectionActionProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Log Inspection',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Inspector Info ──────────────────────────────────────────
              _buildSectionTitle('Inspector Information'),
              const SizedBox(height: 8),
              profileAsync.when(
                data: (profile) {
                  final name = '${profile.firstName} ${profile.lastName}'.trim();
                  final company = profile.companyName;
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFB9E6FE)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFF276572),
                          child: Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.isEmpty ? 'Inspector' : name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF101828),
                                ),
                              ),
                              if (company != null && company.isNotEmpty)
                                Text(
                                  company,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF276572),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'QA/QC',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF067647),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(color: Color(0xFF276572)),
                error: (_, e) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // ── Geo-location ────────────────────────────────────────────
              _buildSectionTitle('Location'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD0D5DD)),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF9FAFB),
                ),
                child: Row(
                  children: [
                    Icon(
                      _locationCoordinates != null
                          ? Icons.location_on
                          : Icons.location_off_outlined,
                      size: 18,
                      color: _locationCoordinates != null
                          ? const Color(0xFF067647)
                          : const Color(0xFF667085),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _isFetchingLocation
                          ? const Text('Capturing GPS location...',
                              style: TextStyle(fontSize: 13, color: Color(0xFF667085)))
                          : Text(
                              _locationCoordinates != null
                                  ? 'GPS captured: $_locationCoordinates'
                                  : 'Location unavailable',
                              style: TextStyle(
                                fontSize: 13,
                                color: _locationCoordinates != null
                                    ? const Color(0xFF067647)
                                    : const Color(0xFF667085),
                              ),
                            ),
                    ),
                    if (!_isFetchingLocation)
                      GestureDetector(
                        onTap: _captureLocation,
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF276572),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Date Picker ─────────────────────────────────────────────
              _buildSectionTitle('Inspection Date'),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMMM dd, yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today, size: 20, color: Color(0xFF667085)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Phase Selector ──────────────────────────────────────────
              _buildSectionTitle('Related Phase *'),
              const SizedBox(height: 8),
              phasesAsync.when(
                data: (response) {
                  final phases = response.data;
                  if (phases.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD0D5DD)),
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFF9FAFB),
                      ),
                      child: const Text('No phases found', style: TextStyle(color: Color(0xFF667085))),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedPhase,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                      ),
                    ),
                    items: phases
                        .map((p) => DropdownMenuItem(value: p.name, child: Text(p.name)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedPhase = val),
                    hint: const Text('Select Phase'),
                    validator: (val) => val == null ? 'Please select a phase' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(
                  backgroundColor: Color(0xFFF2F4F7),
                  color: Color(0xFF276572),
                ),
                error: (error, _) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDA29B)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 16, color: Color(0xFFB42318)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Failed to load phases: $error',
                            style: const TextStyle(fontSize: 12, color: Color(0xFFB42318))),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Executive Summary ───────────────────────────────────────
              _buildSectionTitle('Executive Summary *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _summaryController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. Roof truss installation verified against architectural plans...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Summary is required' : null,
              ),
              const SizedBox(height: 24),

              // ── Key Findings ────────────────────────────────────────────
              _buildSectionTitle('Key Findings *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _findingsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. Truss spacing OK, anchoring meets building code...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Key findings are required' : null,
              ),
              const SizedBox(height: 24),

              // ── Photo Proof ─────────────────────────────────────────────
              Row(
                children: [
                  _buildSectionTitle('Photo Proof'),
                  const SizedBox(width: 8),
                  Text(
                    '${_images.length} added',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Take a photo or upload from your gallery',
                style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ..._images.map(
                    (file) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => setState(() => _images.remove(file)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showImageSourceSheet,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD0D5DD)),
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFF9FAFB),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF276572)),
                          Text('Add', style: TextStyle(fontSize: 12, color: Color(0xFF667085))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // ── Submit ──────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF276572),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Inspection',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF344054),
      ),
    );
  }
}
