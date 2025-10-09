// lib/features/rates/infrastructure/volt_api_client.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:voltpay/core/env/env.dart';
import 'package:voltpay/features/rates/domain/quote.dart';

class VoltApiClient {
  VoltApiClient({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Uri _u(String path, [Map<String, String>? q]) =>
      Uri.parse('${Env.apiBase}$path').replace(queryParameters: q);

  Future<String> health() async {
    final http.Response r =
        await _client.get(_u('/health')).timeout(const Duration(seconds: 6));
    if (r.statusCode != 200) {
      throw Exception('Health ${r.statusCode}: ${r.body}');
    }
    return r.body;
  }

  Future<Quote> getQuote({
    required String source,
    required String target,
    required double amount,
    required String method,
  }) async {
    final Map<String, String> q = <String, String>{
      'source': source,
      'target': target,
      'amount': amount.toStringAsFixed(2),
      'method': method,
    };
    final http.Response r = await _client
        .get(_u('/quotes', q), headers: await _authHeaders())
        .timeout(const Duration(seconds: 10));

    if (r.statusCode != 200) {
      throw Exception('Quote ${r.statusCode}: ${r.body}');
    }
    return Quote.fromJson(json.decode(r.body) as Map<String, dynamic>);
  }

  /// Optional: keep sending App Check header (Cloud Run won’t verify unless you add server-side verification).
  Future<Map<String, String>> _authHeaders() async {
    // If you later add App Check verification on Cloud Run:
    // final String? token = await FirebaseAppCheck.instance.getToken(true);
    // return <String, String>{'X-Firebase-AppCheck': token ?? ''};
    return <String, String>{};
  }
}
