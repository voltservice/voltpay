import 'package:freezed_annotation/freezed_annotation.dart';

part 'iban_spec.freezed.dart';
part 'iban_spec.g.dart';

@freezed
abstract class IbanSpec with _$IbanSpec {
  const factory IbanSpec({
    required int length, // 22
    required String countryCode, // "GB"
  }) = _IbanSpec;

  factory IbanSpec.fromJson(Map<String, dynamic> json) =>
      _$IbanSpecFromJson(json);
}
