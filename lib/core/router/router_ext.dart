import 'package:voltpay/core/router/app_routes.dart';

extension AppRouteExtension on AppRoute {
  String get path {
    switch (this) {
      case AppRoute.splash:
        return '/';
      case AppRoute.go:
        return '/go';
    }
  }
}
