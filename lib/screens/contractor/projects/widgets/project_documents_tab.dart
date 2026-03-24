import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../features/projects/providers/project_document_providers.dart';
import '../../../../features/projects/models/project_document.dart';

class ProjectDocumentsTab extends ConsumerStatefulWidget {
  final String projectId;
  final bool isEmbedded;

  const ProjectDocumentsTab({
    super.key,
    required this.projectId,
    this.isEmbedded = false,
  });

  @override
  ConsumerState<ProjectDocumentsTab> createState() => _ProjectDocumentsTabState();
}

class _ProjectDocumentsTabState extends ConsumerState<ProjectDocumentsTab> {
  Future<void> _uploadDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        await ref.read(projectDocumentNotifierProvider.notifier).uploadDocument(
          projectId: widget.projectId,
          filePath: file.path!,
          name: file.name,
          type: file.extension ?? 'unknown',
        );
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document uploaded successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading document: $e')),
        );
      }
    }
  }

  Future<void> _deleteDocument(String documentId) async {
    try {
      await ref.read(projectDocumentNotifierProvider.notifier).deleteDocument(
        widget.projectId,
        documentId,
      );
       if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document deleted successfully')),
          );
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting document: $e')),
        );
      }
    }
  }

  Future<void> _downloadAndOpen(ProjectDocument doc) async {
    try {
        final directory = await getApplicationDocumentsDirectory();
        if (!mounted) return;
        final savePath = '${directory.path}/${doc.name}';
        
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Downloading document...')),
         );

       await ref.read(projectDocumentNotifierProvider.notifier).downloadDocument(
          widget.projectId,
          doc.id,
          savePath,
        );

        await OpenFilex.open(savePath);
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading document: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(projectDocumentsProvider(widget.projectId));
    final isActionLoading = ref.watch(projectDocumentNotifierProvider).isLoading;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.isEmbedded)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/images/document-1.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
                  const SizedBox(width: 12),
                  const Text('Documents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFFF2F4F7), shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 16, color: Color(0xFF667085)),
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
        const Text('Project Documents', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
        const SizedBox(height: 8),
        documentsAsync.when(
          data: (docs) => Text('${docs.length} files stored securely', style: const TextStyle(fontSize: 16, color: Color(0xFF667085))),
          loading: () => const Text('Loading documents...', style: TextStyle(fontSize: 16, color: Color(0xFF667085))),
          error: (e, _) => const Text('Error loading documents', style: TextStyle(fontSize: 16, color: Colors.red)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isActionLoading ? null : _uploadDocument,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276572),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: isActionLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/images/upload-1.svg', width: 20, height: 20, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                      const SizedBox(width: 8),
                      const Text('Upload Document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 32),
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: const Color(0xFFF9FAFB),
          child: const Row(
            children: [
              Expanded(child: Text('Document Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467)))),
              Text('Size', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467))),
              SizedBox(width: 40),
            ],
          ),
        ),
        Expanded(
          child: documentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (docs) {
              if (docs.isEmpty) {
                return const Center(child: Text('No documents found.'));
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFEAECF0))),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _downloadAndOpen(doc),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: SvgPicture.asset('assets/images/document.svg', width: 20, height: 20, colorFilter: const ColorFilter.mode(Color(0xFF039855), BlendMode.srcIn)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _downloadAndOpen(doc),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doc.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF101828)), overflow: TextOverflow.ellipsis),
                                Text(doc.type, style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
                              ],
                            ),
                          ),
                        ),
                        Text(doc.formattedSize, style: const TextStyle(fontSize: 14, color: Color(0xFF475467))),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteDocument(doc.id);
                            } else if (value == 'download') {
                              _downloadAndOpen(doc);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'download', child: Text('Download')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                          icon: const Icon(Icons.more_vert, color: Color(0xFF667085)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );

    if (widget.isEmbedded) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: content,
      );
    }

    return SafeArea(
      bottom: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: content,
      ),
    );
  }
}
