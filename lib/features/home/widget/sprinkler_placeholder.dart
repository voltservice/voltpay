import 'package:flutter/material.dart';

class SparklinePlaceholder extends StatelessWidget {
  const SparklinePlaceholder({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Text(
        'rate trend',
        style: TextStyle(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
