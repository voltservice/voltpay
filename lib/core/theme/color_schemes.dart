import 'package:flutter/material.dart';

const Color _brandSeed = Color(0xFF00C38D);

final ColorScheme lightScheme = ColorScheme.fromSeed(
  seedColor: _brandSeed,
  brightness: Brightness.light,
  surface: const Color(0xFFF9FAFB), // slightly off-white
  surfaceContainer: const Color(0xFFF2F4F5),
  onSurface: const Color(0xFF121418),
  surfaceTint: _brandSeed,
);

final ColorScheme darkScheme = ColorScheme.fromSeed(
  seedColor: _brandSeed,
  brightness: Brightness.dark,
  surface: const Color(0xFF111315), // not fully black
  surfaceContainer: const Color(0xFF1C1F24),
  onSurface: const Color(0xFFEFF1F2),
  surfaceTint: _brandSeed,
);
