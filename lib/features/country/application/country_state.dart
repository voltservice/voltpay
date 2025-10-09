import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voltpay/features/country/domain/country.dart';

part 'country_state.freezed.dart';

@freezed
abstract class CountryState with _$CountryState {
  const factory CountryState({
    @Default(<Country>[]) List<Country> countries,
    Country? selected,
    @Default(false) bool loading,
    String? error,
  }) = _CountryState;
}
