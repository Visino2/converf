import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/auth/providers/auth_provider.dart';
import '../../../../../features/auth/repositories/auth_repository.dart';
import '../../../../../features/auth/services/biometric_auth_service.dart';
import '../../../../../features/profile/models/profile_models.dart';
import '../../../../../features/profile/providers/profile_providers.dart';
import 'package:local_auth/local_auth.dart';

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
  bool _hasPassword = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadBiometricState);
    _loadHasPassword();
  }

  void _loadHasPassword() {
    final user = ref.read(authProvider).value?.data?.user;
    final hasPassword = user?['has_password'] as bool? ?? true;
    setState(() => _hasPassword = hasPassword);
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
    try {
      final biometricService = ref.read(biometricAuthServiceProvider);
      final availability =
          _biometricAvailability ?? await biometricService.getAvailability();

      if (enabled && !availability.canAuthenticate) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(availability.helperText)));
        return;
      }

      setState(() => _biometricBusy = true);

      if (enabled) {
        // Verify biometrics locally first.
        final didAuth = await biometricService.authenticate(
          reason:
              'Use ${availability.preferredLabel} to enable biometric login for Converf.',
        );
        if (!mounted) return;
        if (!didAuth) {
          setState(() => _biometricBusy = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric setup was cancelled. Nothing changed.'),
            ),
          );
          return;
        }

        // Register with the backend to get a long-lived biometric token.
        final repository = ref.read(authRepositoryProvider);
        final deviceToken = await repository.registerBiometric();
        await biometricService.saveDeviceToken(deviceToken);
        await biometricService.setEnabled(true);
      } else {
        // Revoke backend token and clear locally.
        try {
          final repository = ref.read(authRepositoryProvider);
          await repository.revokeBiometric();
        } catch (e) {
          debugPrint('[BiometricAuth] Backend revoke failed (non-fatal): $e');
        }
        await biometricService.disable();
      }

      if (!mounted) return;
      setState(() {
        _biometricEnabled = enabled;
        _biometricBusy = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Biometric login is now active on this device.'
                : 'Biometric login has been turned off.',
          ),
        ),
      );
    } catch (e) {
      debugPrint('[BiometricAuth] Toggle failed: $e');
      if (!mounted) return;
      setState(() {
        _biometricBusy = false;
        _biometricEnabled = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Biometric authentication is not available on this device.',
          ),
        ),
      );
    }
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _formError = null);

    try {
      if (_hasPassword) {
        final current = _currentPasswordController.text.trim();
        final newPassword = _newPasswordController.text.trim();
        final confirm = _confirmPasswordController.text.trim();
        final payload = ChangePasswordPayload(
          currentPassword: current,
          password: newPassword,
          passwordConfirmation: confirm,
        );
        await ref.read(profileNotifierProvider.notifier).changePassword(payload);
      } else {
        await ref.read(authRepositoryProvider).setPassword(
          password: _newPasswordController.text.trim(),
          passwordConfirmation: _confirmPasswordController.text.trim(),
        );
        // Update local auth state so the form switches to Change Password.
        await ref.read(authProvider.notifier).updateCurrentUser({'has_password': true});
        if (mounted) setState(() => _hasPassword = true);
      }
      if (mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_hasPassword ? 'Password changed successfully' : 'Password set successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _formError = e.toString());
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
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                  border: Border.all(
                    color: (_biometricAvailability?.canAuthenticate ?? false)
                        ? const Color(0xFFB7E7EA)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _biometricEnabled
                                ? const Color(0xFF276572)
                                : const Color(0xFFE6F4F1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _biometricAvailability?.availableBiometrics
                                        .contains(BiometricType.face) ==
                                    true
                                ? Icons.face_outlined
                                : Icons.fingerprint,
                            color: _biometricEnabled
                                ? Colors.white
                                : const Color(0xFF276572),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Biometric Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  if (!_biometricLoading &&
                                      !(_biometricAvailability
                                              ?.canAuthenticate ??
                                          false)) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF2F4F7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Not available',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF667085),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _biometricLoading
                                    ? 'Checking device security options...'
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
                        const SizedBox(width: 8),
                        if (_biometricLoading)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF276572),
                            ),
                          )
                        else
                          Switch.adaptive(
                            value: _biometricEnabled,
                            onChanged:
                                (_biometricBusy ||
                                    !(_biometricAvailability?.canAuthenticate ??
                                        false))
                                ? null
                                : _toggleBiometricLogin,
                            activeThumbColor: Colors.white,
                            activeTrackColor: const Color(0xFF276572),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFFD0D5DD),
                          ),
                      ],
                    ),
                    if (_biometricBusy) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          minHeight: 3,
                          color: Color(0xFF276572),
                          backgroundColor: Color(0xFFE5E7EB),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Verifying biometrics...',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF276572),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Text(
                _hasPassword ? 'Change Password' : 'Set Password',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              if (!_hasPassword) ...[
                const SizedBox(height: 6),
                const Text(
                  'Add a password so you can log in with email.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ],
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

              if (_hasPassword) ...[
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
              ],

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
