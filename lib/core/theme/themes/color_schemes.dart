import 'package:flutter/material.dart';

const Color _brandSeed = Color(0xFF26A96C);

final ColorScheme lightScheme = ColorScheme.fromSeed(
  seedColor: _brandSeed,
  brightness: Brightness.light,
);

final ColorScheme darkScheme = ColorScheme.fromSeed(
  seedColor: _brandSeed,
  brightness: Brightness.dark,
);
