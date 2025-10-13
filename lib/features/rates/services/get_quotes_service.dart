import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:voltpay/core/env/env.dart';
import 'package:voltpay/features/rates/domain/api_config.dart';
import 'package:voltpay/features/rates/domain/pay_method_type.dart';
import 'package:voltpay/features/rates/domain/quote.dart';
import 'package:voltpay/features/rates/infrastructure/quote_repository.dart';

class HttpQuoteRepository implements QuoteRepository {
  HttpQuoteRepository({ApiConfig? config, http.Client? client})
    : _config = config ?? ApiConfig(Env.apiBase),
      _client = client ?? http.Client();

  final ApiConfig _config;
  final http.Client _client;

  Future<String> health() async {
    final http.Response r = await _client
        .get(_config.healthUri())
        .timeout(const Duration(seconds: 6));
    if (r.statusCode != 200) {
      throw Exception('Health ${r.statusCode}: ${r.body}');
    }
    return r.body;
  }

  @override
  Future<Quote> getQuote({
    required String source,
    required String target,
    required double amount,
    required PaymentMethodType method,
  }) async {
    final Uri uri = _config.quotesUri(
      source: source,
      target: target,
      amount: amount,
      method: method,
    );
    debugPrint('Quotes URI => $uri'); // <— add this
    final http.Response resp = await _client
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 12));

    if (resp.statusCode != 200) {
      throw Exception('Quote API ${resp.statusCode}: ${resp.body}');
    }
    return Quote.fromJson(json.decode(resp.body) as Map<String, dynamic>);
  }

  Future<Map<String, String>> _authHeaders() async {
    // final String? token = await FirebaseAppCheck.instance.getToken(true);
    // return <String, String>{if (token != null) 'X-Firebase-AppCheck': token};
    return <String, String>{};
  }

  void dispose() => _client.close();
}
