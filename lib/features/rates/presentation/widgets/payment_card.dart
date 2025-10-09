import 'package:flutter/material.dart';

class AmountCard extends StatelessWidget {
  const AmountCard({
    required this.controller,
    required this.currency,
    required this.onChanged,
    required this.onPickCurrency,
  });
  final TextEditingController controller;
  final String currency;
  final ValueChanged<String> onChanged;
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
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                hintText: '0',
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPickCurrency,
            child: Row(
              children: <Widget>[
                const CircleAvatar(radius: 12, child: Text('🇺🇸')),
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
