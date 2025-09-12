import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:jaidem/features/notifications/data/datasources/notification_remote_data_source_impl.dart';
import 'package:jaidem/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:jaidem/features/notifications/presentation/cubit/notifications_cubit.dart';

void notificationInjection() {
  // Datasources
  sl.registerSingleton<NotificationRemoteDataSource>(
      NotificationRemoteDataSourceImpl(firestore: sl()));

  // Repositories

  // Usecases
  sl.registerFactory(() => GetNotificationsUsecase(sl()));

  // Cubits
  sl.registerFactory(() => NotificationsCubit(getNotificationsUsecase: sl()));
}
