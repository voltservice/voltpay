import 'package:flutter/material.dart';
import 'package:voltpay/features/rates/domain/payment_method.dart';

class PaymentMethodRow extends StatelessWidget {
  const PaymentMethodRow({
    required Key key,
    required this.method,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  const PaymentMethodRow.selected({
    required Key key,
    required this.method,
    required this.onTap,
  }) : selected = true,
       super(key: key);

  const PaymentMethodRow.unselected({
    required Key key,
    required this.method,
    required this.onTap,
  }) : selected = false,
       super(key: key);

  final PaymentMethodOption method;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: <Widget>[
            // radio indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? scheme.primary : scheme.outlineVariant,
                  width: 2,
                ),
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: selected ? 1 : 0,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Opacity(
                opacity: method.available ? 1.0 : 0.45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      method.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.subtitle,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
