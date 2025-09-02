import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/go/go_services.dart';
import 'package:voltpay/core/router/app_routes.dart';
import 'package:voltpay/core/router/router_ext.dart';

class _NoopCodec extends Codec<Object?, Object?> {
  const _NoopCodec();

  @override
  Object? decode(Object? input) => input;

  @override
  Object? encode(Object? input) => input;

  @override
  Converter<Object?, Object?> get encoder => const _NoopConverter();

  @override
  Converter<Object?, Object?> get decoder => const _NoopConverter();
}

class _NoopConverter extends Converter<Object?, Object?> {
  const _NoopConverter();

  @override
  Object? convert(Object? input) => input;
}

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  extraCodec: const _NoopCodec(),
  initialLocation: '/go',
  routes: <RouteBase>[
    GoRoute(
      path: AppRoute.go.path,
      name: AppRoute.go.name,
      builder: (BuildContext context, GoRouterState state) =>
          const GoTestScreen(),
    ),
  ],
);
