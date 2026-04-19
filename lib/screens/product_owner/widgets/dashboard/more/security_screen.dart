import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/profile/models/profile_models.dart';
import '../../../../../features/profile/providers/profile_providers.dart';
import '../../../../../features/auth/services/biometric_auth_service.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  String? _formError;
  bool _biometricEnabled = false;
  bool _biometricLoading = true;
  bool _biometricBusy = false;
  BiometricAvailability? _biometricAvailability;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadBiometricState);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadBiometricState() async {
    final biometricService = ref.read(biometricAuthServiceProvider);
    final availability = await biometricService.getAvailability();
    if (!mounted) {
      return;
    }

    setState(() {
      _biometricAvailability = availability;
      _biometricEnabled = biometricService.isEnabledSync;
      _biometricLoading = false;
    });
  }

  Future<void> _toggleBiometricLogin(bool enabled) async {
    final biometricService = ref.read(biometricAuthServiceProvider);
    final availability =
        _biometricAvailability ?? await biometricService.getAvailability();

    if (enabled && !availability.canAuthenticate) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(availability.helperText)));
      return;
    }

    setState(() => _biometricBusy = true);

    bool didEnable = enabled;
    if (enabled) {
      didEnable = await biometricService.authenticate(
        reason:
            'Use ${availability.preferredLabel} to enable biometric login for Converf.',
      );
    }

    if (!mounted) {
      return;
    }

    if (enabled && !didEnable) {
      setState(() => _biometricBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric setup was cancelled. Nothing changed.'),
        ),
      );
      return;
    }

    await biometricService.setEnabled(enabled);
    setState(() {
      _biometricEnabled = enabled;
      _biometricBusy = false;
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? 'Biometric login is now active on this device.'
              : 'Biometric login has been turned off.',
        ),
      ),
    );
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState?.validate() != true) return;
    final current = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (newPassword != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    final payload = ChangePasswordPayload(
      currentPassword: current,
      password: newPassword,
      passwordConfirmation: confirm,
    );

    setState(() => _formError = null);
    try {
      await ref.read(profileNotifierProvider.notifier).changePassword(payload);
      if (mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _formError = e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change password: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Security',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Security & Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Strengthen your account security with professional controls',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 28),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6F4F1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fingerprint,
                            color: Color(0xFF276572),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Biometric Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _biometricLoading
                                    ? 'Checking your device security options...'
                                    : (_biometricAvailability?.helperText ??
                                          'Use biometrics to unlock your app after inactivity.'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Color(0xFF667085),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _biometricEnabled,
                          onChanged: (_biometricLoading || _biometricBusy)
                              ? null
                              : _toggleBiometricLogin,
                          activeThumbColor: const Color(0xFF276572),
                          activeTrackColor: const Color(0xFFB7E7EA),
                        ),
                      ],
                    ),
                    if (_biometricBusy) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(
                        minHeight: 3,
                        color: Color(0xFF276572),
                        backgroundColor: Color(0xFFE5E7EB),
                      ),
                    ],
                  ],
                ),
              ),

              const Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),

              if (_formError != null || actionState.hasError) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Text(
                    _formError ?? actionState.error.toString(),
                    style: const TextStyle(
                      color: Color(0xFFB42318),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],

              _buildPasswordField(
                'Current Password',
                _currentPasswordController,
                _showCurrent,
                () => setState(() => _showCurrent = !_showCurrent),
                enabled: !actionState.isLoading,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter current password' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildPasswordField(
                      'New Password',
                      _newPasswordController,
                      _showNew,
                      () => setState(() => _showNew = !_showNew),
                      enabled: !actionState.isLoading,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter new password';
                        if (v.length < 8) return 'Use at least 8 characters';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPasswordField(
                      'Confirm New Password',
                      _confirmPasswordController,
                      _showConfirm,
                      () => setState(() => _showConfirm = !_showConfirm),
                      enabled: !actionState.isLoading,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Re-enter new password';
                        }
                        if (v != _newPasswordController.text.trim()) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: actionState.isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A8090),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: actionState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isVisible,
    VoidCallback onToggle, {
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          enabled: enabled,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: onToggle,
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
              borderSide: const BorderSide(color: Color(0xFF2A8090)),
            ),
          ),
        ),
      ],
    );
  }
}
