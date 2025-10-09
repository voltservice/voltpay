import 'package:freezed_annotation/freezed_annotation.dart';

part 'fee_line.freezed.dart';
part 'fee_line.g.dart';

@freezed
abstract class FeeLine with _$FeeLine {
  const factory FeeLine({
    required String label, // "Wire Transfer fee" / "Our fee"
    required double amount, // 6.11
  }) = _FeeLine;

  factory FeeLine.fromJson(Map<String, dynamic> json) =>
      _$FeeLineFromJson(json);
}
