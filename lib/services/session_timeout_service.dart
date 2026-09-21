import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app.dart';
import '../core/routing/routes.dart';

class SessionTimeoutService{
  static const Duration _timeout = Duration(minutes: 30);
  static DateTime? _lastActivity;

  static void updateActivity() {
    _lastActivity = DateTime.now();
  }

  static bool get isExpired{
    if(_lastActivity == null) return false;
    return DateTime.now().difference(_lastActivity!) > _timeout;
  }

  static Future<void> checkAndLogout() async {
    if (!isExpired) return;
    await Supabase.instance.client.auth.signOut();
    _lastActivity = null;
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.auth,
        (_) => false,
    );
  }
}