import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:converf/core/media/app_image_picker.dart';
import '../../../../../features/contractors/models/contractor_models.dart';
import '../../../../../features/contractors/providers/contractor_providers.dart';

class AddPortfolioItemScreen extends ConsumerStatefulWidget {
  final ContractorPortfolioItem? initialItem;

  const AddPortfolioItemScreen({super.key, this.initialItem});

  @override
  ConsumerState<AddPortfolioItemScreen> createState() => _AddPortfolioItemScreenState();
}

class _AddPortfolioItemScreenState extends ConsumerState<AddPortfolioItemScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _budgetController;
  late TextEditingController _descriptionController;
  
  String _constructionType = 'Residential';
  String _status = 'Completed';
  XFile? _imageFile;
  bool _isUploading = false;

  final List<String> _constructionTypes = [
    'Residential',
    'Commercial',
    'Industrial',
    'Infrastructure',
    'Renovation',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialItem?.title);
    _locationController = TextEditingController(text: widget.initialItem?.location);
    _cityController = TextEditingController(text: widget.initialItem?.city);
    _stateController = TextEditingController(text: widget.initialItem?.state);
    _budgetController = TextEditingController(text: widget.initialItem?.budget?.toString());
    _descriptionController = TextEditingController(text: widget.initialItem?.description);
    
    if (widget.initialItem?.constructionType != null) {
      _constructionType = widget.initialItem!.constructionType!;
    }
    if (widget.initialItem?.status != null) {
      _status = widget.initialItem!.status!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ref.read(appImagePickerProvider).pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _imageFile = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null && widget.initialItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a cover image')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final payload = ContractorPortfolioPayload(
        title: _titleController.text,
        location: _locationController.text,
        city: _cityController.text,
        state: _stateController.text,
        constructionType: _constructionType,
        budget: num.tryParse(_budgetController.text),
        status: _status.toLowerCase(),
        description: _descriptionController.text,
        coverImage: _imageFile?.path,
      );

      if (widget.initialItem != null) {
        await ref.read(portfolioNotifierProvider.notifier).updateItem(widget.initialItem!.id, payload);
      } else {
        await ref.read(portfolioNotifierProvider.notifier).createItem(payload);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project ${widget.initialItem != null ? 'updated' : 'added'} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.initialItem != null ? 'Edit Project' : 'Add New Project',
          style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEAECF0), width: 2),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                        )
                      : widget.initialItem?.coverImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(widget.initialItem!.coverImage!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                const Text('Upload Project Cover Photo', 
                                  style: TextStyle(color: Color(0xFF667085), fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                const Text('JPG, PNG or GIF (max. 5MB)', 
                                  style: TextStyle(color: Color(0xFF98A2B3), fontSize: 12)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 32),

              _buildLabel('Project Title'),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('e.g. Modern Residential Complex'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Construction Type'),
                        DropdownButtonFormField<String>(
                          initialValue: _constructionType,
                          decoration: _inputDecoration(''),
                          items: _constructionTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setState(() => _constructionType = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Status'),
                        DropdownButtonFormField<String>(
                          initialValue: _status,
                          decoration: _inputDecoration(''),
                          items: ['Completed', 'Ongoing'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() => _status = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildLabel('Location (Street Address)'),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration('e.g. 123 Lekki Phase 1'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('City'),
                        TextFormField(
                          controller: _cityController,
                          decoration: _inputDecoration('e.g. Lagos'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('State'),
                        TextFormField(
                          controller: _stateController,
                          decoration: _inputDecoration('e.g. Lagos State'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildLabel('Project Budget (₦)'),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('e.g. 50000000'),
              ),
              const SizedBox(height: 20),

              _buildLabel('Project Description'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration('Tell us about the project scope, challenges, and success...'),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF276572),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.initialItem != null ? 'Update Project' : 'Publish to Portfolio',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF344054)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF276572), width: 2),
      ),
    );
  }
}
