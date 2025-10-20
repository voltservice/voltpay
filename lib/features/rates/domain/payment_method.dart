import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voltpay/features/rates/domain/pay_method_type.dart';

part 'payment_method.freezed.dart';
part 'payment_method.g.dart';

@freezed
abstract class PaymentMethodOption with _$PaymentMethodOption {
  const factory PaymentMethodOption({
    required PaymentMethodType type,
    required String title,
    required String subtitle,
    required double fixedFee,
    required bool available,
  }) = _PaymentMethodOption;

  // Presets (optional convenience constructors)
  factory PaymentMethodOption.wire() => const PaymentMethodOption(
    type: PaymentMethodType.wire,
    title: 'Wire Transfer',
    subtitle: '6.11 USD fee, should arrive by Thursday',
    fixedFee: 6.11,
    available: true,
  );

  factory PaymentMethodOption.debitCard() => const PaymentMethodOption(
    type: PaymentMethodType.debitCard,
    title: 'Debit Card',
    subtitle: '12.35 USD fee, should arrive by Thursday',
    fixedFee: 12.35,
    available: true,
  );

  factory PaymentMethodOption.creditCard() => const PaymentMethodOption(
    type: PaymentMethodType.creditCard,
    title: 'Credit Card',
    subtitle: '61.65 USD fee, should arrive by Thursday',
    fixedFee: 61.65,
    available: true,
  );

  factory PaymentMethodOption.accountTransfer() => const PaymentMethodOption(
    type: PaymentMethodType.accountTransfer,
    title: 'Account transfer',
    subtitle:
        'Sorry, using a multi currency account isn’t available in your country.',
    fixedFee: 0,
    available: false,
  );

  factory PaymentMethodOption.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodOptionFromJson(json);
}
