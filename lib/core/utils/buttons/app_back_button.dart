import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/router/app_routes.dart';

/// A reusable, flexible back button that:
/// - Pops the current route by default.
/// - Can optionally go to a specific named route or run a custom callback.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.routeName,
    this.icon,
    this.tooltip,
  });

  /// Optional custom handler. If provided, this takes priority.
  final VoidCallback? onPressed;

  /// Optional GoRouter named route to navigate to instead of popping.
  final String? routeName;

  /// Optionally override the back icon (e.g., close or chevron)
  final IconData? icon;

  /// Optional tooltip for accessibility.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(icon ?? Icons.arrow_back_ios_new),
      color: scheme.onSurface,
      tooltip: tooltip ?? 'Back',
      onPressed:
          onPressed ??
          () {
            if (routeName != null) {
              context.goNamed(routeName!);
            } else if (context.canPop()) {
              context.pop();
            } else {
              // fallback: go home if nothing to pop
              context.goNamed(AppRoute.home.name);
            }
          },
    );
  }
}
