import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'app_routes.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    // Home Route
    AutoRoute(
      page: HomeWrapperRoute.page,
      path: '/',
      initial: true,
    ),
  ];
}
