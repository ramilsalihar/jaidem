import 'package:flutter/material.dart';
import 'package:jaidem/features/notifications/data/models/notification_model.dart';
import 'package:jaidem/features/notifications/presentation/widgets/notification_content.dart';

mixin NotificationMixin<T extends StatefulWidget> on State<T> {
  void showNotificationPopup(List<NotificationModel> notifications) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: NotificationContent(notifications: notifications),
        );
      },
    );
  }
}
