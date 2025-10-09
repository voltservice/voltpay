import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/core/theme/theme_controller.dart';
import 'package:voltpay/core/theme/theme_dark.dart';
import 'package:voltpay/core/theme/theme_light.dart';

final Provider<ThemeModeRepository> themeRepoProvider =
    Provider<ThemeModeRepository>(
  (Ref ref) => ThemeModeRepository(),
);

final Provider<ThemeData> lightThemeProvider = Provider<ThemeData>(
  (_) => buildLightTheme(),
);
final Provider<ThemeData> darkThemeProvider = Provider<ThemeData>(
  (_) => buildDarkTheme(),
);
