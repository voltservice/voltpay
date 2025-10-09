import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import 'package:voltpay/core/env/env.dart';
import 'package:voltpay/features/rates/domain/api_config.dart';
import 'package:voltpay/features/rates/infrastructure/quote_repository.dart';
import 'package:voltpay/features/rates/services/get_quotes_service.dart';

final Provider<ApiConfig> apiConfigProvider = Provider<ApiConfig>(
  (_) => ApiConfig(Env.apiBase),
);
final Provider<http.Client> httpClientProvider = Provider<http.Client>(
  (_) => http.Client(),
);
final Provider<QuoteRepository> quoteRepoProvider = Provider<QuoteRepository>(
  (Ref ref) => HttpQuoteRepository(
    config: ref.watch(apiConfigProvider),
    client: ref.watch(httpClientProvider),
  ),
);
