import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../features/contractors/providers/contractor_providers.dart';
import '../../../../../features/contractors/models/contractor_models.dart';

class CertificationTab extends ConsumerStatefulWidget {
  const CertificationTab({super.key});

  @override
  ConsumerState<CertificationTab> createState() => _CertificationTabState();
}

class _CertificationTabState extends ConsumerState<CertificationTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _issuerController = TextEditingController();
  final _issuedAtController = TextEditingController();
  final _expiresAtController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _issuedAtController.dispose();
    _expiresAtController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF276572),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showAddCertificationDialog() {
    _nameController.clear();
    _issuerController.clear();
    _issuedAtController.clear();
    _expiresAtController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Certification',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 24),
              _buildDialogField(
                label: 'Certification Name',
                controller: _nameController,
                hint: 'e.g. Registered Civil Engineer',
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildDialogField(
                label: 'Issuing Body',
                controller: _issuerController,
                hint: 'e.g. COREN',
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDialogField(
                      label: 'Issued At',
                      controller: _issuedAtController,
                      hint: 'YYYY-MM-DD',
                      readOnly: true,
                      onTap: () => _selectDate(context, _issuedAtController),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDialogField(
                      label: 'Expires At (Optional)',
                      controller: _expiresAtController,
                      hint: 'YYYY-MM-DD',
                      readOnly: true,
                      onTap: () => _selectDate(context, _expiresAtController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF276572),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Save Certification',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      'name': _nameController.text.trim(),
      'issuing_body': _issuerController.text.trim(),
      'issued_at': _issuedAtController.text.trim(),
      if (_expiresAtController.text.isNotEmpty)
        'expires_at': _expiresAtController.text.trim(),
    };

    final success = await ref
        .read(contractorProfileNotifierProvider.notifier)
        .addCertification(payload);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Certification added successfully'
                : 'Failed to add certification',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(contractorProfileProvider);
    final actionState = ref.watch(contractorProfileNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: profileState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF276572)),
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (response) {
          final certifications = response.data.certifications ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (certifications.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No certifications added yet.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                )
              else
                ...certifications.map(
                  (cert) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildCertificationCard(
                      cert: cert,
                      onDelete: actionState.isLoading
                          ? null
                          : () => _deleteCert(cert.id),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: actionState.isLoading
                      ? null
                      : _showAddCertificationDialog,
                  icon: actionState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Certification',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF276572),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteCert(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certification'),
        content: const Text(
          'Are you sure you want to delete this certification?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(contractorProfileNotifierProvider.notifier)
          .deleteCertification(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Certification deleted'
                  : 'Failed to delete certification',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCertificationCard({
    required ContractorCertification cert,
    VoidCallback? onDelete,
  }) {
    final expiryDate = cert.expiresAt;
    final isExpiring = expiryDate != null;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isExpiring
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/images/Diploma.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isExpiring
                        ? const Color(0xFFD97706)
                        : const Color(0xFF059669),
                    BlendMode.srcIn,
                  ),
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.card_membership,
                    color: isExpiring
                        ? const Color(0xFFD97706)
                        : const Color(0xFF059669),
                  ),
                ),
              ),
              const Spacer(),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            cert.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cert.issuingBody,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF3F4F6)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateItem(
                'Issued',
                cert.issuedAt,
                'assets/images/Calendar.svg',
                Icons.calendar_today,
              ),
              if (expiryDate != null)
                _buildDateItem(
                  'Expiry',
                  expiryDate,
                  'assets/images/shield-warning.svg',
                  Icons.warning_amber,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(
    String label,
    String date,
    String iconPath,
    IconData fallbackIcon,
  ) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 14,
          height: 14,
          colorFilter: const ColorFilter.mode(
            Color(0xFF9CA3AF),
            BlendMode.srcIn,
          ),
          errorBuilder: (context, error, stackTrace) =>
              Icon(fallbackIcon, size: 14, color: const Color(0xFF9CA3AF)),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 2),
            Text(
              date,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDialogField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF276572),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
