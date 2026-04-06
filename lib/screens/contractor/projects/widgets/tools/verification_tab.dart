import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/contractors/providers/contractor_providers.dart';

class VerificationTab extends ConsumerWidget {
  const VerificationTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verificationState = ref.watch(contractorVerificationProvider);
    final actionState = ref.watch(contractorProfileNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: verificationState.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(color: Color(0xFF276572)),
          ),
        ),
        error: (err, _) => _errorBox(
          context,
          message: 'Unable to load verification: $err',
          onRetry: () => ref.invalidate(contractorVerificationProvider),
        ),
        data: (verification) {
          final steps = verification.steps ?? const [];
          final documents = verification.documents ?? const [];
          final status = (verification.verificationStatus ?? 'pending')
              .toUpperCase();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionCard(
                title: 'Verification Tracker',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statusPill(status),
                    const SizedBox(height: 16),
                    if (steps.isEmpty)
                      const Text(
                        'No verification steps available yet.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      )
                    else
                      Column(
                        children: steps
                            .asMap()
                            .entries
                            .map(
                              (entry) => _buildTrackerItem(
                                title:
                                    entry.value['title']?.toString() ??
                                    entry.value['name']?.toString() ??
                                    'Step ${entry.key + 1}',
                                date:
                                    entry.value['completed_at']?.toString() ??
                                    entry.value['updated_at']?.toString() ??
                                    'Pending',
                                isLast: entry.key == steps.length - 1,
                                completed:
                                    (entry.value['status']?.toString() ?? '')
                                        .toLowerCase() ==
                                    'completed',
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Documents',
                child: Column(
                  children: [
                    if (documents.isEmpty)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No documents uploaded yet.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      )
                    else
                      ...documents.map(
                        (doc) => _buildDocumentRow(
                          context,
                          ref,
                          doc.id,
                          doc.name,
                          actionState.isLoading,
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: actionState.isLoading
                            ? null
                            : () => _pickAndUpload(context, ref),
                        icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                        label: actionState.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Upload PDF (max 5MB)'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F2F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _statusPill(String status) {
    final lower = status.toLowerCase();
    Color bg = const Color(0xFFFFF4E5);
    Color fg = const Color(0xFFB54708);
    if (lower == 'verified') {
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF0F973D);
    } else if (lower == 'under_review') {
      bg = const Color(0xFFE0F2FE);
      fg = const Color(0xFF276572);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

  Widget _buildTrackerItem({
    required String title,
    required String date,
    required bool isLast,
    bool completed = false,
  }) {
    final circleColor = completed
        ? const Color(0xFF276572)
        : const Color(0xFFE5E7EB);
    final inner = completed ? Colors.white : const Color(0xFFE5E7EB);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: circleColor, width: 1.5),
              ),
              child: Center(
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed ? circleColor : inner,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(width: 1.5, height: 40, color: const Color(0xFFE5E7EB)),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            if (!isLast) const SizedBox(height: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentRow(
    BuildContext context,
    WidgetRef ref,
    String documentId,
    String name,
    bool disabled,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Color(0xFF276572)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFB42318)),
            onPressed: disabled
                ? null
                : () async {
                    try {
                      await ref
                          .read(contractorProfileNotifierProvider.notifier)
                          .deleteDocument(documentId);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Delete failed: $e')),
                        );
                      }
                    }
                  },
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: false,
    );
    final file = result?.files.single;
    if (file == null) return;

    // Check for 5MB limit (5 * 1024 * 1024 bytes)
    if (file.size > 5242880) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File is too large. Maximum size is 5MB.'),
            backgroundColor: Color(0xFFB42318),
          ),
        );
      }
      return;
    }

    final path = file.path ?? '';

    try {
      await ref
          .read(contractorProfileNotifierProvider.notifier)
          .uploadDocument(path);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Document uploaded')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  Widget _errorBox(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2F0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFB42318)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB42318),
                  ),
                ),
              ),
              if (onRetry != null)
                TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ],
    );
  }
}
