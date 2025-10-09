// lib/core/router/app_router.dart
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/auth/provider/auth_provider.dart';
import 'package:voltpay/core/auth/repository/email_passwordless_login_repo.dart';
import 'package:voltpay/core/auth/ui/email_entry_screen.dart';
import 'package:voltpay/core/auth/ui/email_verification_pending_screen.dart';
import 'package:voltpay/core/go/go_services.dart';
import 'package:voltpay/core/router/app_routes.dart';
import 'package:voltpay/core/router/router_ext.dart';
import 'package:voltpay/core/theme/theme_switcher.dart';
import 'package:voltpay/features/home/ui/cards_screen.dart';
import 'package:voltpay/features/home/ui/home_screen.dart';
import 'package:voltpay/features/home/ui/home_shell.dart';
import 'package:voltpay/features/home/ui/payments_screen.dart';
import 'package:voltpay/features/home/ui/recipients_screen.dart';
import 'package:voltpay/features/onboarding/ui/service_screen.dart';
import 'package:voltpay/features/rates/presentation/rates_page.dart';
import 'package:voltpay/presentation/widgets/onboarding_flow.dart';
import 'package:voltpay/splash/splash_screen.dart';

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

/// A single chrome that all pages inherit.
class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    // Pick your AppBar background (surface or primary)
    // Material 3 guidance: Top app bar on surface with onSurface content.
    final Color appBarBg = scheme.surface;
    final Color appBarFg = scheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        title: Text(
          'VoltPay',
          // inherit color from foregroundColor (no hardcoded Colors.green)
          style: Theme.of(context).textTheme.titleLarge,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        actions: const <Widget>[
          // Always available; tiny and out of the way
          ThemeSwitcher(),
        ],
      ),
      body: child,
    );
  }
}

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  extraCodec: const _NoopCodec(),
  initialLocation: AppRoute.splash.path,
  routes: <RouteBase>[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return _ShellScaffold(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: AppRoute.splash.path,
          name: AppRoute.splash.name,
          builder: (BuildContext context, GoRouterState state) =>
              const SplashScreen(),
        ),
        GoRoute(
          path: AppRoute.flow.path,
          name: AppRoute.flow.name,
          builder: (BuildContext ctx, _) => OnboardingFlow(
            onCheckRates: () => ctx.goNamed(AppRoute.rate.name),
            onGetStarted: () => ctx.goNamed(AppRoute.emailEntry.name),
            onFinished: () => ctx.goNamed(AppRoute.flow.name),
          ),
        ),
        GoRoute(
          path: AppRoute.rate.path,
          name: AppRoute.rate.name,
          builder: (_, __) => const RatesPage(),
        ),
        // Somewhere in your router or caller:
        GoRoute(
          name: AppRoute.emailEntry.name,
          path: AppRoute.emailEntry.path,
          builder: (BuildContext context, GoRouterState state) {
            final String? _ = state.extra as String?;
            return Consumer(
              builder: (BuildContext context, WidgetRef ref, _) {
                return EmailEntryScreen(
                  onClose: () => context.pop(),
                  onNext: (String email) async {
                    final EmailPasswordlessLoginRepo repo = ref.read(
                      emailPasswordlessLoginRepoProvider,
                    );
                    await repo.sendEmailLink(email);
                    context.goNamed(
                      AppRoute.emailVerification.name,
                      extra: email,
                    );
                  },
                );
              },
            );
          },
        ),
        GoRoute(
          name: AppRoute.emailVerification.name,
          path: AppRoute.emailVerification.path,
          builder: (BuildContext context, GoRouterState state) {
            final String email = (state.extra as String?) ?? 'user@example.com';
            return Consumer(
              builder: (BuildContext context, WidgetRef ref, _) =>
                  EmailVerificationPendingScreen(
                email: email,
                onClose: () => context.pop(),
                onResend: (String e) async {
                  await ref
                      .read(emailPasswordlessLoginRepoProvider)
                      .sendEmailLink(e);
                },
              ),
            );
          },
        ),
        GoRoute(
          name: AppRoute.service.name,
          path: AppRoute.service.path,
          builder: (BuildContext context, GoRouterState state) => Consumer(
            builder: (BuildContext context, WidgetRef ref, _) {
              // Optional label from your auth state
              final User? user = ref.watch(firebaseUserChangesProvider).value;
              final String? label = user == null ? null : user.email ?? '';
              return ServiceScreen(
                userLabel: label, // e.g., “finaluser@gmail.com • Google”
                onClose: () => context.goNamed(AppRoute.home.name),
                onPersonalKyc: () => context.goNamed('kycPersonal'),
                onBusinessKyc: () => context.goNamed('kycBusiness'),
              );
            },
          ),
        ),
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) =>
              const HomeShell(),
          routes: <RouteBase>[
            GoRoute(
              name: AppRoute.home.name,
              path: AppRoute.home.path,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const NoTransitionPage<dynamic>(child: HomeScreen()),
            ),
            GoRoute(
              name: AppRoute.cards.name,
              path: AppRoute.cards.path,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const NoTransitionPage<dynamic>(child: CardsScreen()),
            ),
            GoRoute(
              name: AppRoute.recipients.name,
              path: AppRoute.recipients.path,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const NoTransitionPage<dynamic>(child: RecipientsScreen()),
            ),
            GoRoute(
              name: AppRoute.payments.name,
              path: AppRoute.payments.path,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const NoTransitionPage<dynamic>(child: PaymentsScreen()),
            ),
          ],
        ),
        GoRoute(
          path: AppRoute.go.path,
          name: AppRoute.go.name,
          builder: (BuildContext context, GoRouterState state) =>
              const GoTestScreen(),
        ),
        // add more routes here; they all inherit the AppBar + ThemeSwitcher
      ],
    ),
  ],
);
