import 'package:flutter/material.dart';

class HeaderError extends StatelessWidget {
  const HeaderError({required this.onProfile});
  final VoidCallback onProfile;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.error_outline),
      title: const Text('Failed to load profile'),
      trailing: TextButton(onPressed: onProfile, child: const Text('Retry')),
    );
  }
}
