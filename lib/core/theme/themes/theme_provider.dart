// lib/core/theme/themes/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/core/theme/themes/theme_dark.dart';
import 'package:voltpay/core/theme/themes/theme_light.dart';

/// Persisted setting (swap to SharedPreferences/Hive as needed)
class ThemeModeRepository {
  ThemeMode _mode = ThemeMode.system;
  Future<ThemeMode> load() async => _mode;
  Future<void> save(ThemeMode mode) async => _mode = mode;
}

final Provider<ThemeModeRepository> themeRepoProvider =
    Provider<ThemeModeRepository>(
      (Ref<ThemeModeRepository> ref) => ThemeModeRepository(),
    );

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Could be async; keeping sync for simplicity. Use AsyncNotifier if loading from disk.
    final ThemeModeRepository repo = ref.read(themeRepoProvider);
    // ignore: discarded_futures
    repo.load().then((ThemeMode value) => state = value);
    return ThemeMode.system;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref.read(themeRepoProvider).save(mode);
  }
}

final NotifierProvider<ThemeModeController, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(
      () => ThemeModeController(),
    );

final Provider<ThemeData> lightThemeProvider = Provider<ThemeData>(
  (_) => buildLightTheme(),
);
final Provider<ThemeData> darkThemeProvider = Provider<ThemeData>(
  (_) => buildDarkTheme(),
);
