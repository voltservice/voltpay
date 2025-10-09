// lib/core/theme/theme_switcher.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/core/theme/theme_controller.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeMode mode = ref.watch(themeControllerProvider);
    return PopupMenuButton<AppThemeMode>(
      initialValue: mode,
      onSelected: (AppThemeMode m) =>
          ref.read(themeControllerProvider.notifier).setMode(m),
      icon: const Icon(Icons.brightness_6, size: 24, color: Colors.teal),
      itemBuilder: (_) => const <PopupMenuEntry<AppThemeMode>>[
        PopupMenuItem<AppThemeMode>(
          value: AppThemeMode.system,
          child: Text('System'),
        ),
        PopupMenuItem<AppThemeMode>(
          value: AppThemeMode.light,
          child: Text('Light'),
        ),
        PopupMenuItem<AppThemeMode>(
          value: AppThemeMode.dark,
          child: Text('Dark'),
        ),
      ],
    );
  }
}
