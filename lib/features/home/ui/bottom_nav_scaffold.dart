// lib/features/home/ui/bottom_nav_scaffold.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:with_opacity/with_opacity.dart';

class BottomNavScaffold extends StatelessWidget {
  const BottomNavScaffold({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    // keeps tab state; if you tap the current tab, it pops to its root
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: navigationShell, // <- child route for the active branch
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          indicatorColor: scheme.primaryContainer.withCustomOpacity(.25),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onTap,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.credit_card_outlined),
              selectedIcon: Icon(Icons.credit_card_rounded),
              label: 'Cards',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Recipients',
            ),
            NavigationDestination(
              icon: Icon(Icons.payment_outlined),
              selectedIcon: Icon(Icons.payment_rounded),
              label: 'Payments',
            ),
          ],
        ),
      ),
    );
  }
}
