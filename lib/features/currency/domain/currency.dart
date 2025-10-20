import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency.freezed.dart';
part 'currency.g.dart';

@freezed
abstract class Currency with _$Currency {
  const Currency._(); // allows adding custom getters later

  const factory Currency({
    required String code, // "EUR"
    required String name, // "Euro"
    required String flag, // emoji or asset flag
    @Default(false) bool popular,
  }) = _Currency;

  factory Currency.fromJson(Map<String, dynamic> json) =>
      _$CurrencyFromJson(json);
}
