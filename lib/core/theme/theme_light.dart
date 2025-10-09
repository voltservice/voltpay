import 'package:flutter/material.dart';
import 'package:voltpay/core/brand/brand_colors.dart';
import 'package:voltpay/core/theme/color_schemes.dart';
import 'package:voltpay/core/theme/theme_extensions.dart';
import 'package:with_opacity/with_opacity.dart';

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: lightScheme,
    // ✅ Use background for scaffold
    scaffoldBackgroundColor: BrandColor.coolWhite, // or lightScheme.background
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: BrandColor.appBarLightBG, // or lightScheme.surface
      foregroundColor: BrandColor.appBarLightFG, // or lightScheme.onSurface
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: Colors.black,
      ),
      iconTheme: IconThemeData(color: Colors.black),
    ),
    cardColor: Colors.white,
    dividerColor: Colors.black.withCustomOpacity(0.06),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        shape: const StadiumBorder(),
        backgroundColor: lightScheme.primary,
        foregroundColor: lightScheme.onPrimary,
        disabledBackgroundColor: Colors.black12,
        disabledForegroundColor: Colors.black38,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: lightScheme.primary),
    ),
    extensions: const <ThemeExtension<dynamic>>[Spacing()],
  );
}
