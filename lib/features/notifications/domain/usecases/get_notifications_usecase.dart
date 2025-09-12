import 'package:dartz/dartz.dart';
import 'package:jaidem/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:jaidem/features/notifications/data/models/notification_model.dart';

class GetNotificationsUsecase {
  final NotificationRemoteDataSource repository;

  const GetNotificationsUsecase(this.repository);

  Future<Either<String, List<NotificationModel>>> call() {
    return repository.getNotifications();
  }
}
