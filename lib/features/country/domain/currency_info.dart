import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency_info.freezed.dart';
part 'currency_info.g.dart';

@freezed
abstract class CurrencyInfo with _$CurrencyInfo {
  const factory CurrencyInfo({
    required String code, // GBP
    required String name, // Pound sterling
    required String symbol, // £
  }) = _CurrencyInfo;

  factory CurrencyInfo.fromJson(Map<String, dynamic> json) =>
      _$CurrencyInfoFromJson(json);
}
