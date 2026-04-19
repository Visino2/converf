import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:converf/core/media/app_image_picker.dart';

import 'package:converf/features/projects/models/project_image.dart';
import 'package:converf/features/projects/providers/project_image_providers.dart';

// ─── Main Modal ──────────────────────────────────────────────────────────────
class ProjectImagesModal extends ConsumerWidget {
  final String projectId;
  final bool isEmbedded;

  const ProjectImagesModal({
    super.key,
    required this.projectId,
    this.isEmbedded = false,
  });

  void _showUploadSheet(BuildContext context, bool hasExistingPrimary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UploadImageSheet(
        projectId: projectId,
        hasExistingPrimary: hasExistingPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(projectImagesProvider(projectId));

    final content = Column(
      children: [
        if (!isEmbedded) ...[
          _buildHandle(),
          _buildHeader(context, ref, imagesAsync.asData?.value ?? []),
          const Divider(height: 1, color: Color(0xFFEAECF0)),
        ],
        Expanded(
          child: imagesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF276572)),
            ),
            error: (e, _) => Center(
              child: Text(
                'Error loading images: $e',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            data: (images) {
              if (images.isEmpty) return _buildEmpty(context, false);
              return _buildGrid(context, ref, images);
            },
          ),
        ),
      ],
    );

    if (isEmbedded) return content;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: content,
    );
  }

  Widget _buildHandle() => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 4),
    child: Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFD0D5DD),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ),
  );

  Widget _buildHeader(BuildContext context, WidgetRef ref, List<ProjectImage> images) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Project Images',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${images.length} photo${images.length != 1 ? 's' : ''} uploaded',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          if (images.length < 3)
            ElevatedButton.icon(
              onPressed: () =>
                  _showUploadSheet(context, images.any((i) => i.isPrimary)),
              icon: const Icon(
                Icons.upload_rounded,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                'Upload',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF276572),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                elevation: 0,
              ),
            )
          else
            const Badge(
              label: Text('LIMIT REACHED'),
              backgroundColor: Color(0xFFFEE4E2),
              textColor: Color(0xFFB42318),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          if (images.isNotEmpty) ...[
            GestureDetector(
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete All Images?'),
                    content: const Text('This will remove all cover photos for this project. This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Delete All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  try {
                    await ref.read(projectImageNotifierProvider.notifier).deleteAllImages(
                          projectId,
                          images.map((i) => i.id).toList(),
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All images deleted')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete: $e')),
                      );
                    }
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE4E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep_outlined,
                  size: 18,
                  color: Color(0xFFB42318),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF2F4F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 18,
                color: Color(0xFF667085),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, bool hasExistingPrimary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 52,
                color: Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No images yet.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload project photos to document progress.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _showUploadSheet(context, hasExistingPrimary),
              icon: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 18,
                color: Color(0xFF276572),
              ),
              label: const Text(
                'Upload Images',
                style: TextStyle(
                  color: Color(0xFF276572),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                side: const BorderSide(color: Color(0xFF276572)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    List<ProjectImage> images,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78, // portrait-ish card to show caption
      ),
      itemCount: images.length,
      itemBuilder: (ctx, i) =>
          _ImageCard(image: images[i], projectId: projectId),
    );
  }
}

// ─── Individual Image Card (mirrors the web `figure` element) ────────────────
class _ImageCard extends ConsumerWidget {
  final ProjectImage image;
  final String projectId;
  const _ImageCard({required this.image, required this.projectId});

  String _formatFileSize(int bytes) {
    final kb = (bytes / 1024).ceil();
    return '$kb KB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(projectImageNotifierProvider).isLoading;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        // Teal border for primary image, grey otherwise — same as web
        border: Border.all(
          color: image.isPrimary
              ? const Color(0xFF309DAA)
              : const Color(0xFFEAECF0),
          width: image.isPrimary ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Image area with Primary badge overlay ──────────────────
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(11),
                  ),
                  child: image.fileUrl.isNotEmpty
                      ? Image.network(
                          '${image.fileUrl}${image.fileUrl.contains('?') ? '&' : '?'}t=${DateTime.now().millisecondsSinceEpoch}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: const Color(0xFFE4E7EC),
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: Color(0xFF9E9E9E),
                                  size: 36,
                                ),
                              ),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: const Color(0xFFE4E7EC),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF276572),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: const Color(0xFFE4E7EC),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF9E9E9E),
                            size: 36,
                          ),
                        ),
                ),

                // Primary badge — top-left overlay like the web
                if (image.isPrimary)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FBFB),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Primary',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF276572),
                        ),
                      ),
                    ),
                  ),

                // Delete button — top-right overlay
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: isLoading
                        ? null
                        : () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Image'),
                                content: const Text(
                                  'Are you sure you want to delete this image?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              try {
                                await ref
                                    .read(projectImageNotifierProvider.notifier)
                                    .deleteImage(projectId, image.id);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to delete: $e'),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Caption + metadata ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  image.caption?.trim().isNotEmpty == true
                      ? image.caption!
                      : 'Photo',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatFileSize(image.fileSize)} • ${image.mimeType}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF667185),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Upload Bottom Sheet ─────────────────────────────────────────────────────
class _UploadImageSheet extends ConsumerStatefulWidget {
  final String projectId;
  final bool hasExistingPrimary;
  const _UploadImageSheet({
    required this.projectId,
    required this.hasExistingPrimary,
  });

  @override
  ConsumerState<_UploadImageSheet> createState() => _UploadImageSheetState();
}

class _UploadImageSheetState extends ConsumerState<_UploadImageSheet> {
  File? _selectedFile;
  final _captionController = TextEditingController();
  bool _setAsPrimary = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ref
        .read(appImagePickerProvider)
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _selectedFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_selectedFile == null) return;
    try {
      await ref
          .read(projectImageNotifierProvider.notifier)
          .uploadImage(
            projectId: widget.projectId,
            filePath: _selectedFile!.path,
            caption: _captionController.text.trim().isEmpty
                ? null
                : _captionController.text.trim(),
            // Only offer set-as-primary when no primary exists
            isPrimary: !widget.hasExistingPrimary && _setAsPrimary,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString()
            .replaceAll('ApiException: ', '')
            .replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(projectImageNotifierProvider).isLoading;
    final isFormValid = _selectedFile != null && !isLoading;
    final canShowPrimaryToggle = !widget.hasExistingPrimary;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Photo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF171717),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Upload a project image (max 5MB)',
                      style: TextStyle(fontSize: 13, color: Color(0xFF737373)),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F4F7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF667085),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── File picker zone — dashed border like web ─────────────
            GestureDetector(
              onTap: isLoading ? null : _pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _selectedFile != null
                      ? const Color(0xFFF0FBFB)
                      : Colors.white,
                  border: Border.all(
                    color: _selectedFile != null
                        ? const Color(0xFF309DAA)
                        : const Color(0xFFD0D5DD),
                    width: _selectedFile != null ? 1.5 : 1,
                    // Simulate dashed via a solid border when no file is picked
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F2F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.upload_rounded,
                        size: 22,
                        color: Color(0xFF667185),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedFile != null
                          ? _selectedFile!.path.split('/').last
                          : 'Tap to select an image',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF101928),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_selectedFile == null)
                      const Text(
                        'Images only. Max file size: 5MB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF667185),
                        ),
                      ),
                    if (_selectedFile != null)
                      TextButton(
                        onPressed: isLoading ? null : _pickImage,
                        child: const Text(
                          'Change file',
                          style: TextStyle(color: Color(0xFF276572)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Caption
            const Text(
              'Caption (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF344054),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _captionController,
              enabled: !isLoading,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Optional caption...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Set-as-primary checkbox — only shown if no primary exists
            if (canShowPrimaryToggle)
              GestureDetector(
                onTap: isLoading
                    ? null
                    : () => setState(() => _setAsPrimary = !_setAsPrimary),
                child: Row(
                  children: [
                    Checkbox(
                      value: _setAsPrimary,
                      onChanged: isLoading
                          ? null
                          : (v) => setState(() => _setAsPrimary = v ?? false),
                      activeColor: const Color(0xFF276572),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Text(
                      'Set as primary',
                      style: TextStyle(fontSize: 14, color: Color(0xFF475467)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFD0D5DD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF344054),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isFormValid ? _submit : null,
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.upload_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                    label: Text(
                      isLoading ? 'Uploading...' : 'Upload',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF276572),
                      disabledBackgroundColor: const Color(0xFFEAECF0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
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
