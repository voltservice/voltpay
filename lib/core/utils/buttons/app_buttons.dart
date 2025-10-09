import 'package:flutter/material.dart';
import 'package:with_opacity/with_opacity.dart';

enum ButtonType { primary, secondary, tertiary, outline, fill }

enum ButtonSize { extraSmall, small, medium, large, extraLarge }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool underline;
  final bool iconRight;
  final bool isLoading;
  final bool isOutlined; // kept for backward-compat; type=outline preferred
  final bool isRounded;
  final bool isFullWidth;
  final bool isDisabled;
  final ButtonType type;
  final ButtonSize size;
  final Color? customBackgroundColor;
  final Color? customForegroundColor;
  final Color? customBorderColor;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final double? customWidth;

  const AppButton({
    required this.text,
    super.key,
    this.onPressed,
    this.icon,
    this.underline = false,
    this.iconRight = false,
    this.isLoading = false,
    this.isOutlined = false,
    this.isRounded = false,
    this.isFullWidth = false,
    this.isDisabled = false,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.customBackgroundColor,
    this.customForegroundColor,
    this.customBorderColor,
    this.padding,
    this.gradient,
    this.customWidth,
  });

  double get _height => switch (size) {
        ButtonSize.extraSmall => 28,
        ButtonSize.small => 36,
        ButtonSize.medium => 44,
        ButtonSize.large => 52,
        ButtonSize.extraLarge => 60,
      };

  TextStyle _textStyle(BuildContext ctx) {
    final TextTheme text = Theme.of(ctx).textTheme;
    final TextStyle base = switch (size) {
      ButtonSize.extraSmall => text.labelSmall,
      ButtonSize.small => text.labelMedium,
      ButtonSize.medium => text.labelLarge,
      ButtonSize.large => text.titleSmall,
      ButtonSize.extraLarge => text.titleMedium,
    }!;
    return base.copyWith(
      color: _fg(ctx, const <WidgetState>{}),
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
    );
  }

  // --- Color helpers (theme-first) -----------------------------------------

  Color _fg(BuildContext ctx, Set<WidgetState> states) {
    if (customForegroundColor != null) {
      return customForegroundColor!;
    }
    final ColorScheme s = Theme.of(ctx).colorScheme;
    final Color disabled = s.onSurface.withCustomOpacity(0.38);

    if (states.contains(WidgetState.disabled)) {
      return disabled;
    }

    return switch (type) {
      ButtonType.primary => s.onPrimary,
      ButtonType.secondary => s.onSecondaryContainer,
      ButtonType.tertiary => s.primary, // text color
      ButtonType.outline => s.primary,
      ButtonType.fill => s.onPrimary,
    };
  }

  Color _bg(BuildContext ctx, Set<WidgetState> states) {
    if (gradient != null) {
      return Colors.transparent;
    }
    if (isOutlined || type == ButtonType.outline) {
      return Colors.transparent;
    }
    if (customBackgroundColor != null) {
      return customBackgroundColor!;
    }

    final ColorScheme s = Theme.of(ctx).colorScheme;
    final Color disabled = s.onSurface.withCustomOpacity(0.12);

    if (states.contains(WidgetState.disabled)) {
      return disabled;
    }

    Color base = switch (type) {
      ButtonType.primary => s.primary,
      ButtonType.secondary => s.secondaryContainer, // tonal filled
      ButtonType.tertiary => Colors.transparent, // text button
      ButtonType.outline => Colors.transparent,
      ButtonType.fill => Colors.transparent,
    };

    if (states.contains(WidgetState.pressed)) {
      base = _tint(base, -0.08);
    } else if (states.contains(WidgetState.hovered)) {
      base = _tint(base, -0.04);
    }
    return base;
  }

  BorderSide? _border(BuildContext ctx, Set<WidgetState> states) {
    final ColorScheme s = Theme.of(ctx).colorScheme;
    if (isOutlined || type == ButtonType.outline) {
      final Color c = states.contains(WidgetState.disabled)
          ? s.onSurface.withCustomOpacity(0.12)
          : s.outline;
      return BorderSide(color: c, width: 1);
    }
    return null;
  }

  // small util to darken/lighten
  Color _tint(Color c, double amount) {
    final HSLColor hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(isRounded ? 100 : 12);
    final EdgeInsetsGeometry resolvedPadding = padding ??
        switch (size) {
          ButtonSize.extraSmall => const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
          ButtonSize.small => const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ButtonSize.medium => const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ButtonSize.large => const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ButtonSize.extraLarge => const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 18,
            ),
        };

    final WidgetStateProperty<Color?> bg = WidgetStateProperty.resolveWith(
      (Set<WidgetState> s) => _bg(context, s),
    );
    final WidgetStateProperty<Color?> fg = WidgetStateProperty.resolveWith(
      (Set<WidgetState> s) => _fg(context, s),
    );
    final WidgetStateProperty<BorderSide?> side =
        WidgetStateProperty.resolveWith(
      (Set<WidgetState> s) => _border(context, s),
    );
    final WidgetStateProperty<OutlinedBorder?> shape = WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: radius),
    );
    final WidgetStateProperty<TextStyle?> textStyle = WidgetStateProperty.all(
      _textStyle(context),
    );
    final WidgetStateProperty<EdgeInsetsGeometry?> pad =
        WidgetStateProperty.all(resolvedPadding);
    final WidgetStateProperty<Size?> minSize = WidgetStateProperty.all(
      Size.fromHeight(_height),
    );

    final ButtonStyle style = ButtonStyle(
      backgroundColor: bg,
      foregroundColor: fg,
      side: side,
      shape: shape,
      textStyle: textStyle,
      padding: pad,
      minimumSize: minSize,
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      overlayColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> s) =>
            Theme.of(context).colorScheme.primary.withCustomOpacity(
                  s.contains(WidgetState.pressed)
                      ? 0.08
                      : s.contains(WidgetState.hovered)
                          ? 0.04
                          : 0.0,
                ),
      ),
    );

    final bool disabledByState = isLoading || isDisabled;
    final VoidCallback? safeOnPressed = disabledByState ? null : onPressed;

    final Widget label = Flexible(
      child: Text(text, overflow: TextOverflow.ellipsis, softWrap: false),
    );

    final List<Widget> row = icon == null
        ? <Widget>[label]
        : iconRight
            ? <Widget>[label, const SizedBox(width: 8), icon!]
            : <Widget>[icon!, const SizedBox(width: 8), label];

    final Widget child = isLoading
        ? SizedBox(
            height: _height - 16,
            width: _height - 16,
            child: const CircularProgressIndicator(strokeWidth: 2.8),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: row,
          );

    final ButtonStyleButton button = switch (type) {
      ButtonType.primary => ElevatedButton(
          onPressed: safeOnPressed,
          style: style,
          child: child,
        ),
      ButtonType.secondary => FilledButton(
          onPressed: safeOnPressed,
          style: style,
          child: child,
        ),
      ButtonType.tertiary => TextButton(
          onPressed: safeOnPressed,
          style: style,
          child: child,
        ),
      ButtonType.outline => OutlinedButton(
          onPressed: safeOnPressed,
          style: style,
          child: child,
        ),
      ButtonType.fill => FilledButton.tonal(
          onPressed: safeOnPressed,
          style: style,
          child: child,
        ),
    };

    final Widget core = SizedBox(
      width: isFullWidth ? double.infinity : customWidth,
      height: _height,
      child: button,
    );

    if (gradient != null) {
      return Container(
        decoration: BoxDecoration(gradient: gradient, borderRadius: radius),
        child: ClipRRect(borderRadius: radius, child: core),
      );
    }
    return core;
  }
}
