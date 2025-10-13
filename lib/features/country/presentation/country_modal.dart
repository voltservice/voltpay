import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/features/country/application/country_state.dart';
import 'package:voltpay/features/country/domain/country.dart';
import 'package:voltpay/features/country/provider/country_provider.dart';

class CountryPickerModal extends ConsumerStatefulWidget {
  const CountryPickerModal({super.key});

  @override
  ConsumerState<CountryPickerModal> createState() => _CountryPickerModalState();
}

class _CountryPickerModalState extends ConsumerState<CountryPickerModal> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    // AsyncValue<CountryState>
    final AsyncValue<CountryState> countryAsync = ref.watch(countryProvider);
    final CountryNotifier notifier = ref.read(countryProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Select your country', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          TextField(
            onChanged: (String v) => setState(() => query = v),
            decoration: const InputDecoration(
              hintText: 'Search countries',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),

          // Handle loading/error/data from AsyncValue
          SizedBox(
            height: 360,
            child: countryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object e, _) => Center(
                child: Text(
                  'Failed to load countries\n$e',
                  textAlign: TextAlign.center,
                ),
              ),
              data: (CountryState state) {
                final List<Country> filtered = query.isEmpty
                    ? state.countries
                    : notifier.search(query);

                if (filtered.isEmpty) {
                  return const Center(child: Text('No matches'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, int i) {
                    final Country c = filtered[i];
                    return ListTile(
                      onTap: () async {
                        await notifier.select(c);
                        if (mounted) {
                          Navigator.pop(context, c);
                        }
                      },
                      leading: Text(
                        c.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text('${c.name} (${c.iso2})'),
                      subtitle: Text(
                        '${c.currency.code} • ${c.currency.symbol}',
                      ),
                      trailing: Text(c.dialCode),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
