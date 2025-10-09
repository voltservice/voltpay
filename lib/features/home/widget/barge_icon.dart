import 'package:flutter/material.dart';

class BadgeIcon extends StatelessWidget {
  const BadgeIcon();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Icon(Icons.stars_rounded, color: scheme.primary),
    );
  }
}
