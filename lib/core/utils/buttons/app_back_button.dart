import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/router/app_routes.dart';

/// Minimal back button that pops the current route.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new),
      color: Theme.of(context).colorScheme.onSurface,
      onPressed: () => context.goNamed(AppRoute.flow.name),
    );
  }
}
