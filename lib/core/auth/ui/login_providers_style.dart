import 'package:flutter/material.dart';

enum _Kind { google, facebook, emailPassword, apple, passkey }

_Kind _kindFromLabel(String label) {
  if (label.contains('Google')) {
    return _Kind.google;
  }
  if (label.contains('Facebook')) {
    return _Kind.facebook;
  }
  if (label.contains('Email')) {
    return _Kind.emailPassword;
  }
  if (label.contains('Apple')) {
    return _Kind.apple;
  }
  if (label.contains('Passkey')) {
    return _Kind.passkey;
  }
  return _Kind.emailPassword;
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

enum LoginProviders { google, facebook, apple, passkey, emailPassword }

/// The policy describes *how* to color a button given the current Theme.
/// No hard-coded Colors in the model except brand requirements.
class LoginProviderPolicy {
  final String label;
  final String iconAsset;
  final bool tintIcon;
  final String loadingLabel;
  final bool useBrandColors;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  const LoginProviderPolicy({
    required this.label,
    required this.iconAsset,
    this.tintIcon = true,
    this.loadingLabel = 'Signing in…',
    this.useBrandColors = false,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor = Colors.transparent,
    this.borderColor,
  });

  /// Resolve runtime colors based on current ColorScheme and provider brand rules.
  ButtonColors resolve(
    ColorScheme scheme,
    Brightness brightness,
    LoginProviderPolicy provider,
  ) {
    switch (_kindFromLabel(label)) {
      case _Kind.google:
        return ButtonColors(
          background: provider.backgroundColor,
          foreground: provider.foregroundColor,
          border: null,
        );
      case _Kind.facebook:
        return ButtonColors(
          background: provider.backgroundColor,
          foreground: provider.foregroundColor,
          border: null,
        );
      case _Kind.apple:
        return ButtonColors(
          background: provider.backgroundColor,
          foreground: provider.foregroundColor,
          border: null,
        );
      case _Kind.emailPassword:
        // Theme-colored (adaptive): use primary/onPrimary.
        return ButtonColors(
          background: provider.backgroundColor,
          foreground: provider.foregroundColor,
          border: null,
        );
      case _Kind.passkey:
        final bool _ = brightness == Brightness.dark;
        return ButtonColors(
          background: provider.backgroundColor,
          foreground: provider.foregroundColor,
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
          loadingLabel: 'Signing in…',
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          borderColor: Colors.black,
        );
      case LoginProviders.facebook:
        return const LoginProviderPolicy(
          label: 'Continue with Facebook',
          iconAsset: 'assets/images/facebook.png',
          tintIcon: false,
          useBrandColors: true,
          loadingLabel: 'Signing in…',
          backgroundColor: Colors.blue,
          foregroundColor: Colors.black,
        );
      case LoginProviders.emailPassword:
        return const LoginProviderPolicy(
          label: 'Continue with Email',
          iconAsset: 'assets/images/email.png',
          tintIcon: true,
          useBrandColors: false,
          loadingLabel: 'Signing in…',
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
        );
      case LoginProviders.apple:
        return const LoginProviderPolicy(
          label: 'Continue with apple',
          iconAsset: 'assets/images/apple.png',
          tintIcon: true,
          useBrandColors: false,
          loadingLabel: 'Signing in…',
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          borderColor: Colors.black,
        );
      case LoginProviders.passkey:
        return const LoginProviderPolicy(
          label: 'Continue with passkey',
          iconAsset: 'assets/images/passkey.png',
          tintIcon: true,
          useBrandColors: false,
          loadingLabel: 'Signing in…',
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        );
    }
  }
}
