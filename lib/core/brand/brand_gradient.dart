import 'package:flutter/material.dart';

class BrandGradients {
  const BrandGradients._(); // Prevent instantiation

  static const LinearGradient premiumCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: <double>[0.0, 0.55, 0.75, 1.0],
    colors: <Color>[
      Color(0xFF1E3888), // Deep blue
      Color(0xFF2C4D7A), // Lighter blue
      Color(0xFF4A148C), // Deep purple
      Color(0xFF6A1B9A), // Lighter purple
    ],
  );

  /// Platinum card gradient
  static const Gradient platinum = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFECECEC), // Platinum highlight
      Color(0xFFC9D1D3), // Light metallic grey
      Color(0xFFB5B5B5), // Brushed steel
      Color(0xFFDDE2E4), // Subtle cool tint
    ],
  );

  /// Gold card gradient
  static const Gradient gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFFFD700), // Gold highlight
      Color(0xFFFFC700), // Light metallic gold
      Color(0xFFFFB300), // Brushed gold
      Color(0xFFFFE5B4), // Subtle warm tint
    ],
  );

  /// Silver card gradient
  static const Gradient silver = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFC0C0C0), // Silver highlight
      Color(0xFFAFAFAF), // Light metallic silver
      Color(0xFFB0B0B0), // Brushed silver
      Color(0xFFD3D3D3), // Subtle cool tint
    ],
  );

  /// Bronze card gradient
  static const Gradient bronze = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFCD7F32), // Bronze highlight
      Color(0xFFB87333), // Light metallic bronze
      Color(0xFFA0522D), // Brushed bronze
      Color(0xFFD2B48C), // Subtle warm tint
    ],
  );

  /// Premium VoltPay card gradient
  static const Gradient premium = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF1E3888), // Deep blue
      Color(0xFF2C4D7A), // Lighter blue
      Color(0xFF4A148C), // Deep purple
      Color(0xFF6A1B9A), // Lighter purple
    ],
  );

  /// Notification banner gradient (distinct from cards)
  static const Gradient notification = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF1B4D4F), // Deep teal shift
      Color(0xFF2D2D34), // Charcoal gray
    ],
  );

  // Card gradients
  static const Gradient platinumCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFECECEC), // Platinum highlight
      Color(0xFFC9D1D3), // Light metallic grey
      Color(0xFFB5B5B5), // Brushed steel
      Color(0xFFDDE2E4), // Subtle cool tint
    ],
  );
}
