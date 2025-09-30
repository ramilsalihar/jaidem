import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/features/jaidems/data/datasources/jaidems_remote_data_source.dart';
import 'package:jaidem/features/jaidems/data/datasources/jaidems_remote_data_source_impl.dart';
import 'package:jaidem/features/jaidems/domain/usecases/get_jaidems_usecase.dart';
import 'package:jaidem/features/jaidems/presentation/cubit/jaidems_cubit.dart';

void jaidemInjection() {
  // Data Source
  sl.registerSingleton<JaidemsRemoteDataSource>(
      JaidemsRemoteDataSourceImpl(dio: sl()));

  // Reopsitory

  // Usecases
  sl.registerFactory(() => GetJaidemsUsecase(sl()));

  // Cubits
  sl.registerFactory(() => JaidemsCubit(getJaidemsUsecase: sl()));
}
