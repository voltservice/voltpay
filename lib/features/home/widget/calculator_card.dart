import 'package:flutter/material.dart';
import 'package:with_opacity/with_opacity.dart';

class CalculatorCard extends StatelessWidget {
  const CalculatorCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.onSurface.withCustomOpacity(.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
