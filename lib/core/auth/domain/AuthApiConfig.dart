// lib/core/net/auth_api_config.dart
class AuthApiConfig {
  const AuthApiConfig({
    required this.baseUrl,
    this.beforeCreatePath = '/auth/beforeCreate',
    this.beforeSignInPath = '/auth/beforeSignIn',
    this.usersEnsurePath = '/users/ensure',
    this.attachApiPrefix = false,
  });

  /// Root of your service (Cloud Run or Functions).
  /// e.g. https://authgate-xyz.a.run.app  OR  https://authgate-xyz.a.run.app/api
  final String baseUrl;

  /// Endpoint paths (customizable if you ever remap routes).
  final String beforeCreatePath;
  final String beforeSignInPath;
  final String usersEnsurePath;

  /// If true, we normalize to `<base>/api` unless it already ends with `/api`.
  final bool attachApiPrefix;

  /// Normalized API root (adds `/api` if requested & missing).
  String get apiBase {
    if (!attachApiPrefix) {
      return _stripTrailing(baseUrl);
    }
    final String root = _stripTrailing(baseUrl);
    return root.endsWith('/api') ? root : '$root/api';
  }

  Uri get beforeCreateUri => _join(apiBase, beforeCreatePath);
  Uri get beforeSignInUri => _join(apiBase, beforeSignInPath);
  Uri get usersEnsureUri => _join(apiBase, usersEnsurePath);

  // ---------- helpers ----------
  static String _stripTrailing(String s) =>
      s.isNotEmpty && s.endsWith('/') ? s.substring(0, s.length - 1) : s;

  static String _stripLeading(String s) =>
      s.isNotEmpty && s.startsWith('/') ? s.substring(1) : s;

  static Uri _join(String base, String path) {
    final String b = _stripTrailing(base);
    final String p = _stripLeading(path);
    return Uri.parse('$b/$p');
  }

  /// Convenience factories for env-based config (Flutter build-time env).
  /// Strict (throws if missing) – use only when you KNOW you pass --dart-define.
  factory AuthApiConfig.fromEnv({bool attachApiPrefix = false}) {
    const String raw = String.fromEnvironment('FUNCTION_API', defaultValue: '');
    if (raw.isEmpty) {
      throw StateError(
        'Missing FUNCTION_API. Provide with --dart-define=FUNCTION_API=<url>',
      );
    }
    return AuthApiConfig(baseUrl: raw, attachApiPrefix: attachApiPrefix);
  }

  /// Relaxed: use env if present, otherwise fall back to the given base.
  factory AuthApiConfig.fromEnvOr({
    required String fallbackBaseUrl,
    bool attachApiPrefix = false,
  }) {
    const String raw = String.fromEnvironment('FUNCTION_API', defaultValue: '');
    final String base = raw.isNotEmpty ? raw : fallbackBaseUrl;
    return AuthApiConfig(baseUrl: base, attachApiPrefix: attachApiPrefix);
  }
}
