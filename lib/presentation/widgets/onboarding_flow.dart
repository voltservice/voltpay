import 'package:flutter/material.dart';
import 'package:voltpay/presentation/views/onboarding_boost_screen.dart';
import 'package:voltpay/presentation/views/onboarding_initial_screen.dart';
import 'package:voltpay/presentation/views/onboarding_lock_screen.dart';
import 'package:voltpay/presentation/views/onboarding_login_or_register.dart';
import 'package:voltpay/presentation/views/onboarding_remit_screen.dart';
import 'package:voltpay/presentation/views/onboarding_send_n_earn_screen.dart';

// OnboardingFlow
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    required this.onCheckRates,
    required this.onFinished,
    required this.onGetStarted,
    this.idlePerScreen = const Duration(seconds: 6),
    super.key,
  });
  final VoidCallback onCheckRates;
  final VoidCallback onFinished;
  final VoidCallback onGetStarted;
  final Duration idlePerScreen;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pc = PageController();
  final ValueNotifier<int> _index = ValueNotifier<int>(0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/voltpay_jar.png'), context);
    precacheImage(const AssetImage('assets/images/voltpay_remit.png'), context);
    precacheImage(const AssetImage('assets/images/voltpay_send.png'), context);
    precacheImage(const AssetImage('assets/images/voltpay_graph.png'), context);
  }

  Future<void> _next() async {
    if (!mounted) {
      return;
    }
    final int total = _pageFactories.length;
    final int i = _index.value;
    if (i < total - 1) {
      await _pc.nextPage(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );
    } else {
      widget.onFinished();
    }
  }

  // Build pages via factories so totalSteps = factories.length (auto-increments).
  late final List<Widget Function(int total, int active)> _pageFactories =
      <Widget Function(int total, int active)>[
    (int total, int active) => OnboardingInitialScreen(
          totalSteps: total,
          stepIndex: 0,
          isActive: active == 0,
          // pause idle when not active
          autoAdvance: true,
          idleDuration: widget.idlePerScreen,
          onCheckRates: widget.onCheckRates,
          onGetStarted: _next,
          onAutoNext: _next,
        ),
    (int total, int active) => OnboardingRemitScreen(
          totalSteps: total,
          stepIndex: 1,
          isActive: active == 1,
          autoAdvance: true,
          idleDuration: widget.idlePerScreen,
          onCheckRates: widget.onCheckRates,
          onGetStarted: _next,
          onAutoNext: _next,
        ),
    (int total, int active) => OnboardingSendNEarnScreen(
          totalSteps: total,
          stepIndex: 2,
          isActive: active == 2,
          autoAdvance: true,
          idleDuration: widget.idlePerScreen,
          onCheckRates: widget.onCheckRates,
          onGetStarted: _next,
          onAutoNext: _next,
        ),
    (int total, int active) => OnboardingBoostScreen(
          totalSteps: total,
          stepIndex: 3,
          isActive: active == 3,
          autoAdvance: false,
          // last screen: NO auto
          idleDuration: widget.idlePerScreen,
          onCheckRates: widget.onCheckRates,
          onGetStarted: widget.onFinished,
          onAutoNext: _next,
        ),
    (int total, int active) => OnboardingLockScreen(
          totalSteps: total,
          stepIndex: 4,
          isActive: active == 4,
          autoAdvance: false,
          idleDuration: widget.idlePerScreen,
          onCheckRates: widget.onCheckRates,
          onGetStarted: widget.onFinished,
          onAutoNext: _next,
          // last screen: NO auto
        ),
    (int total, int active) => OnboardingLoginOrRegister(
          totalSteps: total,
          stepIndex: 5,
          isActive: active == 5,
          autoAdvance: false,
          idleDuration: widget.idlePerScreen,
          onCheckRates: widget.onCheckRates,
          onGetStarted: widget.onGetStarted,
          onAutoNext: null,
          // last screen: NO auto
        ),
  ];

  @override
  void dispose() {
    _pc.dispose();
    _index.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _index,
      builder: (BuildContext context, int idx, _) {
        final int total = _pageFactories.length;
        final List<Widget> pages = List<Widget>.generate(
          total,
          (int i) => _pageFactories[i](total, idx),
        );

        return PopScope(
          canPop: idx == 0,
          onPopInvokedWithResult: (bool didPop, _) async {
            // Made synchronous
            if (didPop) {
              return;
            }
            if (_index.value > 0) {
              await _pc.previousPage(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOut,
              );
            }
          },
          child: PageView(
            controller: _pc,
            onPageChanged: (int i) => _index.value = i,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            children: pages,
          ),
        );
      },
    );
  }
}
