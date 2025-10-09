import 'package:flutter/material.dart';
import 'package:voltpay/core/auth/ui/login_providers_style.dart';
import 'package:voltpay/core/utils/buttons/app_buttons.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    required this.provider,
    super.key,
    this.onPressed,
    this.size = ButtonSize.small,
    this.enabled = true,
    this.isLoading = false,
    this.loadingColor, // optional override
  });

  final LoginProviders provider;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final bool enabled;
  final bool isLoading;
  final Color? loadingColor;

  @override
  Widget build(BuildContext context) {
    final LoginProviderPolicy policy = LoginProviderPolicy.of(provider);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Brightness brightness = Theme.of(context).brightness;
    final ButtonColors colors = policy.resolve(scheme, brightness);

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
            colorBlendMode:
                policy.tintIcon ? BlendMode.srcIn : BlendMode.srcOver,
          );

    // Choose AppButton type based on whether we have a border
    final ButtonType type =
        (colors.border != null) ? ButtonType.outline : ButtonType.primary;

    return AppButton(
      text: isLoading ? policy.loadingLabel : policy.label,
      icon: icon,
      onPressed: (enabled && !isLoading) ? onPressed : null,
      isLoading: isLoading,
      size: size,
      type: type,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      customBackgroundColor: colors.background,
      customForegroundColor: colors.foreground,
      customBorderColor: colors.border,
    );
  }
}
