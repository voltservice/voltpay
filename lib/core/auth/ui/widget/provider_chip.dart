// Helper that gives each provider button a flexible width in the Wrap
import 'package:flutter/material.dart';

class ProviderChip extends StatelessWidget {
  const ProviderChip({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // min width ~ 110, max fills available row; prevents overflow on small phones
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 110, maxWidth: 180),
      child: child,
    );
  }
}
