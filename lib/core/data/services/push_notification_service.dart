import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  FirebaseFirestore get _firestore => sl<FirebaseFirestore>();
  SharedPreferences get _prefs => sl<SharedPreferences>();
  String? get _userId => _prefs.getString(AppConstants.userId);

  /// Initialize everything — call after Firebase.initializeApp and initInjections
  Future<void> initialize() async {
    await _requestPermission();
    await _initLocalNotifications();
    await _setupMessageHandlers();
    await _saveTokenToFirestore();
    _listenToTokenRefresh();
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('FCM permission: ${settings.authorizationStatus}',
        name: 'PushNotification');
  }

  Future<void> _initLocalNotifications() async {
    const androidChannel = AndroidNotificationChannel(
      'jaidem_default',
      'Jaidem Notifications',
      description: 'Default notification channel for Jaidem',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  Future<void> _setupMessageHandlers() async {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/terminated tap (app opened via notification)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'jaidem_default',
          'Jaidem Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    _navigateFromPayload(message.data);
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromPayload(data);
    } catch (_) {}
  }

  void _navigateFromPayload(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final router = sl<AppRouter>();

    switch (type) {
      case 'training':
        router.pushPath('/trainings');
        break;
      case 'notification':
      default:
        router.pushPath('/main');
        break;
    }
  }

  // --- Token Management ---

  Future<void> _saveTokenToFirestore() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      final flowId = _prefs.getInt('user_flow_id') ?? 0;

      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'flowId': flowId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      log('FCM token saved for user $userId', name: 'PushNotification');
    } catch (e) {
      log('Error saving FCM token: $e', name: 'PushNotification');
    }
  }

  void _listenToTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      final userId = _userId;
      if (userId == null || userId.isEmpty) return;

      try {
        final flowId = _prefs.getInt('user_flow_id') ?? 0;

        await _firestore.collection('users').doc(userId).set({
          'fcmToken': newToken,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'flowId': flowId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        log('Error updating FCM token: $e', name: 'PushNotification');
      }
    });
  }

  /// Call after login to update token for newly authenticated user
  Future<void> onUserLogin() async {
    await _saveTokenToFirestore();
  }

  /// Call on logout to clear token
  Future<void> onUserLogout() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
    } catch (_) {}
  }
}
