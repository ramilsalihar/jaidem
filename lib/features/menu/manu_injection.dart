import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/features/menu/presentation/cubit/menu_cubit.dart';

void menuInjection() {
  // Register the MenuCubit
  sl.registerFactory<MenuCubit>(
    () => MenuCubit(
      signOutUsecase: sl(),
    ),
  );
}
