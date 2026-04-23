import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/router/app_routes.dart';
import 'package:gpsc_prep_app/utils/enums/user_role.dart';

import '../../core/helpers/supabase_helper.dart';

class FCMService {
  final SupabaseHelper _supabase;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  FCMService(this._supabase);

  Future<Map<String, dynamic>?> setupFirebaseMessaging() async {
    try {
      // Initialize Local Notifications to handle taps on banners
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null) {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            _handleNotificationClick(data);
          }
        },
      );

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _setFcmToken(fcmToken);
        await _subscribeToTopics();
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        await _setFcmToken(token);
        await _subscribeToTopics();
      });

      FirebaseMessaging.onMessage.listen((payload) {
        debugPrint("DATA: ${payload.data}");
        final notification = payload.notification;
        if (notification != null) {
          _showLocalNotification(payload);
        }
      });

      // Handle taps when app is in background but still in memory
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationClick(message.data);
      });

      // Check for message that opened the app from terminated state
      final RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        debugPrint(
          "App opened from terminated state via notification: ${initialMessage.data}",
        );
        return initialMessage.data;
      }
    } catch (e) {
      debugPrint("Firebase setup failed: $e");
    }
    return null;
  }

  /// Centralized logic to handle navigating when a notification is tapped.
  /// This maps the FCM data payload to the app's existing deep-link routes.
  void _handleNotificationClick(Map<String, dynamic> data) {
    final route = getRouteFromData(data);
    if (route != null) {
      debugPrint("Navigating to: $route");
      AppRouter.router.push(route);
    }
  }

  /// Maps the FCM data payload to the app's existing deep-link routes.
  String? getRouteFromData(Map<String, dynamic> data) {
    final String? type = data['type']?.toString();
    final String? referenceId = data['reference_id']?.toString();
    final String? testType = data['test_type']?.toString();

    if (type == 'course' && referenceId != null) {
      return '/openCourse?id=$referenceId';
    } else if (type == 'test' && referenceId != null) {
      // Normalize type for the router (expects 'mcq' or 'desc')
      final String normalizedType =
          (testType == 'desc' || testType == 'descriptive') ? 'desc' : 'mcq';
      return '/openTest?type=$normalizedType&id=$referenceId';
    }
    return null;
  }

  Future<void> requestNotificationPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
        // Refresh token after permission granted
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await _setFcmToken(fcmToken);
        }
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }
    } catch (e) {
      debugPrint("Error requesting notification permission: $e");
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

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
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _setFcmToken(String token) async {
    await _supabase.updateOrInsertFcmToken(token);
  }

  Future<void> _subscribeToTopics() async {
    try {
      // 1. Always subscribe to all_users for general broadcasts
      await FirebaseMessaging.instance.subscribeToTopic("all_users");
      debugPrint("Subscribed to all_users topic");

      // 2. Subscribe to role-based topics for targeting
      final role = getIt<CacheManager>().getUserRole();
      if (role == UserRole.student) {
        await FirebaseMessaging.instance.subscribeToTopic("student");
        debugPrint("Subscribed to students topic");
      } else if (role == UserRole.mentor) {
        await FirebaseMessaging.instance.subscribeToTopic("mentor");
        debugPrint("Subscribed to mentors topic");
      }
    } catch (e) {
      debugPrint("Error subscribing to topics: $e");
    }
  }
}
