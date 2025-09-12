import 'package:dartz/dartz.dart';
import 'package:jaidem/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<Either<String, List<NotificationModel>>> getNotifications();
}
