import 'package:voltpay/core/router/app_routes.dart';

extension AppRouteExtension on AppRoute {
  String get path {
    switch (this) {
      case AppRoute.splash:
        return '/splash';
      case AppRoute.home:
        return '/home';
      case AppRoute.cards:
        return '/cards';
      case AppRoute.recipients:
        return '/recipients';
      case AppRoute.payments:
        return '/payments';
      case AppRoute.flow:
        return '/flow';
      case AppRoute.onboarding:
        return '/onboarding';
      case AppRoute.obnlastpg:
        return '/obnlastpg';
      case AppRoute.remit:
        return '/remit';
      case AppRoute.send:
        return '/send';
      case AppRoute.boost:
        return '/boost';
      case AppRoute.rate:
        return '/rate';
      case AppRoute.emailEntry:
        return '/email-entry';
      case AppRoute.login:
        return '/login';
      case AppRoute.emailVerification:
        return '/email-verification';
      case AppRoute.service:
        return '/service';
      case AppRoute.go:
        return '/go';
    }
  }
}
