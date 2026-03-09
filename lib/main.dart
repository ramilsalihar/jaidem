import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/data/services/push_notification_service.dart';
import 'package:jaidem/features/goals/data/services/goal_reminder_service.dart';
import 'package:jaidem/firebase_options.dart';
import 'core/app/app.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await initInjections();

  await PushNotificationService().initialize();

  // Create goal reminder notification channel
  await GoalReminderService().createChannel();

  runApp(const App());
}
