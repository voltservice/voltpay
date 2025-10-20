import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:voltpay/features/currency/domain/currency.dart';
import 'package:voltpay/features/currency/provider/currency_provider.dart';

part 'currency_family_provider.g.dart';

@riverpod
Currency? currencyByCode(Ref ref, String code) {
  final Map<String, Currency> idx = ref.watch(currencyIndexProvider);
  return idx[code];
}
