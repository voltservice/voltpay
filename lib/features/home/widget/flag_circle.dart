import 'package:flutter/material.dart';

class FlagCircle extends StatelessWidget {
  const FlagCircle({required this.codeEmoji});
  final String codeEmoji;

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
      child: Center(
        child: Text(codeEmoji, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
