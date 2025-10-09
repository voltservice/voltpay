import 'package:flutter/material.dart';
import 'package:voltpay/features/profile/presentation/widget/avatar.dart';
import 'package:with_opacity/with_opacity.dart';

class Header extends StatelessWidget {
  const Header({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.initials,
    required this.onProfile,
  });

  final String name;
  final String email;
  final String? photoUrl;
  final String initials;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: <Widget>[
          Avatar(photoUrl: photoUrl, initials: initials),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (email.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurface.withCustomOpacity(.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(onPressed: onProfile, child: const Text('View profile')),
        ],
      ),
    );
  }
}
