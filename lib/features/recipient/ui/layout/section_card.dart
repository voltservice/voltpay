import 'package:flutter/material.dart';

/// A soft card wrapper for logical sections (padding + rounded corners).
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 16),
    this.background,
  });

  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: background ?? scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.onSecondaryContainer),
        ),
      ),
      padding: padding,
      child: child,
    );
  }
}
