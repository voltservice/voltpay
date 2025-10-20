// optional: lib/core/auth/helpers/ensure_profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:voltpay/core/auth/provider/auth_api_providers.dart';
import 'package:voltpay/core/auth/service/ensure_user_profile_service.dart';

final Provider<Future<bool> Function()> ensureProfileCallProvider =
    Provider<Future<bool> Function()>((Ref ref) {
      final String base = ref.watch(authGateBaseUrlProvider);
      final http.Client client = http.Client();
      ref.onDispose(client.close);
      return () => ensureProfile(base, client: client);
    });
