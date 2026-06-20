import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for managing Firebase Cloud Messaging notifications.
class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Initialize FCM and request permissions.
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request notification permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
          '🔔 Notification permission: ${settings.authorizationStatus}');

      // Initialize local notifications for foreground messages
      const androidInitSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      const initSettings = InitializationSettings(android: androidInitSettings);
      
      await _localNotifications.initialize(settings: initSettings);

      // Create a high importance channel for Android 8+
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', 
        'High Importance Notifications', 
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Get the FCM token
      final token = await _messaging.getToken();
      debugPrint('🔔 FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Handle notification tap when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Subscribe to topics
      await _messaging.subscribeToTopic('all_users');
      await _messaging.subscribeToTopic('daily_reminders');

      _initialized = true;
      debugPrint('✅ Notification service initialized');
    } catch (e) {
      debugPrint('❌ Notification service failed: $e');
    }
  }

  /// Get the current FCM token.
  static Future<String?> getToken() => _messaging.getToken();

  /// Handle foreground messages.
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📩 Foreground message: ${message.notification?.title}');
    
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/launcher_icon',
          ),
        ),
      );
    }
  }

  /// Handle message tap when app was in background.
  static void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('📩 Message opened app: ${message.notification?.title}');
    // Navigate to relevant screen based on message data
  }

  /// Subscribe to a topic.
  static Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  /// Unsubscribe from a topic.
  static Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);
}

/// Top-level handler for background messages.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('📩 Background message: ${message.notification?.title}');
}
