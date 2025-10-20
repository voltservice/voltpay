// lib/core/utils/buttons/app_close_button.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/router/app_routes.dart';

class AppCloseButton extends StatelessWidget {
  const AppCloseButton({super.key, this.onPressed, this.color});

  /// If null, will pop the current route automatically.
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: const Icon(Icons.close_rounded),
      tooltip: 'Close',
      color: color ?? scheme.onSurface,
      onPressed:
          onPressed ??
          () {
            // Smart route pop — works in most cases
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.goNamed(AppRoute.home.name);
            }
          },
    );
  }
}
