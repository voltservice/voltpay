import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/auth/interface/i_auth_repository.dart';
import 'package:voltpay/core/auth/provider/auth_provider.dart';
import 'package:voltpay/core/router/app_routes.dart';
import 'package:with_opacity/with_opacity.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scale = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOut);

    unawaited(_startupGuard());
  }

  Future<void> _startupGuard() async {
    // Give the animation a beat, then decide route.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final IAuthRepository repo = ref.read(authRepoProvider);

    // Use currentUser first for speed; fall back to one event from stream.
    final bool loggedIn = repo.isLoggedIn || await repo.authChanges().first;

    if (!mounted) {
      return;
    }
    context.goNamed(loggedIn ? AppRoute.service.name : AppRoute.flow.name);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.onSurface,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, _) {
              return Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: <Color>[scheme.primary, scheme.secondary],
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: scheme.shadow.withCustomOpacity(0.20),
                              blurRadius: 28,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.monetization_on,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'VoltPay',
                        style: text.displayMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(
                        width: 42,
                        height: 42,
                        child: CircularProgressIndicator(strokeWidth: 4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
