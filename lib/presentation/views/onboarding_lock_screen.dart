import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/router/app_routes.dart';
import 'package:voltpay/core/utils/buttons/app_buttons.dart';
import 'package:voltpay/presentation/widgets/onboarding_step_bar.dart';

class OnboardingLockScreen extends StatefulWidget {
  const OnboardingLockScreen({
    required this.onCheckRates,
    required this.onGetStarted,
    required this.totalSteps,
    required this.stepIndex,
    this.onAutoNext,
    this.isActive = false,
    this.autoAdvance = false,
    this.idleDuration = const Duration(seconds: 6),
    super.key,
  });

  final VoidCallback onCheckRates;
  final VoidCallback onGetStarted;
  final VoidCallback? onAutoNext;

  /// Progress bar config
  final int totalSteps;
  final int stepIndex;
  final bool isActive;
  final bool autoAdvance;

  /// Time to auto advance if the user is idle.
  final Duration idleDuration;

  @override
  State<OnboardingLockScreen> createState() => OnboardingLockScreenState();
}

class OnboardingLockScreenState extends State<OnboardingLockScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final AnimationController _enter; // image enter
  late final AnimationController _float; // image bob
  late final Animation<double> _fadeIn;
  late final Animation<double> _rise;
  late final Animation<double> _bob;

  late final AnimationController? _idle; // top bar + auto-advance
  VoidCallback? _autoNextCb;

  // Any user interaction resets the idle timer.
  void _resetIdle() {
    if (!mounted) {
      return;
    }
    final AnimationController? c = _idle;
    c
      ?..stop()
      ..reset()
      ..forward();
    _autoNextCb?.call();
  }

  @override
  void initState() {
    super.initState();

    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(parent: _enter, curve: Curves.easeOut);
    _rise = Tween<double>(
      begin: 20,
      end: 0,
    ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic));
    _bob = Tween<double>(
      begin: -4,
      end: 4,
    ).animate(CurvedAnimation(parent: _float, curve: Curves.easeInOut));

    _autoNextCb = widget.onAutoNext;

    _idle = AnimationController(vsync: this, duration: widget.idleDuration)
      ..addStatusListener((AnimationStatus s) {
        if (s == AnimationStatus.completed) {
          _autoNextCb?.call();
        }
      });

    // Start progress once mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) => _idle?.forward());
  }

  @override
  void dispose() {
    _enter.dispose();
    _float.dispose();
    _idle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _resetIdle,
      onPanDown: (_) => _resetIdle(),
      child: Scaffold(
        backgroundColor:
            scheme.onSurface, // keep parity with your previous screen
        body: SafeArea(
          child: Column(
            children: <Widget>[
              // Tiny progress bar with animated current segment
              AnimatedBuilder(
                animation: _idle!,
                builder: (_, _) => OnboardingStepBar(
                  total: widget.totalSteps,
                  current: widget.stepIndex,
                  progress: _idle.value,
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 8),

                          // 3D paper plane (use your asset path)
                          AnimatedBuilder(
                            animation: Listenable.merge(<Listenable?>[
                              _enter,
                              _float,
                            ]),
                            builder: (_, _) {
                              final double dy = _rise.value + _bob.value;
                              return Opacity(
                                opacity: _fadeIn.value,
                                child: Transform.translate(
                                  offset: Offset(0, dy),
                                  child: Hero(
                                    tag: 'lock-hero',
                                    child: Image.asset(
                                      'assets/images/voltpay_lock.png',
                                      height: size.height * 0.36,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          // Title
                          Text(
                            'SECURITY THAT DISAPPOINTS\nTHIEVES.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: scheme.surface,
                              fontSize: 32,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              fontFamily: 'Poppins',
                              wordSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Spacer(),
                          AppButton(
                            text: 'Get started',
                            customForegroundColor: scheme.onPrimary,
                            customBackgroundColor: scheme.primary,
                            type: ButtonType.primary,
                            size: ButtonSize.large,
                            isRounded: true,
                            isFullWidth: true,
                            onPressed: () {
                              _resetIdle();
                              context.goNamed(AppRoute.obnlastpg.name);
                            },
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
