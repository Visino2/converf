import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:converf/core/media/app_image_picker.dart';
import '../../../../../../features/inspections/models/inspection_models.dart';
import '../../../../../../features/inspections/providers/inspection_providers.dart';
import '../../../../../../features/phases/providers/phase_providers.dart';

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

  @override
  void dispose() {
    _summaryController.dispose();
    _findingsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await ref
        .read(appImagePickerProvider)
        .pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
          maxWidth: 1920,
          maxHeight: 1080,
        );
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = CreateInspectionPayload(
      inspectionDate: _selectedDate.toIso8601String(),
      summary: _summaryController.text,
      findings: _findingsController.text,
      status: 'completed',
      phase: _selectedPhase,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phasesAsync = ref.watch(phasesProvider(widget.projectId));
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
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMMM dd, yyyy').format(_selectedDate)),
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Color(0xFF667085),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Phase Selector
              _buildSectionTitle('Related Phase'),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                      ),
                    ),
                    items: phases
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.name,
                            child: Text(p.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedPhase = val),
                    hint: const Text('Select Phase'),
                  );
                },
                loading: () => const LinearProgressIndicator(
                  backgroundColor: Color(0xFFF2F4F7),
                  color: Color(0xFF276572),
                ),
                error: (error, stackTrace) => Container(
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
                        child: Text(
                          'Failed to load phases: $error',
                          style: const TextStyle(fontSize: 12, color: Color(0xFFB42318)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Summary
              _buildSectionTitle('Executive Summary'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _summaryController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'e.g. Roof truss installation verified against architectural plans...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Summary is required' : null,
              ),
              const SizedBox(height: 24),

              // Findings
              _buildSectionTitle('Key Findings'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _findingsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'e.g. Truss spacing OK, anchoring meets building code...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Photo Proof
              _buildSectionTitle('Photo Proof'),
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
                          child: Image.file(
                            file,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
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
                              child: const Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFD0D5DD),
                          style: BorderStyle.solid,
                        ), // Actually I want dashed
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFF9FAFB),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Color(0xFF667085),
                          ),
                          Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF276572),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Inspection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
