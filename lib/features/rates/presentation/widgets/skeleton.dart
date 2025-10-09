import 'package:flutter/material.dart';

class Skeleton extends StatelessWidget {
  const Skeleton({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    Widget bar(double w) => Container(
          height: 16,
          width: w,
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: scheme.onSurfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        );
    return Column(
      children: <Widget>[
        bar(240),
        bar(260),
        bar(280),
        const SizedBox(height: 16),
        bar(220),
      ],
    );
  }
}
