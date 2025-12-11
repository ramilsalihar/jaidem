import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/features/events/data/datasources/event_remote_data_source.dart';
import 'package:jaidem/features/events/data/datasources/event_remote_data_source_impl.dart';
import 'package:jaidem/features/events/data/repositories/event_repository_impl.dart';
import 'package:jaidem/features/events/domain/repositories/event_repository.dart';
import 'package:jaidem/features/events/domain/usecases/get_events_usecase.dart';
import 'package:jaidem/features/events/domain/usecases/send_attendance_usecase.dart';
import 'package:jaidem/features/events/domain/usecases/update_event_usecase.dart';
import 'package:jaidem/features/events/presentation/cubit/events_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void eventInjection() {
  // Datasource
  sl.registerSingleton<EventRemoteDataSource>(EventRemoteDataSourceImpl(
    dio: sl(),
    prefs: sl(),
  ));

  // Repositories
  sl.registerSingleton<EventRepository>(
      EventRepositoryImpl(remoteDataSource: sl()));

  // Usecases
  sl.registerFactory(() => GetEventsUsecase(sl()));

  sl.registerFactory(() => SendAttendanceUsecase(sl()));

  sl.registerFactory(() => UpdateEventUseCase(sl()));

  // Cubits
  sl.registerFactory(() => EventsCubit(
        getEventsUsecase: sl(),
        sendEventRequestUsecase: sl(),
        updateEventUseCase: sl(),
      ));
}
