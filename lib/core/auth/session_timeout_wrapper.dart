import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';

class SessionTimeoutWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final Duration timeoutDuration;

  const SessionTimeoutWrapper({
    super.key,
    required this.child,
    this.timeoutDuration = const Duration(minutes: 15),
  });

  @override
  ConsumerState<SessionTimeoutWrapper> createState() => _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends ConsumerState<SessionTimeoutWrapper> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeoutDuration, _handleTimeout);
  }

  void _resetTimer([_]) {
    _startTimer();
  }

  void _handleTimeout() {
    final authState = ref.read(authProvider).value;
    
    // Only log out if there is an active session
    if (authState != null && authState.isAuthenticated) {
      debugPrint('[AUTH] Session inactivity timeout reached. Logging out...');
      ref.read(authProvider.notifier).logout();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired due to inactivity.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } else {
      // If we are on the login screen/unauthenticated, we don't log out.
      // But we restart the timer just so it stays active.
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _resetTimer,
      onPointerMove: _resetTimer, 
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
