import 'package:freezed_annotation/freezed_annotation.dart';

part 'phone_plan.freezed.dart';
part 'phone_plan.g.dart';

@freezed
abstract class PhonePlan with _$PhonePlan {
  const factory PhonePlan({
    String? example, // "7400123456"
    int? minLen, // 7
    int? maxLen, // 11
  }) = _PhonePlan;

  factory PhonePlan.fromJson(Map<String, dynamic> json) =>
      _$PhonePlanFromJson(json);
}
