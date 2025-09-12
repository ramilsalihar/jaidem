import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:jaidem/features/notifications/data/models/notification_model.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;

  NotificationRemoteDataSourceImpl({required this.firestore});

  @override
  Future<Either<String, List<NotificationModel>>> getNotifications() async {
    try {
      final querySnapshot = await firestore
          .collection(ApiConst.notifications)
          .orderBy('createdAt', descending: true)
          .get();

      final notifications = querySnapshot.docs
          .map((doc) => NotificationModel.fromFirebase(doc))
          .toList();

      return Right(notifications);
    } on FirebaseException catch (e) {
      return Left("Firebase error: ${e.message}");
    } catch (e) {
      return Left("Unexpected error: $e");
    }
  }
}
