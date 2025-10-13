import 'package:flutter/material.dart';
import 'package:voltpay/core/auth/ui/login_providers_style.dart';
import 'package:voltpay/core/utils/buttons/app_buttons.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    required this.provider,
    super.key,
    this.onPressed,
    this.size = ButtonSize.small,
    this.type = ButtonType.outline,
    this.enabled = true,
    this.isLoading = false,
    this.showLabel = true,
    this.loadingColor, // optional override
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.loadingLabelOverride,
  });

  final LoginProviders provider;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final ButtonType type;
  final bool enabled;
  final bool isLoading;
  final bool showLabel;
  final Color? loadingColor;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final String? loadingLabelOverride;

  @override
  Widget build(BuildContext context) {
    final LoginProviderPolicy policy = LoginProviderPolicy.of(provider);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Brightness brightness = Theme.of(context).brightness;
    final ButtonColors colors = policy.resolve(scheme, brightness, policy);

    final Widget icon = isLoading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                loadingColor ?? colors.foreground,
              ),
            ),
          )
        : Image.asset(
            policy.iconAsset,
            height: 20,
            width: 20,
            fit: BoxFit.contain,
            color: policy.tintIcon ? colors.foreground : null,
            colorBlendMode: policy.tintIcon
                ? BlendMode.srcIn
                : BlendMode.srcOver,
          );

    // Choose AppButton type based on whether we have a border
    final bool _ = colors.border != null;

    return AppButton(
      text: showLabel ? (isLoading ? policy.loadingLabel : policy.label) : '',
      icon: icon,
      onPressed: (enabled && !isLoading) ? onPressed : null,
      isLoading: isLoading,
      size: size,
      type: type,
      customBackgroundColor: policy.backgroundColor,
      customForegroundColor: policy.foregroundColor,
      customBorderColor: colors.border,
      padding: showLabel
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
          : const EdgeInsets.all(12), // tighter when icon-only
      spacing: showLabel ? 8 : 0, // no gap if no label
      centerIconOnly: !showLabel,
    );
  }
}
