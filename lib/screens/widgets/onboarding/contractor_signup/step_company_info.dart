import 'package:flutter/material.dart';

class ContractorCompanyInfoStep extends StatefulWidget {
  final VoidCallback onNext;
  final TextEditingController companyNameController;
  final TextEditingController registrationNumberController;
  final TextEditingController licenseNumberController;
  final String? yearsInBusiness;
  final Function(String) onYearsSelected;

  const ContractorCompanyInfoStep({
    super.key,
    required this.onNext,
    required this.companyNameController,
    required this.registrationNumberController,
    required this.licenseNumberController,
    required this.yearsInBusiness,
    required this.onYearsSelected,
  });

  @override
  State<ContractorCompanyInfoStep> createState() =>
      _ContractorCompanyInfoStepState();
}

class _ContractorCompanyInfoStepState extends State<ContractorCompanyInfoStep> {
  final _formKey = GlobalKey<FormState>();

 // Actually removing them check by check.
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
                      widget.onYearsSelected(option);
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
    required TextEditingController controller,
    Widget? trailing,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    bool isValid = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            suffixIcon: isValid 
                ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                : trailing,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
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
          _buildTextField(
            'Company Name *',
            'e.g ABC Construction',
            controller: widget.companyNameController,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter company name';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Business Registration Number *',
            'e.g RC 11118338',
            controller: widget.registrationNumberController,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter registration number';
              return null;
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Your CAC registration number or equivalent',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Years in Business *'),
                    FormField<String>(
                      validator: (v) =>
                          widget.yearsInBusiness == null ? 'Required' : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      builder: (state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: _showYearsPicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: state.hasError
                                        ? Colors.red
                                        : Colors.grey.shade300,
                                    width: state.hasError ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      widget.yearsInBusiness ?? 'Select',
                                      style: TextStyle(
                                        color: widget.yearsInBusiness == null
                                            ? Colors.grey.shade400
                                            : Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.keyboard_arrow_down,
                                        color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                            if (state.hasError)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, left: 12),
                                child: Text(
                                  state.errorText!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'License Number',
                  'Enter license',
                  controller: widget.licenseNumberController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter license number';
                    if (v.length < 3) return 'Invalid license';
                    return null;
                  },
                ),
              ),
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
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onNext();
                }
              },
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
