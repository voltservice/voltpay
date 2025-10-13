import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voltpay/core/auth/provider/email_verification_state.dart';
import 'package:voltpay/core/router/app_routes.dart';
import 'package:voltpay/core/utils/buttons/app_buttons.dart';
import 'package:with_opacity/with_opacity.dart';

class EmailVerificationPendingScreen extends ConsumerWidget {
  const EmailVerificationPendingScreen({
    required this.email,
    required this.onResend,
    required this.onClose,
    super.key,
    // trigger your resend flow outside this widget
    this.onApproved, // e.g. navigate once user taps "I've approved"
    this.initialCountdown = 120, // seconds (matches your mock mm:ss)
    this.heroAsset = 'assets/images/voltpay_email_pending.png',
  });

  final String email;
  final VoidCallback onClose;
  final Future<void> Function(String email) onResend;
  final VoidCallback? onApproved;
  final int initialCountdown;
  final String heroAsset;

  Future<void> _openMailApp() async {
    // Best-effort: opens composer, which usually foregrounds the mail app.
    final Uri u = Uri(scheme: 'mailto', path: '');
    await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final EmailVerificationState state = ref.watch(
      emailVerificationProvider(
        email: email,
        initialCountdown: initialCountdown,
      ),
    );
    final EmailVerificationNotifier notifier = ref.read(
      emailVerificationProvider(
        email: email,
        initialCountdown: initialCountdown,
      ).notifier,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close_rounded),
                      color: scheme.onSurface,
                      onPressed: () => context.goNamed(AppRoute.obnlastpg.name),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Hero image
                  Image.asset(heroAsset, height: 160, fit: BoxFit.contain),

                  const SizedBox(height: 18),

                  // Title
                  Text(
                    'CHECK YOUR\nEMAIL',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Helper text
                  Text(
                    'Follow the link in the email we sent to\n${state.email}. '
                    'The email can take up to 1 minute to arrive.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withCustomOpacity(0.75),
                      height: 1.4,
                    ),
                  ),

                  const Spacer(),

                  // Open email app
                  AppButton(
                    text: 'Open email to approve',
                    isFullWidth: true,
                    isRounded: true,
                    size: ButtonSize.large,
                    type: ButtonType.primary,
                    customBackgroundColor: scheme.primary,
                    customForegroundColor: scheme.onPrimary,
                    onPressed: () async {
                      await _openMailApp();
                      onApproved?.call();
                    },
                  ),

                  const SizedBox(height: 12),

                  // Resend with countdown
                  AppButton(
                    text: state.canResend
                        ? 'Resend email'
                        : 'Resend email ${state.mmSs}',
                    isFullWidth: true,
                    isRounded: true,
                    size: ButtonSize.large,
                    type: ButtonType.fill,
                    customBackgroundColor: Colors.blueGrey.withCustomOpacity(
                      0.14,
                    ),
                    customForegroundColor: scheme.primary,
                    onPressed: state.canResend
                        ? () async {
                            await onResend(state.email);
                            notifier.restartCountdown(
                              seconds: initialCountdown,
                            );
                          }
                        : null,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
