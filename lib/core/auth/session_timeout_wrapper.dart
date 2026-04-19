import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/models/auth_response.dart';
import '../../features/auth/services/biometric_auth_service.dart';
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
    final currentAuthState = ref.watch(authProvider).valueOrNull;
    ref.listen<AsyncValue<AuthResponse?>>(authProvider, (previous, next) {
      unawaited(_handleAuthStateChanged(next.valueOrNull));
    });

    final currentIsAuthenticated = currentAuthState?.isAuthenticated ?? false;
    if (currentIsAuthenticated != _isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_handleAuthStateChanged(currentAuthState));
      });
    }

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
    _timer?.cancel();
    super.dispose();
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
