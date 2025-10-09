import 'package:flutter/material.dart';

enum LoginProviders { google, facebook, emailPassword }

/// The policy describes *how* to color a button given the current Theme.
/// No hard-coded Colors in the model except brand requirements.
class LoginProviderPolicy {
  final String label;
  final String iconAsset;
  final bool tintIcon; // true = tint icon with fg; false = keep original colors
  final String loadingLabel;
  final bool
      useBrandColors; // true for Google/Facebook, false for theme-colored buttons

  const LoginProviderPolicy({
    required this.label,
    required this.iconAsset,
    this.tintIcon = true,
    this.loadingLabel = 'Signing in…',
    this.useBrandColors = false,
  });

  /// Resolve runtime colors based on current ColorScheme and provider brand rules.
  ButtonColors resolve(ColorScheme scheme, Brightness brightness) {
    switch (_kindFromLabel(label)) {
      case _Kind.google:
        // Google brand: white bg, dark text, brand-colored icon (no tint), subtle border.
        return ButtonColors(
          background: Colors.white,
          foreground: Colors.black87,
          border: scheme.outlineVariant,
        );
      case _Kind.facebook:
        // Facebook brand blue regardless of theme.
        const Color fbBlue = Color(0xFF1877F2);
        return const ButtonColors(
          background: fbBlue,
          foreground: Colors.white,
          border: null,
        );
      case _Kind.email:
        // Theme-colored (adaptive): use primary/onPrimary.
        return ButtonColors(
          background: scheme.primary,
          foreground: scheme.onPrimary,
          border: null,
        );
    }
  }

  /// Convenience factory per provider.
  static LoginProviderPolicy of(LoginProviders p) {
    switch (p) {
      case LoginProviders.google:
        return const LoginProviderPolicy(
          label: 'Continue with Google',
          iconAsset: 'assets/images/google.png',
          tintIcon: false,
          useBrandColors: true,
        );
      case LoginProviders.facebook:
        return const LoginProviderPolicy(
          label: 'Continue with Facebook',
          iconAsset: 'assets/images/facebook.png',
          tintIcon: false,
          useBrandColors: true,
        );
      case LoginProviders.emailPassword:
        return const LoginProviderPolicy(
          label: 'Continue with Email',
          iconAsset: 'assets/images/email.png',
          tintIcon: true,
          useBrandColors: false,
        );
    }
  }
}

class ButtonColors {
  final Color background;
  final Color foreground;
  final Color? border; // for outlined brand like Google
  const ButtonColors({
    required this.background,
    required this.foreground,
    this.border,
  });
}

enum _Kind { google, facebook, email }

_Kind _kindFromLabel(String label) {
  if (label.contains('Google')) {
    return _Kind.google;
  }
  if (label.contains('Facebook')) {
    return _Kind.facebook;
  }
  return _Kind.email;
}
