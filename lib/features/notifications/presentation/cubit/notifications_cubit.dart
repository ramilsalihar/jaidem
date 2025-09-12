import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/notifications/data/models/notification_model.dart';
import 'package:jaidem/features/notifications/data/services/notification_helper.dart';
import 'package:jaidem/features/notifications/domain/usecases/get_notifications_usecase.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required this.getNotificationsUsecase,
  }) : super(NotificationsInitial());

  final GetNotificationsUsecase getNotificationsUsecase;

  Future<void> fetchNotifications() async {
    emit(NotificationsLoading());

    final result = await getNotificationsUsecase();

    result.fold((failure) => emit(NotificationsError(message: failure)),
        (notifications) async {
      final enriched =
          await NotificationLocalHelper.enrichWithLocalReads(notifications);
      emit(NotificationsLoaded(notifications: enriched));
    });
  }

  Future<void> markAllAsRead() async {
    if (state is NotificationsLoaded) {
      final current = (state as NotificationsLoaded).notifications;

      for (final notif in current) {
        if (!notif.isRead) {
          await NotificationLocalHelper.markAsRead(notif.id);
        }
      }

      fetchNotifications();
    }
  }
}
