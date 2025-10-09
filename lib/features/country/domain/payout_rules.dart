import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voltpay/features/country/domain/bank_transfer_rules.dart';

part 'payout_rules.freezed.dart';
part 'payout_rules.g.dart';

@freezed
abstract class PayoutRules with _$PayoutRules {
  const factory PayoutRules({
    BankTransferRules? bankTransfer,
    // TODO: add mobileMoney, cashPickup, wallet as you expand
  }) = _PayoutRules;

  factory PayoutRules.fromJson(Map<String, dynamic> json) =>
      _$PayoutRulesFromJson(json);
}
