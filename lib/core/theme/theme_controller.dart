// lib/core/theme/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_controller.g.dart';

enum AppThemeMode { system, light, dark }

extension AppThemeModeX on AppThemeMode {
  ThemeMode get material => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}

// Simple repo (no codegen)
class ThemeModeRepository {
  ThemeMode _mode = ThemeMode.system;
  Future<ThemeMode> load() async => _mode;
  Future<void> save(ThemeMode mode) async => _mode = mode;
}

// ✅ Plain Provider (avoids deprecated annotation usage)
final Provider<ThemeModeRepository> themeRepoProvider =
    Provider<ThemeModeRepository>((Ref ref) => ThemeModeRepository());

@riverpod
class ThemeController extends _$ThemeController {
  @override
  AppThemeMode build() {
    // (If you later want to actually load persisted mode, switch to AsyncNotifier)
    return AppThemeMode.system;
  }

  void setMode(AppThemeMode mode) {
    state = mode;
    ref.read(themeRepoProvider).save(mode.material);
  }

  void toggleLightDark() {
    state = switch (state) {
      AppThemeMode.light => AppThemeMode.dark,
      AppThemeMode.dark => AppThemeMode.light,
      AppThemeMode.system => AppThemeMode.dark,
    };
    ref.read(themeRepoProvider).save(state.material);
  }
}
