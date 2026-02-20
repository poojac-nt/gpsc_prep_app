import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/helpers/supabase_helper.dart';

class FCMService {
  final SupabaseHelper _supabase;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  FCMService(this._supabase);

  Future<void> setupFirebaseMessaging() async {
    try {
      await FirebaseMessaging.instance.requestPermission();

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _setFcmToken(fcmToken);
        await FirebaseMessaging.instance.subscribeToTopic("all_users");
        debugPrint("Subscribed to all_users topic");
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        await _setFcmToken(token);
        await FirebaseMessaging.instance.subscribeToTopic("all_users");
        debugPrint("Subscribed to all_users topic (refreshed)");
      });

      FirebaseMessaging.onMessage.listen((payload) {
        final notification = payload.notification;
        if (notification != null) {
          _showLocalNotification(notification);
        }
      });
    } catch (e) {
      debugPrint("Firebase setup failed: $e");
    }
  }

  Future<void> _showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> _setFcmToken(String token) async {
    await _supabase.updateOrInsertFcmToken(token);
  }
}
