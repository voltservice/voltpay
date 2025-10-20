import 'package:flutter/material.dart';

class Divider extends StatelessWidget {
  const Divider();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
      margin: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}
