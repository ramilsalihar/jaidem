import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/features/birthday/data/datasources/birthday_remote_data_source.dart';
import 'package:jaidem/features/birthday/data/datasources/birthday_remote_data_source_impl.dart';
import 'package:jaidem/features/birthday/data/repositories/birthday_repository_impl.dart';
import 'package:jaidem/features/birthday/domain/repositories/birthday_repository.dart';
import 'package:jaidem/features/birthday/domain/usecases/get_my_birthday_reactions_usecase.dart';
import 'package:jaidem/features/birthday/domain/usecases/get_today_birthdays_usecase.dart';
import 'package:jaidem/features/birthday/domain/usecases/send_birthday_reaction_usecase.dart';

void birthdayInjection() {
  // Data sources
  sl.registerSingleton<BirthdayRemoteDataSource>(
    BirthdayRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<BirthdayRepository>(
    () => BirthdayRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTodayBirthdaysUseCase(sl()));
  sl.registerLazySingleton(() => SendBirthdayReactionUseCase(sl()));
  sl.registerLazySingleton(() => GetMyBirthdayReactionsUseCase(sl()));
}
