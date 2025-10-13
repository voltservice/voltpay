import 'package:flutter/material.dart';

class FeeRow extends StatelessWidget {
  const FeeRow({
    required this.scheme,
    required this.bullet,
    required this.left,
    super.key,
    this.rightText,
    this.rightWidget,
    this.rightLinkText,
    this.onRightTap,
  });

  final ColorScheme scheme;
  final IconData bullet;
  final String left;
  final String? rightText;
  final Widget? rightWidget;
  final String? rightLinkText;
  final VoidCallback? onRightTap;

  @override
  Widget build(BuildContext context) {
    final Widget right =
        rightWidget ??
        (rightLinkText != null
            ? GestureDetector(
                onTap: onRightTap,
                child: Text(
                  rightLinkText!,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: scheme.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : Text(
                rightText ?? '',
                textAlign: TextAlign.right,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Icon(bullet, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            left,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
    );
  }
}
