import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/style/app_theme.dart';
import 'package:jaidem/features/auth/presentation/cubit/auth_cubit.dart';

final appRouter = sl<AppRouter>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => sl<AuthCubit>(),
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
