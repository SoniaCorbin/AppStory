import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notification reçue : ${message.notification?.title}');
      debugPrint('Corps : ${message.notification?.body}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification ouverte : ${message.notification?.title}');
      _handleNotificationTap(message);
    });
  }

  static void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'];
    debugPrint('Type de notification : $type');
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  static Future<void> saveTokenToSupabase(String userId) async {
    final token = await getToken();
    if (token == null) return;
    debugPrint('Token à sauvegarder pour $userId : $token');
  }
}