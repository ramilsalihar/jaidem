import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:jaidem/features/notifications/presentation/widgets/notification_content.dart';

mixin NotificationMixin<T extends StatefulWidget> on State<T> {
  void showNotificationPopup() {
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
          child: const NotificationContent(),
        );
      },
    ).then((_) {
      // 🔹 Mark all as read when dialog closes
      context.read<NotificationsCubit>().markAllAsRead();
    });
  }
}
