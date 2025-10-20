import 'package:flutter/material.dart';
import 'package:with_opacity/with_opacity.dart';

class ChangeChip extends StatelessWidget {
  const ChangeChip({required this.onTap, super.key, this.gradient});

  final VoidCallback onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        constraints: const BoxConstraints(minHeight: 28),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          gradient:
              gradient ??
              LinearGradient(
                colors: <Color>[
                  scheme.primary.withCustomOpacity(0.18),
                  scheme.primary.withCustomOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        ),
        alignment: Alignment.center,
        child: Text(
          'Change',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: scheme.primary,
          ),
        ),
      ),
    );
  }
}
