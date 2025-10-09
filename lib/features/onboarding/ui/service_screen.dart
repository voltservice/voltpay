import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/features/onboarding/provider/account_type_provider.dart';
import 'package:voltpay/features/onboarding/ui/account_type_card.dart';
import 'package:with_opacity/with_opacity.dart';

/// Post-verification landing screen (no “home” yet).
/// - Shows two choices: Personal / Business
/// - Emits callbacks for navigation to respective KYC flows
/// - Optionally shows the signed-in email/provider via [userLabel]
class ServiceScreen extends ConsumerWidget {
  const ServiceScreen({
    required this.onClose,
    required this.onPersonalKyc,
    required this.onBusinessKyc,
    super.key,
    this.userLabel, // e.g. "finaluser@gmail.com • Google"
  });

  final VoidCallback onClose;
  final VoidCallback onPersonalKyc;
  final VoidCallback onBusinessKyc;
  final String? userLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

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
                      icon: const Icon(Icons.close_rounded),
                      color: scheme.onSurface,
                      tooltip: 'Close',
                      onPressed: onClose,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Headline
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'What kind of account would you like to open today?',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.2,
                              ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'You can add another account later on, too',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withCustomOpacity(.75),
                          ),
                    ),
                  ),

                  if (userLabel != null) ...<Widget>[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        userLabel!,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  AccountTypeCard(
                    icon: Icons.person_2_outlined,
                    title: 'Personal account',
                    subtitle:
                        'Spend, send, and receive money around the world for less and secure.',
                    onTap: () {
                      ref
                          .read(accountTypeProvider.notifier)
                          .choose(AccountType.personal);
                      onPersonalKyc();
                    },
                  ),
                  const SizedBox(height: 12),
                  AccountTypeCard(
                    icon: Icons.account_balance_outlined,
                    title: 'Business account',
                    subtitle: 'Do business or freelance work intentionally.',
                    onTap: () {
                      ref
                          .read(accountTypeProvider.notifier)
                          .choose(AccountType.business);
                      onBusinessKyc();
                    },
                  ),

                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'You must use Voltpay in line with our Acceptable Use Policy. '
                      'You cannot use a personal account for business.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withCustomOpacity(.6),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
