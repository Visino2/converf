import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/core/ui/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../features/auth/models/auth_response.dart';
import '../../../features/auth/models/social_auth_method.dart';
import '../../../features/auth/providers/social_auth_provider.dart';

class OnboardingAuthStep extends ConsumerWidget {
  const OnboardingAuthStep({
    super.key,
    required this.onSignupManually,
    required this.onLogin,
    this.selectedRole,
  });

  final VoidCallback onSignupManually;
  final VoidCallback onLogin;
  final String? selectedRole;

  Widget _buildSocialButton({
    required String title,
    required Widget iconWidget,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Opacity(
        opacity: onTap == null ? 0.6 : 1,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<UserRole?> _resolveRole(BuildContext context) async {
    final initialRole = userRoleFromOnboardingSelection(selectedRole);
    if (initialRole != null) {
      return initialRole;
    }

    return showModalBottomSheet<UserRole>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Continue as',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose the account type you want to use for this sign-in.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
                ),
                const SizedBox(height: 20),
                _RoleOptionTile(
                  title: 'Project Owner',
                  onTap: () => Navigator.of(context).pop(UserRole.projectOwner),
                ),
                const SizedBox(height: 12),
                _RoleOptionTile(
                  title: 'Contractor',
                  onTap: () => Navigator.of(context).pop(UserRole.contractor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSocialAuth(
    BuildContext context,
    WidgetRef ref,
    SocialAuthMethod method,
  ) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final role = await _resolveRole(context);
    if (role == null || !navigator.mounted) {
      return;
    }

    // Small delay to allow bottom sheet animation to finish before native SDK takes over.
    // This prevents the 'hang' issue on some Android devices.
    await Future.delayed(const Duration(milliseconds: 150));
    if (!navigator.mounted) return;

    try {
      if (method == SocialAuthMethod.google) {
        debugPrint(
          '[OnboardingAuthStep] Starting native Google Sign-In for role=${role.name} on ${defaultTargetPlatform.name}.',
        );
        final response = await ref
            .read(socialAuthActionProvider.notifier)
            .signInWithGoogleNative(role: role);

        if (response == null) {
          return;
        }
      } else {
        final authUrl = await ref
            .read(socialAuthActionProvider.notifier)
            .getSignInUrl(method: method, role: role);

        if (!navigator.mounted) return;

        final uri = Uri.parse(authUrl);
        debugPrint(
          '[OnboardingAuthStep] Launching external ${method.name} auth URL: $uri',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Could not launch the browser for signing in.');
        }
      }
    } on PlatformException catch (e) {
      if (!navigator.mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Google Sign-In failed (${e.code}). Please try again or contact support if this persists.',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!navigator.mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socialAuthState = ref.watch(socialAuthActionProvider);

    return Container(
      key: const ValueKey('auth'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.45],
          colors: [AppColors.authShellTop, Colors.white],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: onLogin,
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Get started with\nConverf',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -1.0,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Build world-class infrastructure across Africa',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildSocialButton(
                          title: 'Continue with Google',
                          iconWidget: Image.asset(
                            'assets/images/Google Icon.png',
                            width: 24,
                            height: 24,
                          ),
                          onTap: socialAuthState.isLoading
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  _handleSocialAuth(
                                    context,
                                    ref,
                                    SocialAuthMethod.google,
                                  );
                                },
                        ),
                        const SizedBox(height: 16),
                        _buildSocialButton(
                          title: 'Continue with Apple',
                          iconWidget: const Icon(
                            Icons.apple,
                            size: 28,
                            color: Colors.black,
                          ),
                          onTap: socialAuthState.isLoading
                              ? null
                              : () => _handleSocialAuth(
                                  context,
                                  ref,
                                  SocialAuthMethod.apple,
                                ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
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
                            onPressed: onSignupManually,
                            child: const Text(
                              'Signup Manually',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoleOptionTile extends StatelessWidget {
  const _RoleOptionTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF667085),
            ),
          ],
        ),
      ),
    );
  }
}
