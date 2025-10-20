import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  const ErrorText({required this.error, required this.scheme});
  final String error;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'Failed to load quote: $error',
        style: TextStyle(color: scheme.error),
      ),
    );
  }
}
