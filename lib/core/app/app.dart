import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/data/services/usage_service.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/localization/locale_cubit.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/style/app_theme.dart';
import 'package:jaidem/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:jaidem/features/events/presentation/cubit/events_cubit.dart';
import 'package:jaidem/features/forum/presentation/cubit/forum_cubit.dart';
import 'package:jaidem/features/goals/presentation/cubit/goals/goals_cubit.dart';
import 'package:jaidem/features/goals/presentation/cubit/indicators/indicators_cubit.dart';
import 'package:jaidem/features/goals/presentation/cubit/tasks/tasks_cubit.dart';
import 'package:jaidem/features/jaidems/presentation/cubit/jaidems_cubit.dart';
import 'package:jaidem/features/menu/presentation/cubit/chat_cubit/chat_cubit.dart';
import 'package:jaidem/features/menu/presentation/cubit/menu_cubit/menu_cubit.dart';
import 'package:jaidem/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:jaidem/features/profile/presentation/cubit/profile_cubit.dart';

final appRouter = sl<AppRouter>();

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Track app usage on launch
    UsageService().updateAppLastUsedTime();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Track app usage when app comes to foreground
      UsageService().updateAppLastUsedTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(
          create: (context) => LocaleCubit(),
        ),
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
        BlocProvider<ChatCubit>(
          create: (context) => sl<ChatCubit>(),
        ),
        BlocProvider<GoalsCubit>(
          create: (context) => sl<GoalsCubit>(),
        ),
        BlocProvider<IndicatorsCubit>(
          create: (context) => sl<IndicatorsCubit>(),
        ),
        BlocProvider<TasksCubit>(
          create: (context) => sl<TasksCubit>(),
        ),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            title: 'Jaidem',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.lightTheme,
            routerConfig: appRouter.config(),
            locale: locale,
            supportedLocales: LocaleCubit.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
