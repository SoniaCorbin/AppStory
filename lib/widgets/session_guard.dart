import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/session_timeout_service.dart';

class SessionGuard extends StatefulWidget {
  final Widget child;
  const SessionGuard({super.key, required this.child});

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SessionTimeoutService.updateActivity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (AuthService.isLoggedIn) {
        SessionTimeoutService.checkAndLogout();
      }
    } else if (state == AppLifecycleState.paused) {
      SessionTimeoutService.updateActivity();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}