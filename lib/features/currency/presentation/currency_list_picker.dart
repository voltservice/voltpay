import 'package:flutter/material.dart';
import 'package:voltpay/features/currency/domain/currency.dart';

class CurrencyListSection extends StatelessWidget {
  const CurrencyListSection({required this.items, required this.onTap});

  final List<Currency> items;
  final ValueChanged<Currency> onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return SliverList.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, int i) {
        final Currency c = items[i];
        return ListTile(
          onTap: () => onTap(c),
          leading: Text(c.flag, style: const TextStyle(fontSize: 28)),
          title: Text(
            c.code,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(c.name),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}
