import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:voltpay/features/country/application/country_state.dart';
import 'package:voltpay/features/country/domain/country.dart';
import 'package:voltpay/features/country/infrastructure/country_storage.dart';

part 'country_provider.g.dart';

/// Use @riverpod to generate a strongly-typed provider called [countryNotifierProvider].
@riverpod
class CountryNotifier extends _$CountryNotifier {
  final CountryStorage _storage = CountryStorage();

  @override
  FutureOr<CountryState> build() async {
    try {
      final String raw =
          await rootBundle.loadString('assets/data/countries.json');

      final List<Country> list = (json.decode(raw) as List<dynamic>)
          .map((dynamic e) => Country.fromJson(e as Map<String, dynamic>))
          .toList();

      Country? selected;

      // restore saved iso2
      final String? savedIso2 = await _storage.loadIso2();
      if (savedIso2 != null) {
        selected = list.firstWhere(
          (Country c) => c.iso2.toUpperCase() == savedIso2.toUpperCase(),
          orElse: () => list.first,
        );
      }

      // default to device locale if none saved
      selected ??= _defaultForLocale(
        list,
        WidgetsBinding.instance.platformDispatcher.locale,
      );

      return CountryState(
        countries: list,
        selected: selected,
        loading: false,
      );
    } catch (e) {
      return CountryState(loading: false, error: e.toString());
    }
  }

  Country _defaultForLocale(List<Country> all, Locale locale) {
    final String cc = (locale.countryCode ?? '').toUpperCase();
    return all.firstWhere(
      (Country c) => c.iso2.toUpperCase() == cc,
      orElse: () => all.first,
    );
  }

  Future<void> select(Country country) async {
    state = AsyncData<CountryState>(
      (state.value ?? const CountryState()).copyWith(selected: country),
    );
    await _storage.saveIso2(country.iso2);
  }

  List<Country> search(String query) {
    final CountryState current = state.value ?? const CountryState();
    final String q = query.trim().toLowerCase().replaceAll('+', '');
    return current.countries.where((Country c) {
      final String code = c.dialCode.replaceAll('+', '');
      return c.name.toLowerCase().contains(q) ||
          c.iso2.toLowerCase().contains(q) ||
          code.contains(q);
    }).toList();
  }
}
