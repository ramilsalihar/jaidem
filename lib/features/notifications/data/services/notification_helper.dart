import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:jaidem/features/notifications/data/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationLocalHelper {
  static const String _readKey = "read_notifications";

  /// Save notification as read
  static Future<void> markAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final readList = prefs.getStringList(_readKey) ?? [];
    if (!readList.contains(notificationId)) {
      readList.add(notificationId);
      await prefs.setStringList(_readKey, readList);
    }
  }

  /// Check if a notification is read
  static Future<bool> isRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final readList = prefs.getStringList(_readKey) ?? [];
    return readList.contains(notificationId);
  }

  /// Clear all locally read notifications (optional)
  static Future<void> clearRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_readKey);
  }

  static Future<List<NotificationModel>> enrichWithLocalReads(
      List<NotificationModel> notifications) async {
    final result = <NotificationModel>[];
    for (final notif in notifications) {
      final read = await NotificationLocalHelper.isRead(notif.id);
      result.add(NotificationModel(
        id: notif.id,
        message: notif.message,
        createdAt: notif.createdAt,
        authorId: notif.authorId,
        isRead: read,
      ));
    }
    return result;
  }

  static String dateFormat(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('HH:mm').format(dateTime);
    } catch (_) {
      return isoDate;
    }
  }
}
