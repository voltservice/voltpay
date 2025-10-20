// lib/core/auth/hooks/auth_policy_providers.dart
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import 'package:voltpay/core/auth/hooks/auth_policy_client.dart';
import 'package:voltpay/core/auth/provider/auth_api_providers.dart';

// Base URL provider (override per flavor/env)
/// Back-compat alias if other code expects just the base URL.
final Provider<String> authGateBaseUrlProvider = Provider<String>((Ref ref) {
  return ref.watch(authApiConfigProvider).apiBase;
});

final Provider<http.Client> httpClientProvider = Provider<http.Client>((
  Ref ref,
) {
  final http.Client c = http.Client();
  ref.onDispose(c.close);
  return c;
});

// App Check token provider
final Provider<AppCheckTokenProvider> appCheckTokenProvider =
    Provider<AppCheckTokenProvider>((Ref ref) {
      return () async {
        return null;
      };
    });

// The client
final Provider<AuthPolicyClient> authPolicyClientProvider =
    Provider<AuthPolicyClient>((Ref ref) {
      final String baseUrl = ref.watch(authGateBaseUrlProvider);
      final http.Client client = ref.watch(httpClientProvider);
      final AppCheckTokenProvider appCheckTok = ref.watch(
        appCheckTokenProvider,
      );

      return AuthPolicyClient(
        baseUrl: baseUrl,
        client: client,
        timeout: const Duration(seconds: 5),
        beforeCreatePath: '/auth/beforeCreate',
        beforeSignInPath: '/auth/beforeSignIn',
        appCheckTokenProvider: appCheckTok,
      );
    });
