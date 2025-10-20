import 'package:flutter/material.dart';

/// Centers content and constrains it to a max width (like a container on web).
class CenterWidth extends StatelessWidget {
  const CenterWidth({required this.child, super.key, this.maxWidth = 720});

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
