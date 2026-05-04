import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:converf/features/projects/models/project_document.dart';
import 'package:converf/features/projects/providers/project_document_providers.dart';

class ProjectDocumentsModal extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDocumentsModal({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDocumentsModal> createState() => _ProjectDocumentsModalState();
}

class _ProjectDocumentsModalState extends ConsumerState<ProjectDocumentsModal> {
  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UploadDocumentSheet(projectId: widget.projectId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(projectDocumentsProvider(widget.projectId));

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 1, color: Color(0xFFEAECF0)),
            Expanded(
              child: documentsAsync.when(
                data: (documents) {
                  if (documents.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildDocumentsList(documents);
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error loading documents: $err', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Project Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _showUploadSheet(context),
                icon: const Icon(Icons.upload_file, size: 16, color: Colors.white),
                label: const Text('Upload', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF276572),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  minimumSize: const Size(0, 40),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF667185)),
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFFF2F4F7), shape: BoxShape.circle),
            child: const Icon(Icons.folder_open, size: 48, color: Color(0xFF667185)),
          ),
          const SizedBox(height: 16),
          const Text('No documents uploaded yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF101828))),
          const SizedBox(height: 8),
          const Text('Upload PDFs or Images to share with your team.', style: TextStyle(fontSize: 14, color: Color(0xFF667185))),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _showUploadSheet(context),
            icon: const Icon(Icons.add, size: 18, color: Color(0xFF344054)),
            label: const Text('New Upload', style: TextStyle(color: Color(0xFF344054))),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(List<ProjectDocument> documents) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: documents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = documents[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFEAECF0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF0FBFB), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.insert_drive_file, color: Color(0xFF309DAA)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF101828)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16)),
                          child: Text(
                            doc.type.toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF667185)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          doc.createdAt.toIso8601String().split('T').first,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF667185),
                          ),
                        ),
                        if (doc.formattedSize.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.circle, size: 4, color: Color(0xFFD0D5DD)),
                          const SizedBox(width: 8),
                          Text(doc.formattedSize, style: const TextStyle(fontSize: 12, color: Color(0xFF667185))),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              _buildActionButtons(doc),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(ProjectDocument doc) {
    return Consumer(
      builder: (context, ref, _) {
        final isLoading = ref.watch(projectDocumentNotifierProvider).isLoading;
        return Row(
          children: [
            IconButton(
              icon: const Icon(Icons.download_rounded, color: Color(0xFF667185)),
              tooltip: 'Download',
              onPressed: isLoading ? null : () async {
                try {
                  await ref.read(projectDocumentNotifierProvider.notifier).downloadAndOpenDocument(widget.projectId, doc);
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download: $e')));
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFD42620)),
              tooltip: 'Delete',
              onPressed: isLoading ? null : () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Document'),
                    content: Text('Are you sure you want to delete "${doc.name}"?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    await ref
                        .read(projectDocumentNotifierProvider.notifier)
                        .deleteDocument(widget.projectId, doc.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Document deleted'), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _UploadDocumentSheet extends ConsumerStatefulWidget {
  final String projectId;
  const _UploadDocumentSheet({required this.projectId});

  @override
  ConsumerState<_UploadDocumentSheet> createState() => _UploadDocumentSheetState();
}

class _UploadDocumentSheetState extends ConsumerState<_UploadDocumentSheet> {
  final _nameController = TextEditingController();
  String? _selectedType;
  File? _selectedFile;

  final List<String> _types = ['design', 'contract', 'permit', 'report', 'other'];

  @override
  void initState() {
    super.initState();
    _selectedType = _types.first;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );
    if (result != null && result.files.single.path != null) {
      final sizeInBytes = result.files.single.size;
      const maxBytes = 5 * 1024 * 1024; // Increased to 5MB
      if (sizeInBytes > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File is larger than 5MB. Please choose a smaller file.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedFile == null || _selectedType == null) return;
    try {
      await ref.read(projectDocumentNotifierProvider.notifier).uploadDocument(
        projectId: widget.projectId,
        filePath: _selectedFile!.path,
        type: _selectedType!,
        name: _nameController.text.trim().isEmpty ? _selectedFile!.path.split('/').last : _nameController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(projectDocumentNotifierProvider).isLoading;
    final isFormValid = _selectedFile != null && _selectedType != null && !isLoading;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Upload Document', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF667185)),
                  tooltip: 'Close',
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Upload a PDF or image document to this project (max 5MB)', style: TextStyle(fontSize: 14, color: Color(0xFF667185))),
            const SizedBox(height: 20),

            // File Picker
            GestureDetector(
              onTap: isLoading ? null : _pickFile,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _selectedFile != null ? const Color(0xFFF0FBFB) : Colors.white,
                  border: Border.all(color: _selectedFile != null ? const Color(0xFF309DAA) : const Color(0xFFD0D5DD), style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 32, color: Color(0xFF276572)),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFile != null ? _selectedFile!.path.split('/').last : 'Tap to select a file',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF101828)),
                      textAlign: TextAlign.center,
                    ),
                    if (_selectedFile == null)
                      const Text('PDF, PNG, JPG, JPEG', style: TextStyle(fontSize: 12, color: Color(0xFF667185))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Type Dropdown
            const Text('Document Type*', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF344054))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD0D5DD)), borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  hint: const Text('Select a type'),
                  isExpanded: true,
                  items: _types.map((type) => DropdownMenuItem(value: type, child: Text(type.toUpperCase()))).toList(),
                  onChanged: isLoading ? null : (val) => setState(() => _selectedType = val),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name Input
            const Text('Document Name (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF344054))),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              enabled: !isLoading,
              decoration: InputDecoration(
                hintText: 'Leave blank to use file name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isFormValid ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF276572),
                      disabledBackgroundColor: const Color(0xFFEAECF0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Upload Document', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
