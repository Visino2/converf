import 'package:flutter/material.dart';

class ContractorCompanyInfoStep extends StatefulWidget {
  final VoidCallback onNext;

  const ContractorCompanyInfoStep({super.key, required this.onNext});

  @override
  State<ContractorCompanyInfoStep> createState() =>
      _ContractorCompanyInfoStepState();
}

class _ContractorCompanyInfoStepState extends State<ContractorCompanyInfoStep> {
  String? _yearsInBusiness;

  void _showYearsPicker() {
    final yearsOptions = ['1-2 Years', '3-5 Years', '5-10 Years', '10+ Years'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      'Select years in business',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              ListView.separated(
                shrinkWrap: true,
                itemCount: yearsOptions.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 24, endIndent: 24),
                itemBuilder: (context, index) {
                  final option = yearsOptions[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    title: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      setState(() => _yearsInBusiness = option);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    Widget? trailing,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        TextFormField(
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            suffixIcon: trailing,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF276572)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('company_info'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company Information',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Help us verify your construction business',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        _buildTextField('Company Name *', 'e.g ABC Construction'),
        const SizedBox(height: 16),
        _buildTextField('Business Registration Number *', 'e.g RC 11118338'),
        const SizedBox(height: 4),
        Text(
          'Your CAC registration number or equivalent',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'Years in Business *',
                _yearsInBusiness ?? 'Select',
                readOnly: true,
                onTap: _showYearsPicker,
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('License Number', 'Enter license')),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276572),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            onPressed: widget.onNext,
            child: const Text(
              'Next',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
