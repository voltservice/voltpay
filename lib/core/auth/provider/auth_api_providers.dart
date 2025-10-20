// lib/core/net/auth_api_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/core/auth/domain/AuthApiConfig.dart';
import 'package:voltpay/core/env/env.dart'; // wherever your Env class lives

final Provider<AuthApiConfig> authApiConfigProvider = Provider<AuthApiConfig>((
  Ref ref,
) {
  // This will NOT throw: uses FUNCTION_API if provided, else Env.funcBase
  return AuthApiConfig.fromEnvOr(
    fallbackBaseUrl: Env.funcBase,
    attachApiPrefix: false, // set true if your server expects /api
  );
});

// Back-compat for places that only want the base string
final Provider<String> authGateBaseUrlProvider = Provider<String>((Ref ref) {
  return ref.watch(authApiConfigProvider).apiBase;
});
