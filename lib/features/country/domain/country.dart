import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voltpay/features/country/domain/currency_info.dart';
import 'package:voltpay/features/country/domain/payout_rules.dart';
import 'package:voltpay/features/country/domain/phone_plan.dart';

part 'country.freezed.dart';
part 'country.g.dart';

@freezed
abstract class Country with _$Country {
  const factory Country({
    // identity
    required String iso2, // "GB"
    required String iso3, // "GBR"
    required String name, // "United Kingdom"
    required String flag, // "🇬🇧"
    required String dialCode, // money/phone
    required CurrencyInfo currency,
    required PhonePlan phone, // payout constraints
    required PayoutRules payoutRules,
    String? region, // "Europe"
  }) = _Country;

  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);
}
