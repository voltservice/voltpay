import 'package:flutter/material.dart';

/// Minimal, on-brand palette (Revolut/Wise vibe)
class BrandColor {
  // 🌑 Dark / Core
  static const Color voltBlack = Color(0xFF0B0E11);
  static const Color deepSlate = Color(0xFF1C1F24);
  static const Color charcoalInk = Color(0xFF2A2E35);

  // 💚 Primary / Accents
  static const Color voltGreen = Color(0xFF00C38D);
  static const Color tealSurge = Color(0xFF0ABF9E);
  static const Color limeAccent = Color(0xFFA8FF60);

  // ✨ Light / Onboarding
  static const Color mintCloud = Color(0xFFE6FFF6);
  static const Color coolWhite = Color(0xFFF9FAFB);
  static const Color voltLightTeal = Color(0xFFCFF9EB);

  // 🎨 Neutrals
  static const Color softGray = Color(0xFF9CA3AF);
  static const Color warmGray = Color(0xFFD1D5DB);
  static const Color offWhite = Color(0xFFF3F4F6);

  // App bars / icons (fallbacks if needed)
  static const Color appBarDarkBG = deepSlate;
  static const Color appBarDarkFG = Colors.white;
  static const Color appBarLightBG = Colors.white;
  static const Color appBarLightFG = Colors.black;
}

class BrandGradients {
  const BrandGradients._();

  /// Onboarding hero (light)
  static const LinearGradient onboardingHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      BrandColor.mintCloud,
      BrandColor.voltLightTeal,
      BrandColor.tealSurge,
    ],
  );

  /// Primary CTA
  static const LinearGradient cta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[BrandColor.voltGreen, BrandColor.limeAccent],
  );

  /// Premium card (dark) – subtle teal shift over slate
  static const LinearGradient premiumCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: <double>[0.0, 0.5, 1.0],
    colors: <Color>[
      BrandColor.deepSlate,
      BrandColor.charcoalInk,
      BrandColor.tealSurge,
    ],
  );

  /// Notification banner (dark)
  static const LinearGradient notification = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF1B4D4F), // deep teal
      Color(0xFF2D2D34), // charcoal
    ],
  );
}
