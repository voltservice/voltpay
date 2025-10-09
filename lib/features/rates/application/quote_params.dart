// features/rates/application/quote_params.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voltpay/features/rates/domain/pay_method_type.dart';

part 'quote_params.freezed.dart';

@freezed
abstract class QuoteParams with _$QuoteParams {
  const factory QuoteParams({
    required String source,
    required String target,
    required double amount,
    required PaymentMethodType method, // enum, not String
  }) = _QuoteParams;
}
