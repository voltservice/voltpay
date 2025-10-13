// features/rates/domain/payment_method.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pay_method_type.g.dart';

@JsonEnum(alwaysCreate: true)
enum PaymentMethodType {
  @JsonValue('wire')
  wire,
  @JsonValue('debitCard')
  debitCard,
  @JsonValue('creditCard')
  creditCard,
  @JsonValue('accountTransfer')
  accountTransfer,
}

extension PaymentMethodTypeX on PaymentMethodType {
  String get apiCode => _$PaymentMethodTypeEnumMap[this]!;
  String get label => switch (this) {
    PaymentMethodType.wire => 'Wire Transfer',
    PaymentMethodType.debitCard => 'Debit Card',
    PaymentMethodType.creditCard => 'Credit Card',
    PaymentMethodType.accountTransfer => 'Account transfer',
  };
  String get feeLinkLabel => '$label fee';
}
