import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/features/currency/domain/currency.dart';
import 'package:voltpay/features/currency/presentation/currency_list_picker.dart';
import 'package:voltpay/features/currency/provider/currency_provider.dart';

Future<Currency?> showCurrencyPicker(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<Currency>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (_) => const _CurrencyPickerBody(),
  );
}

class _CurrencyPickerBody extends ConsumerStatefulWidget {
  const _CurrencyPickerBody();

  @override
  ConsumerState<_CurrencyPickerBody> createState() =>
      _CurrencyPickerBodyState();
}

class _CurrencyPickerBodyState extends ConsumerState<_CurrencyPickerBody> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AsyncValue<List<Currency>> asyncAll = ref.watch(currenciesProvider);
    final List<Currency> popular = ref.watch(popularCurrenciesProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // header row with back chevron
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Choose a currency',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // search
          TextField(
            onChanged: (String v) => setState(() => q = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search for a currency / country',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // body
          Expanded(
            child: asyncAll.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object e, _) => Center(child: Text('Failed to load: $e')),
              data: (List<Currency> all) {
                final String query = q.trim().toLowerCase();
                final List<Currency> filtered = query.isEmpty
                    ? all
                    : all.where((Currency c) {
                        return c.code.toLowerCase().contains(query) ||
                            c.name.toLowerCase().contains(query);
                      }).toList();

                final List<Currency> popularList = query.isEmpty
                    ? popular
                    : filtered.where((Currency c) => c.popular).toList();

                return CustomScrollView(
                  slivers: <Widget>[
                    if (query.isEmpty && popularList.isNotEmpty) ...<Widget>[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                          child: Text(
                            'Popular currencies',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                      CurrencyListSection(
                        items: popularList,
                        onTap: (Currency c) => Navigator.pop(context, c),
                      ),
                      const SliverToBoxAdapter(child: Divider(height: 24)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                          child: Text(
                            'All currencies',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ],
                    CurrencyListSection(
                      items: query.isEmpty ? all : filtered,
                      onTap: (Currency c) => Navigator.pop(context, c),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
