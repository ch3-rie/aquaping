// lib/services/push_notifications.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotifications {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // iOS permission
    await FirebaseMessaging.instance.requestPermission();

    // Local notifications setup
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(settings);

    // Listen to messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _showLocalNotification(notification.title, notification.body);
      }
    });

    // Save device FCM token to backend
    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
    // Send this token to your backend via ApiService
  }

  static Future<void> _showLocalNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails('water_alerts', 'Water Alerts',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);
    await _localNotifications.show(0, title, body, platformDetails);
  }
}
