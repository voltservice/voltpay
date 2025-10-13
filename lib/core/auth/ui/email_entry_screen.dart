import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/auth/provider/email_form_state.dart';
import 'package:voltpay/core/auth/ui/widget/terms_and_privacy_text.dart';
import 'package:voltpay/core/router/app_routes.dart';
import 'package:voltpay/core/utils/buttons/app_buttons.dart';
import 'package:with_opacity/with_opacity.dart';

/// A clean, theme-adaptive email capture screen.
/// - No auth logic
/// - Emits [onNext] with a validated email
class EmailEntryScreen extends ConsumerWidget {
  const EmailEntryScreen({
    required this.onClose,
    required this.onNext,
    super.key,
    this.title = 'Enter your email address',
    this.label = 'Your email',
  });

  final VoidCallback onClose;
  final ValueChanged<String> onNext;
  final String title;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final EmailFormState form = ref.watch(emailFormProvider);
    final bool showError = form.isDirty && !form.isValid;

    return Scaffold(
      // Keep background adaptive to theme
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  // Close row
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: scheme.onSurface,
                      tooltip: 'Close',
                      onPressed: () => context.goNamed(AppRoute.obnlastpg.name),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: scheme.onSurface.withCustomOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // TextField
                  TextField(
                    key: const Key('email_entry_field'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const <String>[AutofillHints.email],
                    enableSuggestions: true,
                    onChanged: ref.read(emailFormProvider.notifier).setEmail,
                    decoration: InputDecoration(
                      hintText: 'name@example.com',
                      errorText:
                          showError ? 'Enter a valid email address' : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: scheme.primary,
                          width: 1.9,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),

                  const Spacer(),

                  const TermsAndPrivacyText(),
                  const SizedBox(height: 16),

                  // Next button (disabled until email valid)
                  AppButton(
                    key: const Key('email_next_button'),
                    text: 'Next',
                    isFullWidth: true,
                    isRounded: true,
                    size: ButtonSize.large,
                    type: ButtonType.primary,
                    customBackgroundColor: form.canSubmit
                        ? scheme.primary
                        : scheme.primary.withCustomOpacity(0.5),
                    customForegroundColor: scheme.onPrimary,
                    onPressed: form.canSubmit
                        ? () => onNext(ref.read(emailFormProvider).email.trim())
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
