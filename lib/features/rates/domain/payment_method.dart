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

  factory PaymentMethodOption.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodOptionFromJson(json);
}
