import 'package:flutter/material.dart';
import 'package:with_opacity/with_opacity.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.scheme,
    this.dark = false,
  });

  final String title;
  final String subtitle;
  final Widget leading;
  final ColorScheme scheme;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color bg = dark ? scheme.secondaryContainer : scheme.onSurfaceVariant;
    final Color fg = dark ? scheme.onSecondaryContainer : scheme.surface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: fg.withCustomOpacity(.8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
