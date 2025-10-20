import 'package:flutter/material.dart';

class DividerLine extends StatelessWidget {
  const DividerLine();

  @override
  Widget build(BuildContext context) {
    final Color c = Theme.of(context).colorScheme.outlineVariant;
    return Container(
      height: 1,
      color: c,
      margin: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}
