// lib/core/theme/themes/theme_dark.dart
import 'package:flutter/material.dart';
import 'package:voltpay/core/theme/themes/color_schemes.dart';
import 'package:voltpay/core/theme/themes/theme_extensions.dart';

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: darkScheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: darkScheme.surface,
      foregroundColor: darkScheme.onSurface,
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
    extensions: const <ThemeExtension<Spacing>>[Spacing()],
  );
}
