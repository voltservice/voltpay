import 'package:flutter/material.dart';
import 'package:voltpay/core/brand/brand_colors.dart';
import 'package:voltpay/core/theme/color_schemes.dart';
import 'package:voltpay/core/theme/theme_extensions.dart';
import 'package:with_opacity/with_opacity.dart';

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: darkScheme,
    // ✅ Use background for scaffold; onSurface is a foreground color.
    scaffoldBackgroundColor: const Color(
      0xFF0B0E11,
    ), // or darkScheme.background
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: BrandColor.deepSlate, // or darkScheme.surface
      foregroundColor: Colors.white, // or darkScheme.onSurface
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardColor: const Color(0xFF1C1F24),
    dividerColor: Colors.white.withCustomOpacity(0.08),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1C1F24),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        shape: const StadiumBorder(),
        backgroundColor: darkScheme.primary,
        foregroundColor: darkScheme.onPrimary,
        disabledBackgroundColor: Colors.white12,
        disabledForegroundColor: Colors.white38,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: darkScheme.primary),
    ),
    extensions: const <ThemeExtension<Spacing>>[Spacing()],
  );
}
