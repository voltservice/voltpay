// lib/core/theme/themes/theme_extensions.dart
import 'package:flutter/material.dart';

class Spacing extends ThemeExtension<Spacing> {
  final double xs, sm, md, lg, xl;
  const Spacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
  });

  @override
  Spacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) =>
      Spacing(
        xs: xs ?? this.xs,
        sm: sm ?? this.sm,
        md: md ?? this.md,
        lg: lg ?? this.lg,
        xl: xl ?? this.xl,
      );

  @override
  ThemeExtension<Spacing> lerp(ThemeExtension<Spacing>? other, double t) {
    if (other is! Spacing) {
      return this;
    }
    double lerpD(double a, double b) => a + (b - a) * t;
    return Spacing(
      xs: lerpD(xs, other.xs),
      sm: lerpD(sm, other.sm),
      md: lerpD(md, other.md),
      lg: lerpD(lg, other.lg),
      xl: lerpD(xl, other.xl),
    );
  }
}
