import 'package:flutter/material.dart';

class ContractorSpecializationStep extends StatefulWidget {
  final VoidCallback onSignupSubmit;

  const ContractorSpecializationStep({super.key, required this.onSignupSubmit});

  @override
  State<ContractorSpecializationStep> createState() =>
      _ContractorSpecializationStepState();
}

class _ContractorSpecializationStepState
    extends State<ContractorSpecializationStep> {
  bool _specResidential = true;
  bool _specCommercial = false;
  bool _specRoadway = false;
  bool _specInfrastructure = false;
  bool _specIndustrial = false;
  bool _specRenovation = false;

  bool _termsAgreed = false;
  bool _infoAccurate = false;

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
    bool isPassword = false,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        TextFormField(
          obscureText: isPassword,
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

  Widget _buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF276572),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(color: Colors.grey.shade400, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecializationGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Construction Specialization *'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildCheckbox(
                'Residential',
                _specResidential,
                (v) => setState(() => _specResidential = v ?? false),
              ),
            ),
            Expanded(
              child: _buildCheckbox(
                'Infrastructure',
                _specInfrastructure,
                (v) => setState(() => _specInfrastructure = v ?? false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCheckbox(
                'Commercial',
                _specCommercial,
                (v) => setState(() => _specCommercial = v ?? false),
              ),
            ),
            Expanded(
              child: _buildCheckbox(
                'Industrial',
                _specIndustrial,
                (v) => setState(() => _specIndustrial = v ?? false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCheckbox(
                'Roadway',
                _specRoadway,
                (v) => setState(() => _specRoadway = v ?? false),
              ),
            ),
            Expanded(
              child: _buildCheckbox(
                'Renovation',
                _specRenovation,
                (v) => setState(() => _specRenovation = v ?? false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select all that apply',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(
    String text,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF276572),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(color: Colors.grey.shade400, width: 1.5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsRichCheckbox(bool value, ValueChanged<bool?> onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF276572),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(color: Colors.grey.shade400, width: 1.5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              children: [
                const TextSpan(
                  text: 'Yes, I understand and agree to the Converf ',
                ),
                const TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: Color(0xFF276572),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(text: ', including the '),
                const TextSpan(
                  text: 'Privacy Policy.',
                  style: TextStyle(
                    color: Color(0xFF276572),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('specialization'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specialization & Security',
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
          'Complete your profile',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        _buildSpecializationGrid(),
        const SizedBox(height: 16),
        _buildTextField('Business Address *', 'Enter your business Address'),
        const SizedBox(height: 16),
        _buildTextField('Tax Identification Number (TIN)', 'Enter your TIN'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 16),
              const SizedBox(width: 6),
              Text(
                'Additional verification required',
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Password',
          'Password',
          isPassword: true,
          trailing: const Icon(
            Icons.visibility_off_outlined,
            color: Colors.grey,
            size: 20,
          ),
        ),
        const SizedBox(height: 24),
        _buildTermsRichCheckbox(
          _termsAgreed,
          (v) => setState(() => _termsAgreed = v ?? false),
        ),
        const SizedBox(height: 16),
        _buildTermsCheckbox(
          'I confirm that all company information provided is accurate and I will submit verification documents (company registration certificate, valid ID, tax documents, and proof of past projects) within 7 days to complete my profile verification.',
          _infoAccurate,
          (v) => setState(() => _infoAccurate = v ?? false),
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
            onPressed: widget.onSignupSubmit,
            child: const Text(
              'Create my account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
