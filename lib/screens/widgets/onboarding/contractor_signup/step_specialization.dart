import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ContractorSpecializationStep extends StatefulWidget {
  final Future<void> Function() onSignupSubmit;
  final TextEditingController addressController;
  final TextEditingController tinController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Map<String, bool> specializations;
  final Function(String, bool) onSpecializationChanged;
  final bool termsAgreed;
  final Function(bool) onTermsChanged;
  final bool infoAccurate;
  final Function(bool) onInfoAccurateChanged;
  final bool isLoading;

  const ContractorSpecializationStep({
    super.key,
    required this.onSignupSubmit,
    required this.addressController,
    required this.tinController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.specializations,
    required this.onSpecializationChanged,
    required this.termsAgreed,
    required this.onTermsChanged,
    required this.infoAccurate,
    required this.onInfoAccurateChanged,
    this.isLoading = false,
  });

  @override
  State<ContractorSpecializationStep> createState() =>
      _ContractorSpecializationStepState();
}

class _ContractorSpecializationStepState
    extends State<ContractorSpecializationStep> {
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _showTermsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Terms of Service',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Text(
                'By using Converf, you agree to our Terms of Service. '
                'You are responsible for maintaining the confidentiality of your account '
                'and for all activities that occur under your account. '
                'Converf reserves the right to modify these terms at any time.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Converf is committed to protecting your privacy. '
                'We collect information you provide directly to us and use it to '
                'operate, maintain, and improve our services. '
                'We do not sell your personal information to third parties.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.5),
              ),
            ),
          ),
        ],
      ),
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
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    bool isValid = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isValid)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ),
                if (isPassword)
                  IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  ),
              ],
            ),
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
    return FormField<Map<String, bool>>(
      initialValue: widget.specializations,
      validator: (val) {
        if (val == null || !val.values.any((isSelected) => isSelected)) {
          return 'Please select at least one specialization';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
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
                    widget.specializations['residential'] ?? false,
                    (v) {
                      widget.onSpecializationChanged('residential', v ?? false);
                      state.didChange(widget.specializations);
                    },
                  ),
                ),
                Expanded(
                  child: _buildCheckbox(
                    'Infrastructure',
                    widget.specializations['infrastructure'] ?? false,
                    (v) {
                      widget.onSpecializationChanged('infrastructure', v ?? false);
                      state.didChange(widget.specializations);
                    },
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
                    widget.specializations['commercial'] ?? false,
                    (v) {
                      widget.onSpecializationChanged('commercial', v ?? false);
                      state.didChange(widget.specializations);
                    },
                  ),
                ),
                Expanded(
                  child: _buildCheckbox(
                    'Industrial',
                    widget.specializations['industrial'] ?? false,
                    (v) {
                      widget.onSpecializationChanged('industrial', v ?? false);
                      state.didChange(widget.specializations);
                    },
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
                    widget.specializations['roadway'] ?? false,
                    (v) {
                      widget.onSpecializationChanged('roadway', v ?? false);
                      state.didChange(widget.specializations);
                    },
                  ),
                ),
                Expanded(
                  child: _buildCheckbox(
                    'Renovation',
                    widget.specializations['renovation'] ?? false,
                    (v) {
                      widget.onSpecializationChanged('renovation', v ?? false);
                      state.didChange(widget.specializations);
                    },
                  ),
                ),
              ],
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Select all that apply',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        );
      },
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
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    color: Color(0xFF276572),
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _showTermsModal,
                ),
                const TextSpan(text: ', including the '),
                TextSpan(
                  text: 'Privacy Policy.',
                  style: const TextStyle(
                    color: Color(0xFF276572),
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _showPrivacyModal,
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
    return Form(
      key: _formKey,
      child: Column(
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
          _buildTextField(
            'Business Address *',
            'Enter your business Address',
            controller: widget.addressController,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter address';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Tax Identification Number (TIN)',
            'Enter your TIN',
            controller: widget.tinController,
            validator: (v) {
              return null;
            },
          ),
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
                const Text(
                  'Additional verification required',
                  style: TextStyle(
                    color: Color(0xFF166534), // green-800
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
            controller: widget.passwordController,
            isPassword: true,
            obscureText: _obscurePassword,
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
            isValid: _isPasswordValid,
            validator: (v) {
              if (v == null || v.length < 8) return 'Min 8 characters';
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_isPasswordValid) setState(() => _isPasswordValid = true);
              });
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Confirm Password',
            'Confirm Password',
            controller: widget.confirmPasswordController,
            isPassword: true,
            obscureText: _obscureConfirmPassword,
            onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            isValid: _isConfirmPasswordValid,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirm password';
              if (v != widget.passwordController.text) return 'Passwords do not match';
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_isConfirmPasswordValid) setState(() => _isConfirmPasswordValid = true);
              });
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildTermsRichCheckbox(
            widget.termsAgreed,
            (v) => widget.onTermsChanged(v ?? false),
          ),
          const SizedBox(height: 16),
          _buildTermsCheckbox(
            'I confirm that all company information provided is accurate and I will submit verification documents (company registration certificate, valid ID, tax documents, and proof of past projects) within 7 days to complete my profile verification.',
            widget.infoAccurate,
            (v) => widget.onInfoAccurateChanged(v ?? false),
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
              onPressed: widget.isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        if (!widget.termsAgreed || !widget.infoAccurate) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please agree to terms and confirm accuracy')),
                          );
                          return;
                        }
                        widget.onSignupSubmit();
                      }
                    },
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Create my account',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
