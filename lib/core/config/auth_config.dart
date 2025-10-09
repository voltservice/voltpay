// lib/core/config/auth_config.dart
class AuthConfig {
  const AuthConfig({
    required this.googleWebClientId,
    this.googleIosClientId,
    this.googleMacosClientId,
  });

  final String googleWebClientId; // REQUIRED for Android (serverClientId)
  final String? googleIosClientId; // Recommended for iOS/macOS
  final String? googleMacosClientId;

  // Read from --dart-define
  static const AuthConfig fromEnv = AuthConfig(
    googleWebClientId: String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
    googleIosClientId: String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
    googleMacosClientId: String.fromEnvironment('GOOGLE_MACOS_CLIENT_ID'),
  );
}
