import 'package:auto_route/auto_route.dart';
import 'package:jaidem/features/app/presentation/pages/bottom_bar_page.dart';
import 'package:jaidem/features/app/presentation/pages/splash_screen.dart';
import 'package:jaidem/features/auth/presentation/pages/login_page.dart';
import 'package:jaidem/features/forum/presentation/pages/forum_page.dart';

part 'package:jaidem/core/routes/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: SplashRoute.page,
          path: '/',
        ),
        CustomRoute(
          page: LoginRoute.page,
          path: '/login',
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 300),
        ),
        CustomRoute(
          page: BottomBarRoute.page,
          path: '/main',
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 300),
        ),
      ];
}
