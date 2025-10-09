import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({required this.initials, this.photoUrl});
  final String? photoUrl;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.onSurfaceVariant,
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: (photoUrl != null && photoUrl!.isNotEmpty)
          ? Image.network(photoUrl!, fit: BoxFit.cover)
          : Center(
              child: Text(
                initials,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
    );
  }
}
