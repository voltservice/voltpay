import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/features/currency/domain/currency.dart';

final FutureProvider<List<Currency>>
currenciesProvider = FutureProvider<List<Currency>>((Ref ref) async {
  final String raw = await rootBundle.loadString('assets/data/currencies.json');
  final List<Currency> list = (json.decode(raw) as List<dynamic>)
      .map((dynamic e) => Currency.fromJson(e as Map<String, dynamic>))
      .toList();
  // Ensure uniqueness, keep first (useful if you list EUR twice for “popular”)
  final Set<String> seen = <String>{};
  final List<Currency> deduped = <Currency>[];
  for (final Currency c in list) {
    if (seen.add(c.code)) {
      deduped.add(c);
    }
  }
  // Sort alphabetically for “All currencies”
  deduped.sort((Currency a, Currency b) => a.code.compareTo(b.code));
  return deduped;
});

final Provider<List<Currency>> popularCurrenciesProvider =
    Provider<List<Currency>>((Ref ref) {
      final AsyncValue<List<Currency>> async = ref.watch(currenciesProvider);
      return async.maybeWhen(
        data: (List<Currency> all) =>
            all.where((Currency c) => c.popular).toList(),
        orElse: () => const <Currency>[],
      );
    });
