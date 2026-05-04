import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/models/auth_response.dart';
import '../../features/auth/services/biometric_auth_service.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../ui/app_navigation.dart';
import '../ui/app_scaffold_messenger.dart';
import 'session_manager.dart';

class SessionTimeoutWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final Duration timeoutDuration;

  const SessionTimeoutWrapper({
    super.key,
    required this.child,
    this.timeoutDuration = const Duration(minutes: 15),
  });

  @override
  ConsumerState<SessionTimeoutWrapper> createState() =>
      _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends ConsumerState<SessionTimeoutWrapper>
    with WidgetsBindingObserver {
  late final ProviderSubscription<dynamic> _authSubscription;
  Timer? _timer;
  DateTime? _lastActivityAt;
  bool _isAuthenticated = false;
  bool _isLocked = false;
  bool _isUnlocking = false;
  bool _hadPersistedSessionOnLaunch = false;
  bool _launchProtectionHandled = false;
  String? _lockMessage;

  @override
  void initState() {
    super.initState();
    final sessionManager = ref.read(sessionManagerProvider);
    _hadPersistedSessionOnLaunch = sessionManager.hasSessionSync();
    WidgetsBinding.instance.addObserver(this);
    _authSubscription = ref.listenManual<AsyncValue<AuthResponse?>>(
      authProvider,
      (_, next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          unawaited(_handleAuthStateChanged(next.valueOrNull));
        });
      },
      fireImmediately: true,
    );
  }

  void _startTimer([Duration? remaining]) {
    if (!_isAuthenticated || _isLocked) {
      _timer?.cancel();
      return;
    }

    _timer?.cancel();
    final delay = remaining ?? widget.timeoutDuration;
    if (delay <= Duration.zero) {
      unawaited(_handleTimeout());
      return;
    }
    _timer = Timer(delay, () {
      unawaited(_handleTimeout());
    });
  }

  void _resetTimer([_]) {
    if (!_isAuthenticated || _isLocked) {
      return;
    }
    _recordActivity();
  }

  void _recordActivity() {
    _lastActivityAt = DateTime.now();
    _startTimer();
  }

  Future<void> _handleTimeout() async {
    final authState = ref.read(authProvider).value;
    if (authState == null || !authState.isAuthenticated) {
      _timer?.cancel();
      return;
    }

    final biometricService = ref.read(biometricAuthServiceProvider);
    final shouldUseBiometricLock = await biometricService.canProtectSession();
    if (shouldUseBiometricLock) {
      await _lockSession(
        reason:
            'Session locked after 15 minutes of inactivity. Use biometrics to continue.',
      );
      return;
    }

    await _logoutForTimeout();
  }

  Future<void> _logoutForTimeout() async {
    if (!_isAuthenticated) {
      return;
    }

    debugPrint('[AUTH] Session inactivity timeout reached. Logging out...');
    await ref.read(authProvider.notifier).logout();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expired due to inactivity.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> _handleAuthStateChanged(AuthResponse? authState) async {
    final isAuthenticated = authState?.isAuthenticated ?? false;
    if (_isAuthenticated == isAuthenticated) {
      return;
    }

    _isAuthenticated = isAuthenticated;
    if (!_isAuthenticated) {
      _timer?.cancel();
      _lastActivityAt = null;
      if (_isLocked) {
        setState(() {
          _isLocked = false;
          _isUnlocking = false;
          _lockMessage = null;
        });
      }
      return;
    }

    _recordActivity();
    if (_hadPersistedSessionOnLaunch && !_launchProtectionHandled) {
      _launchProtectionHandled = true;
      final biometricService = ref.read(biometricAuthServiceProvider);
      final shouldProtectSession = await biometricService.canProtectSession();
      if (shouldProtectSession) {
        await _lockSession(
          reason: 'Use biometrics to unlock your saved session.',
        );
      }
      return;
    }

    // Fresh login (no persisted session at launch) — offer one-time biometric setup.
    if (!_hadPersistedSessionOnLaunch && !_launchProtectionHandled) {
      _launchProtectionHandled = true;
      final biometricService = ref.read(biometricAuthServiceProvider);
      if (!biometricService.isEnabledSync && !biometricService.hasBeenSetupPrompted) {
        final availability = await biometricService.getAvailability();
        if (availability.canAuthenticate) {
          // Wait for dashboard navigation to settle before showing the sheet.
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) await _offerBiometricSetup(biometricService, availability);
        }
      }
    }
  }

  Future<void> _offerBiometricSetup(
    BiometricAuthService biometricService,
    BiometricAvailability availability,
  ) async {
    if (appNavigatorKey.currentContext == null) return;

    // Mark as prompted only after confirming we can actually show the sheet.
    await biometricService.markSetupPrompted();

    final navContext = appNavigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) return;

    final enabled = await showModalBottomSheet<bool>(
      context: navContext,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => _BiometricSetupSheet(label: availability.preferredLabel),
    );

    if (enabled == true) {
      final didAuth = await biometricService.authenticate(
        reason:
            'Use ${availability.preferredLabel} to enable quick login for Converf.',
      );
      if (didAuth) {
        try {
          final repository = ref.read(authRepositoryProvider);
          final deviceToken = await repository.registerBiometric();
          await biometricService.saveDeviceToken(deviceToken);
          await biometricService.setEnabled(true);
          appScaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(
                '${availability.preferredLabel} login enabled. '
                "You'll see it on the login screen next time.",
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF276572),
            ),
          );
        } catch (e) {
          debugPrint('[BiometricSetup] Backend registration failed: $e');
          appScaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Could not enable biometric login. Please try again in Settings.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _lockSession({required String reason}) async {
    if (!_isAuthenticated || _isLocked) {
      return;
    }

    _timer?.cancel();
    if (!mounted) {
      return;
    }

    setState(() {
      _isLocked = true;
      _lockMessage = reason;
    });

    await _promptBiometricUnlock();
  }

  Future<void> _promptBiometricUnlock() async {
    if (!_isLocked || _isUnlocking || !_isAuthenticated) {
      return;
    }

    final biometricService = ref.read(biometricAuthServiceProvider);
    final availability = await biometricService.getAvailability();
    if (!availability.canAuthenticate) {
      await biometricService.setEnabled(false);
      if (!mounted) {
        return;
      }
      setState(() {
        _isLocked = false;
        _lockMessage = null;
      });
      _recordActivity();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Biometric unlock is no longer available on this device. It has been turned off.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isUnlocking = true;
    });

    final didAuthenticate = await biometricService.authenticate(
      reason:
          'Use ${availability.preferredLabel} to continue your Converf session.',
    );

    if (!mounted) {
      return;
    }

    if (didAuthenticate) {
      setState(() {
        _isLocked = false;
        _isUnlocking = false;
        _lockMessage = null;
      });
      _recordActivity();
      return;
    }

    setState(() {
      _isUnlocking = false;
    });
  }

  Future<void> _handleResume() async {
    if (!_isAuthenticated || _isLocked) {
      return;
    }

    final now = DateTime.now();
    final lastActivity = _lastActivityAt ?? now;
    final inactiveFor = now.difference(lastActivity);

    if (inactiveFor >= widget.timeoutDuration) {
      await _handleTimeout();
      return;
    }

    _startTimer(widget.timeoutDuration - inactiveFor);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_handleResume());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _timer?.cancel();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _resetTimer,
      onPointerMove: _resetTimer,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_isLocked)
            _SessionLockOverlay(
              message:
                  _lockMessage ??
                  'Use biometrics to continue your Converf session.',
              isUnlocking: _isUnlocking,
              onUnlock: _promptBiometricUnlock,
              onLogout: () => ref.read(authProvider.notifier).logout(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription.close();
    _timer?.cancel();
    super.dispose();
  }
}

class _BiometricSetupSheet extends StatelessWidget {
  const _BiometricSetupSheet({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE6F4F1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              label == 'Face ID' ? Icons.face_outlined : Icons.fingerprint,
              color: const Color(0xFF276572),
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Enable $label Login',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Skip the password next time. Use $label to log in to Converf instantly.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF276572),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'Enable $label',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Not now',
              style: TextStyle(
                color: Color(0xFF667085),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionLockOverlay extends StatelessWidget {
  const _SessionLockOverlay({
    required this.message,
    required this.isUnlocking,
    required this.onUnlock,
    required this.onLogout,
  });

  final String message;
  final bool isUnlocking;
  final Future<void> Function() onUnlock;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xCC0F172A),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F4F1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      color: Color(0xFF276572),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Session Locked',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF667085),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isUnlocking
                          ? null
                          : () => unawaited(onUnlock()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF276572),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      icon: isUnlocking
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.fingerprint),
                      label: Text(
                        isUnlocking ? 'Checking...' : 'Unlock with biometrics',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isUnlocking ? null : onLogout,
                    child: const Text('Log out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
