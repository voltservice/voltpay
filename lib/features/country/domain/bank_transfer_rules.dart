import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voltpay/features/country/domain/iban_spec.dart';
import 'package:voltpay/features/country/domain/local_bank_rules.dart';

part 'bank_transfer_rules.freezed.dart';
part 'bank_transfer_rules.g.dart';

@freezed
abstract class BankTransferRules with _$BankTransferRules {
  const factory BankTransferRules({
    required bool supportsIban,
    IbanSpec? iban,
    LocalBankRules? local,
  }) = _BankTransferRules;

  factory BankTransferRules.fromJson(Map<String, dynamic> json) =>
      _$BankTransferRulesFromJson(json);
}
