import 'package:freezed_annotation/freezed_annotation.dart';

part 'length_rule.freezed.dart';
part 'length_rule.g.dart';

@freezed
abstract class LengthRule with _$LengthRule {
  const factory LengthRule({
    List<int>? lengths, // [8] or [6]
    int? minLen, // 6
    int? maxLen, // 17
    String? label, // "ABA routing"
    String? formatHint, // "12-34-56"
  }) = _LengthRule;

  factory LengthRule.fromJson(Map<String, dynamic> json) =>
      _$LengthRuleFromJson(json);
}
