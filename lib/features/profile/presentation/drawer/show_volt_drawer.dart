import 'package:flutter/material.dart';
import 'package:voltpay/features/profile/presentation/drawer/volt_drawer.dart';

Future<void> showVoltDrawer(
  BuildContext context, {
  required VoidCallback onProfile,
  required VoidCallback onManageProviders,
  required VoidCallback onSettings,
  required VoidCallback onHelp,
  required VoidCallback onSignOut,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      return FractionallySizedBox(
        heightFactor: 1, // full-screen
        child: Material(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          elevation: 2,
          child: VoltDrawer(
            onClose: () => Navigator.of(ctx).pop(),
            onProfile: onProfile,
            onManageProviders: onManageProviders,
            onSettings: onSettings,
            onHelp: onHelp,
            onSignOut: onSignOut,
          ),
        ),
      );
    },
  );
}
