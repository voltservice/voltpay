// lib/core/theme/themes/theme_light.dart
import 'package:flutter/material.dart';
import 'package:voltpay/core/theme/themes/index.dart';

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: lightScheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: lightScheme.surface,
      foregroundColor: lightScheme.onSurface,
      centerTitle: true,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        shape: const StadiumBorder(),
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      Spacing(), // default spacings
    ],
  );
}
