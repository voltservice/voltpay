import 'package:flutter/material.dart';

class VoltIcon extends StatelessWidget {
  const VoltIcon();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        'V',
        style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.w900),
      ),
    );
  }
}
