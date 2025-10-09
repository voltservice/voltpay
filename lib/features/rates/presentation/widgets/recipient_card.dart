import 'package:flutter/material.dart';

class RecipientCard extends StatelessWidget {
  const RecipientCard({
    required this.amount,
    required this.currency,
    required this.onPickCurrency,
  });
  final String amount;
  final String currency;
  final VoidCallback onPickCurrency;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 72,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Text(
            amount,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          InkWell(
            onTap: onPickCurrency,
            child: Row(
              children: <Widget>[
                const CircleAvatar(radius: 12, child: Text('🇪🇺')),
                const SizedBox(width: 8),
                Text(
                  currency,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
