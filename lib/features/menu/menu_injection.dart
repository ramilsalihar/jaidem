import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/features/menu/data/datasources/menu_remote_datasource_impl.dart';
import 'package:jaidem/features/menu/data/datasources/menu_remote_datasource.dart';
import 'package:jaidem/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:jaidem/features/menu/domain/repositories/menu_repository.dart';
import 'package:jaidem/features/menu/domain/usecases/create_chat_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/get_chats_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/get_files_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/get_messages_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/mark_message_as_read_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/send_message_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/get_users_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/get_chat_with_user_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/get_chat_with_mentor_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/get_chat_with_admin_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/send_message_to_user_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/send_message_to_mentor_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/send_message_to_admin_usecase.dart';
import 'package:jaidem/features/menu/presentation/cubit/chat_cubit/chat_cubit.dart';
import 'package:jaidem/features/menu/presentation/cubit/menu_cubit/menu_cubit.dart';

void menuInjection() {
  // Datasource
  sl.registerSingleton<MenuRemoteDatasource>(
    MenuRemoteDatasourceImpl(sl(), sl(), sl()),
  );

  // Repostiroes
  sl.registerSingleton<MenuRepository>(
    MenuRepositoryImpl(sl()),
  );

  // Usecases
  sl.registerFactory(() => CreateChatUsecase(sl()));

  sl.registerFactory(() => GetChatsUseCase(sl()));

  sl.registerFactory(() => GetMessagesUseCase(sl()));

  sl.registerFactory(() => MarkMessageAsReadUseCase(sl()));

  sl.registerFactory(() => SendMessageUseCase(sl()));

  sl.registerFactory(() => GetUsersUseCase(sl()));

  // New specific chat use cases
  sl.registerFactory(() => GetChatWithUserUseCase(sl()));
  sl.registerFactory(() => GetChatWithMentorUseCase(sl()));
  sl.registerFactory(() => GetChatWithAdminUseCase(sl()));
  sl.registerFactory(() => SendMessageToUserUseCase(sl()));
  sl.registerFactory(() => SendMessageToMentorUseCase(sl()));
  sl.registerFactory(() => SendMessageToAdminUseCase(sl()));

  sl.registerFactory(() => GetFilesUsecase(sl()));

  // Register the MenuCubit
  sl.registerFactory<MenuCubit>(
    () => MenuCubit(
      signOutUsecase: sl(),
      getFilesUsecase: sl(),
    ),
  );

  sl.registerFactory<ChatCubit>(
    () => ChatCubit(
      sendMessageUseCase: sl(),
      getMessagesUseCase: sl(),
      getChatsUseCase: sl(),
      getUsersUseCase: sl(),
      getChatWithUserUseCase: sl(),
      getChatWithMentorUseCase: sl(),
      getChatWithAdminUseCase: sl(),
      sendMessageToUserUseCase: sl(),
      sendMessageToMentorUseCase: sl(),
      sendMessageToAdminUseCase: sl(),
    ),
  );
}
