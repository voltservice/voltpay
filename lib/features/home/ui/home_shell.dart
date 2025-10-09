import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/features/home/ui/cards_screen.dart';
import 'package:voltpay/features/home/ui/home_screen.dart';
import 'package:voltpay/features/home/ui/payments_screen.dart';
import 'package:voltpay/features/home/ui/recipients_screen.dart';
import 'package:with_opacity/with_opacity.dart';

/// Root shell after authentication.
/// Contains the BottomNavBar and routes between Home, Cards, Recipients, and Payments.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    CardsScreen(),
    RecipientsScreen(),
    PaymentsScreen(),
  ];

  void _onTap(int newIndex) {
    setState(() => _index = newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_index],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          indicatorColor: scheme.primaryContainer.withCustomOpacity(.25),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: NavigationBar(
          selectedIndex: _index,
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
