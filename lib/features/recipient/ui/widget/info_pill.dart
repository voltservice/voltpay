import 'package:flutter/material.dart';

class InfoPill extends StatelessWidget {
  const InfoPill({
    required this.text,
    super.key,
    this.icon,
    this.background,
    this.fg,
  });

  final String text;
  final IconData? icon;
  final Color? background;
  final Color? fg;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: ShapeDecoration(
        color: background ?? scheme.onSurfaceVariant,
        shape: const StadiumBorder(),
        shadows: <BoxShadow>[
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 18, color: fg ?? scheme.onSurface),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg ?? scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
