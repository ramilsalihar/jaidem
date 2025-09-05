import 'package:dio/dio.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/features/forum/data/datasources/forum_remote_data_source.dart';
import 'package:jaidem/features/forum/data/datasources/forum_remote_data_source_impl.dart';
import 'package:jaidem/features/forum/data/repositories/forum_repository_impl.dart';
import 'package:jaidem/features/forum/domain/repositories/forum_repository.dart';
import 'package:jaidem/features/forum/domain/usecases/get_all_forums.dart';
import 'package:jaidem/features/forum/domain/usecases/get_forum_comment.dart';
import 'package:jaidem/features/forum/domain/usecases/post_forum_comment.dart';
import 'package:jaidem/features/forum/presentation/cubit/forum_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void forumInjection() {
  // Data sources
  sl.registerSingleton<ForumRemoteDataSource>(
      ForumRemoteDataSourceImpl(sl<Dio>(), sl<SharedPreferences>()));

  // Repositories
  sl.registerSingleton<ForumRepository>(
      ForumRepositoryImpl(remoteDataSource: sl()));

  // Use cases
  sl.registerFactory(() => GetAllForums(sl()));

  sl.registerFactory(() => GetForumComment(sl()));

  sl.registerFactory(() => PostForumComment(sl()));

  // Cubits
  sl.registerFactory(
    () => ForumCubit(
      getAllForums: sl(),
      getForumComment: sl(),
      postForumComment: sl(),
    ),
  );
}
