import 'package:auto_route/auto_route.dart';
import 'package:jaidem/features/app/presentation/pages/splash_screen.dart';
import 'package:jaidem/features/auth/presentation/pages/login_page.dart';

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
        ),
      ];
}
