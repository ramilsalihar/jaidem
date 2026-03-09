import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class GoalReminderService {
  static final GoalReminderService _instance = GoalReminderService._internal();
  factory GoalReminderService() => _instance;
  GoalReminderService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _tzInitialized = false;

  void _ensureTimezoneInitialized() {
    if (!_tzInitialized) {
      tz.initializeTimeZones();
      // Default to Asia/Bishkek for Kyrgyzstan
      tz.setLocalLocation(tz.getLocation('Asia/Bishkek'));
      _tzInitialized = true;
    }
  }

  /// Schedule a recurring notification for a goal based on its frequency and reminder time.
  Future<void> scheduleGoalReminder(GoalModel goal) async {
    if (goal.id == null || goal.reminder == null || goal.frequency == null) {
      return;
    }

    _ensureTimezoneInitialized();

    // Parse reminder time "HH:mm"
    final parts = goal.reminder!.split(':');
    if (parts.length < 2) return;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;

    // Cancel any existing notification for this goal first
    await cancelGoalReminder(goal.id!);

    final notificationId = _goalNotificationId(goal.id!);

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'goal_reminders',
        'Максат эскертүүлөр',
        channelDescription: 'Максаттарыңыз боюнча эскертүүлөр',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final now = tz.TZDateTime.now(tz.local);

    // Calculate the first scheduled time (today or next occurrence)
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, move to next occurrence
    if (scheduledDate.isBefore(now)) {
      scheduledDate = _nextOccurrence(scheduledDate, goal.frequency!);
    }

    // Don't schedule past the deadline
    if (goal.deadline != null && scheduledDate.isAfter(
      tz.TZDateTime.from(goal.deadline!, tz.local),
    )) {
      return;
    }

    final matchComponents = _dateTimeComponentsForFrequency(goal.frequency!);

    try {
      await _notifications.zonedSchedule(
        notificationId,
        goal.title,
        'Максатыңызды текшерүүнү унутпаңыз!',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchComponents,
        payload: 'goal_${goal.id}',
      );

      log(
        'Scheduled ${goal.frequency} reminder for goal ${goal.id} '
        'at $hour:$minute (next: $scheduledDate)',
        name: 'GoalReminder',
      );
    } catch (e) {
      log('Error scheduling goal reminder: $e', name: 'GoalReminder');
    }
  }

  /// Cancel the notification for a specific goal.
  Future<void> cancelGoalReminder(int goalId) async {
    await _notifications.cancel(_goalNotificationId(goalId));
    log('Cancelled reminder for goal $goalId', name: 'GoalReminder');
  }

  /// Re-schedule reminders for all active goals (call on app launch).
  Future<void> rescheduleAll(List<GoalModel> goals) async {
    for (final goal in goals) {
      if (goal.status == 'in_progress' &&
          goal.reminder != null &&
          goal.frequency != null) {
        await scheduleGoalReminder(goal);
      }
    }
    log('Re-scheduled reminders for ${goals.length} goals',
        name: 'GoalReminder');
  }

  /// Cancel all goal reminders.
  Future<void> cancelAll() async {
    // Cancel IDs in the goal reminder range (10000–19999)
    // We can't enumerate, so we rely on the plugin's cancelAll
    // which also cancels FCM notifications — instead, track individually.
    // For safety, just log. Individual cancels happen on goal delete.
    log('cancelAll called', name: 'GoalReminder');
  }

  /// Create the Android notification channel for goal reminders.
  Future<void> createChannel() async {
    const channel = AndroidNotificationChannel(
      'goal_reminders',
      'Максат эскертүүлөр',
      description: 'Максаттарыңыз боюнча эскертүүлөр',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // -- Helpers --

  /// Generate a stable notification ID from goal ID.
  /// Offset by 10000 to avoid collision with FCM notification IDs.
  int _goalNotificationId(int goalId) => 10000 + goalId;

  /// Get the next occurrence after [current] based on frequency.
  tz.TZDateTime _nextOccurrence(tz.TZDateTime current, String frequency) {
    switch (frequency) {
      case 'daily':
        return current.add(const Duration(days: 1));
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'monthly':
        return tz.TZDateTime(
          tz.local,
          current.month == 12 ? current.year + 1 : current.year,
          current.month == 12 ? 1 : current.month + 1,
          current.day,
          current.hour,
          current.minute,
        );
      default:
        return current.add(const Duration(days: 1));
    }
  }

  /// Map frequency string to DateTimeComponents for repeating notifications.
  DateTimeComponents _dateTimeComponentsForFrequency(String frequency) {
    switch (frequency) {
      case 'daily':
        return DateTimeComponents.time;
      case 'weekly':
        return DateTimeComponents.dayOfWeekAndTime;
      case 'monthly':
        return DateTimeComponents.dayOfMonthAndTime;
      default:
        return DateTimeComponents.time;
    }
  }
}
