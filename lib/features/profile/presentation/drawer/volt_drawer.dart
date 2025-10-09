import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/features/profile/presentation/widget/chip.dart';
import 'package:voltpay/features/profile/presentation/widget/header.dart';
import 'package:voltpay/features/profile/presentation/widget/header_error.dart';
import 'package:voltpay/features/profile/presentation/widget/header_skeleton.dart';
import 'package:voltpay/features/profile/presentation/widget/tile.dart';
import 'package:voltpay/features/profile/provider/drawer_user_providers.dart';

class VoltDrawer extends ConsumerWidget {
  const VoltDrawer({
    required this.onClose,
    required this.onProfile,
    required this.onManageProviders,
    required this.onSettings,
    required this.onHelp,
    required this.onSignOut,
    super.key,
  });

  final VoidCallback onClose;
  final VoidCallback onProfile;
  final VoidCallback onManageProviders;
  final VoidCallback onSettings;
  final VoidCallback onHelp;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    final AsyncValue<DrawerUserUi> userAsync = ref.watch(drawerUserProvider);
    final List<LinkedProviderChip> providers = ref.watch(
      linkedProviderChipsProvider,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Menu',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_rounded),
                    color: scheme.onSurface,
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Header (avatar + name + email)
            userAsync.when(
              loading: () => HeaderSkeleton(scheme: scheme),
              error: (_, __) => HeaderError(onProfile: onProfile),
              data: (DrawerUserUi ui) => Header(
                name: ui.displayName,
                email: ui.email,
                photoUrl: ui.photoUrl,
                initials: ui.initials,
                onProfile: onProfile,
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),

            // Linked providers section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(
                children: <Widget>[
                  Text(
                    'Linked sign-in methods',
                    style: text.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onManageProviders,
                    child: const Text('Manage'),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: providers.map((LinkedProviderChip p) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: VoltChip(icon: p.icon, label: p.label),
                  );
                }).toList(growable: false),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),

            // Navigation list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: <Widget>[
                  Tile(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Tile(
                    icon: Icons.credit_card_outlined,
                    label: 'Cards',
                    onTap: onSettings, // wire to route
                  ),
                  Tile(
                    icon: Icons.people_outline,
                    label: 'Recipients',
                    onTap: onSettings, // wire to route
                  ),
                  Tile(
                    icon: Icons.payment_outlined,
                    label: 'Payments',
                    onTap: onSettings, // wire to route
                  ),
                  const SizedBox(height: 6),
                  Tile(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: onSettings,
                  ),
                  Tile(
                    icon: Icons.help_outline,
                    label: 'Help & support',
                    onTap: onHelp,
                  ),
                ],
              ),
            ),

            // Footer actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.error,
                    side: BorderSide(color: scheme.outlineVariant),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: onSignOut,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
