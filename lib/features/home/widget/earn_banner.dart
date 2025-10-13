import 'package:flutter/material.dart';

class EarnBanner extends StatelessWidget {
  const EarnBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Earn \$50',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
