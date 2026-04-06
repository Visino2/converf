import 'package:flutter/material.dart';

class ContractorPersonalInfoStep extends StatefulWidget {
  final VoidCallback onNext;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final String? selectedCountry;
  final Function(String) onCountrySelected;
  final String? emailBackendError;
  final VoidCallback onEmailChanged;
  final bool isCheckingEmail;

  const ContractorPersonalInfoStep({
    super.key,
    required this.onNext,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.selectedCountry,
    required this.onCountrySelected,
    required this.emailBackendError,
    required this.onEmailChanged,
    this.isCheckingEmail = false,
  });

  @override
  State<ContractorPersonalInfoStep> createState() =>
      _ContractorPersonalInfoStepState();
}

class _ContractorPersonalInfoStepState
    extends State<ContractorPersonalInfoStep> {
  final _formKey = GlobalKey<FormState>();

  bool _isEmailValid = false;
  final List<String> _countries = [
    'Nigeria',
  ];

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                  'Select your country',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: _countries.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    indent: 24,
                    endIndent: 24,
                    color: Color(0xFFF3F4F6),
                  ),
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    final isSelected = widget.selectedCountry == country;

                    return InkWell(
                      onTap: () {
                        widget.onCountrySelected(country);
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: Row(
                          children: [
                            if (isSelected) ...[
                              const Icon(
                                Icons.check,
                                color: Color(0xFF6B7280),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                            ] else ...[
                              const SizedBox(width: 32),
                            ],
                            Text(
                              country,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
    String? errorText,
    VoidCallback? onChanged,
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
          onChanged: (v) => onChanged?.call(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            errorText: errorText,
            suffixIcon: (isValid && errorText == null)
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
        key: const ValueKey('personal_info'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get started with Converf',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Build world-class infrastructure across Africa',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'First Name',
                  'First Name',
                  controller: widget.firstNameController,
                  validator: (v) {
                    if (v == null || v.length < 2) return 'Enter first name';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Last Name',
                  'Last Name',
                  controller: widget.lastNameController,
                  validator: (v) {
                    if (v == null || v.length < 2) return 'Enter last name';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Email Address',
            'you@example.com',
            controller: widget.emailController,
            isValid: _isEmailValid,
            errorText: widget.emailBackendError,
            onChanged: widget.onEmailChanged,
            validator: (v) {
              if (v == null || !v.contains('@') || !v.contains('.')) return 'Enter valid email';
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_isEmailValid) setState(() => _isEmailValid = true);
              });
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Country'),
          FormField<String>(
            validator: (v) => widget.selectedCountry == null ? 'Select country' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _showCountryPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: state.hasError ? Colors.red : Colors.grey.shade300,
                          width: state.hasError ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            widget.selectedCountry ?? 'Select Country',
                            style: TextStyle(
                              color: widget.selectedCountry == null
                                  ? Colors.grey.shade400
                                  : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 12),
                      child: Text(
                        state.errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              );
            },
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
              onPressed: widget.isCheckingEmail
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        widget.onNext();
                      }
                    },
              child: widget.isCheckingEmail
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
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
