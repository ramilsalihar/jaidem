import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/style/app_theme.dart';
import 'package:jaidem/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:jaidem/features/events/presentation/cubit/events_cubit.dart';
import 'package:jaidem/features/forum/presentation/cubit/forum_cubit.dart';
import 'package:jaidem/features/jaidems/presentation/cubit/jaidems_cubit.dart';
import 'package:jaidem/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:jaidem/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:jaidem/features/profile/presentation/cubit/profile_cubit.dart';

final appRouter = sl<AppRouter>();

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => sl<AuthCubit>(),
        ),
        BlocProvider<MenuCubit>(
          create: (context) => sl<MenuCubit>(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => sl<ProfileCubit>(),
        ),
        BlocProvider<ForumCubit>(
          create: (context) => sl<ForumCubit>(),
        ),
        BlocProvider<NotificationsCubit>(
          create: (context) => sl<NotificationsCubit>()..fetchNotifications(),
        ),
        BlocProvider<EventsCubit>(
          create: (context) => sl<EventsCubit>(),
        ),
        BlocProvider<JaidemsCubit>(
          create: (context) => sl<JaidemsCubit>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Jaidem',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.lightTheme,
        routerConfig: appRouter.config(),
      ),
    );
  }
}
