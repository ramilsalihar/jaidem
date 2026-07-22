import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/features/stories/data/datasources/seen_stories_store.dart';
import 'package:jaidem/features/stories/data/datasources/stories_remote_data_source.dart';
import 'package:jaidem/features/stories/data/datasources/stories_remote_data_source_impl.dart';
import 'package:jaidem/features/stories/domain/usecases/stories_usecase.dart';
import 'package:jaidem/features/stories/presentation/cubit/stories_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void storiesInjection() {
  // Data Source
  sl.registerSingleton<StoriesRemoteDataSource>(
      StoriesRemoteDataSourceImpl(dio: sl()));

  sl.registerLazySingleton<SeenStoriesStore>(
      () => SeenStoriesStore(sl<SharedPreferences>()));

  // Usecases
  sl.registerFactory(() => StoriesUsecase(sl()));

  // Cubits
  sl.registerFactory(() => StoriesCubit(storiesUsecase: sl(), seenStore: sl()));
}
