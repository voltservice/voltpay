import 'package:flutter/material.dart';

class MethodLink extends StatelessWidget {
  const MethodLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: scheme.primary,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
