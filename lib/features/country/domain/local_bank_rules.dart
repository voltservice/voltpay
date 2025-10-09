import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voltpay/features/country/domain/length_rule.dart';

part 'local_bank_rules.freezed.dart';
part 'local_bank_rules.g.dart';

@freezed
abstract class LocalBankRules with _$LocalBankRules {
  const factory LocalBankRules({
    LengthRule? accountNumber,
    LengthRule? routing,
  }) = _LocalBankRules;

  factory LocalBankRules.fromJson(Map<String, dynamic> json) =>
      _$LocalBankRulesFromJson(json);
}
