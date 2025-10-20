import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voltpay/features/paymentmethod/domain/pay_method_type.dart';

part 'topup_params.freezed.dart';
part 'topup_params.g.dart';

@freezed
abstract class TopUpParams with _$TopUpParams {
  const TopUpParams._();

  const factory TopUpParams({
    @Default(0.0) double amount,
    @Default('GBP') String currency,
    @Default(PayMethodType.bankTransfer) PayMethodType payMethod,
    @Default('Today') String arrivalLabel,
  }) = _TopUpParams;

  factory TopUpParams.fromJson(Map<String, dynamic> json) =>
      _$TopUpParamsFromJson(json);

  bool get isValid => amount > 0.0;
  String get formattedAmountNoCents => amount.toStringAsFixed(2);
}
