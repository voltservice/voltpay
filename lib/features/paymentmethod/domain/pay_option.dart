import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voltpay/features/paymentmethod/domain/pay_method_type.dart';

part 'pay_option.freezed.dart';
part 'pay_option.g.dart';

@freezed
abstract class PayOption with _$PayOption {
  const PayOption._();

  const factory PayOption({
    required PayMethodType type,
    required String feeCurrency, // "GBP"
    required double feeAmount, // 0.00, 0.33, 1.14...
    required String etaLabel, // "in seconds", "by tuesday"
  }) = _PayOption;

  factory PayOption.fromJson(Map<String, dynamic> json) =>
      _$PayOptionFromJson(json);

  String get feeText => '${feeAmount.toStringAsFixed(2)} $feeCurrency fee';

  String get line2 => '$feeText · should arrive $etaLabel';
}
