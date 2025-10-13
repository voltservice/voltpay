import 'package:flutter/material.dart';
import 'package:with_opacity/with_opacity.dart';

class DiscoverCard extends StatelessWidget {
  const DiscoverCard({
    required this.title,
    required this.onTap,
    required this.onClose,
  });

  final String title;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 18),
                color: scheme.onSurface.withCustomOpacity(.7),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 24, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onPressed: onTap,
                    child: const Text('Learn more'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
