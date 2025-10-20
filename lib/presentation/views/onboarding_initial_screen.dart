// // lib/features/onboarding/screens/onboarding_initial_screen.dart
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:voltpay/core/router/app_routes.dart';
// import 'package:voltpay/core/utils/buttons/app_buttons.dart';
// import 'package:voltpay/presentation/widgets/onboarding_step_bar.dart';
//
// class OnboardingInitialScreen extends StatefulWidget {
//   const OnboardingInitialScreen({
//     required this.onCheckRates,
//     required this.onGetStarted,
//     required this.onAutoNext,
//     required this.totalSteps,
//     required this.stepIndex,
//     this.isActive = false,
//     this.autoAdvance = false,
//     this.idleDuration = const Duration(seconds: 6),
//     super.key,
//   });
//
//   final VoidCallback onCheckRates;
//   final VoidCallback onGetStarted;
//   final bool isActive;
//   final bool autoAdvance;
//   final VoidCallback onAutoNext;
//
//   final int totalSteps;
//   final int stepIndex;
//   final Duration idleDuration;
//
//   @override
//   State<OnboardingInitialScreen> createState() =>
//       _OnboardingInitialScreenState();
// }
//
// class _OnboardingInitialScreenState extends State<OnboardingInitialScreen>
//     with TickerProviderStateMixin {
//   late final AnimationController _enter;
//   late final AnimationController _float;
//   late final Animation<double> _fadeIn;
//   late final Animation<double> _rise;
//   late final Animation<double> _bob;
//
//   late final AnimationController _idle;
//
//   void _resetIdle() {
//     if (!mounted) {
//       return;
//     }
//     _idle
//       ..stop()
//       ..reset()
//       ..forward();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _enter = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     )..forward();
//     _float = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2400),
//     )..repeat(reverse: true);
//
//     _fadeIn = CurvedAnimation(parent: _enter, curve: Curves.easeOut);
//     _rise = Tween<double>(
//       begin: 20,
//       end: 0,
//     ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic));
//     _bob = Tween<double>(
//       begin: -4,
//       end: 4,
//     ).animate(CurvedAnimation(parent: _float, curve: Curves.easeInOut));
//
//     _idle = AnimationController(vsync: this, duration: widget.idleDuration)
//       ..addStatusListener((AnimationStatus s) {
//         if (s == AnimationStatus.completed) {
//           widget.onAutoNext();
//         }
//       });
//
//     WidgetsBinding.instance.addPostFrameCallback((_) => _idle.forward());
//   }
//
//   @override
//   void dispose() {
//     _enter.dispose();
//     _float.dispose();
//     _idle.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final ColorScheme scheme = Theme.of(context).colorScheme;
//     final Size size = MediaQuery.of(context).size;
//
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: _resetIdle,
//       onPanDown: (_) => _resetIdle(),
//       child: Scaffold(
//         backgroundColor: scheme.onSurface,
//         body: SafeArea(
//           child: Column(
//             children: <Widget>[
//               AnimatedBuilder(
//                 animation: _idle,
//                 builder: (_, _) => OnboardingStepBar(
//                   total: widget.totalSteps,
//                   current: widget.stepIndex,
//                   progress: _idle.value,
//                 ),
//               ),
//               Expanded(
//                 child: Center(
//                   child: ConstrainedBox(
//                     constraints: const BoxConstraints(maxWidth: 430),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Column(
//                         children: <Widget>[
//                           const SizedBox(height: 24),
//                           AnimatedBuilder(
//                             animation: Listenable.merge(<Listenable?>[
//                               _enter,
//                               _float,
//                             ]),
//                             builder: (_, _) {
//                               final double dy = _rise.value + _bob.value;
//                               return Opacity(
//                                 opacity: _fadeIn.value,
//                                 child: Transform.translate(
//                                   offset: Offset(0, dy),
//                                   child: Hero(
//                                     tag: 'pots-hero',
//                                     child: Image.asset(
//                                       'assets/images/voltpay_jar.png',
//                                       height: size.height * 0.26,
//                                       fit: BoxFit.contain,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                           const SizedBox(height: 32),
//                           Text(
//                             'SEND AND RECEIVE IN 40+ CURRENCIES\nACROSS 160 COUNTRIES WITH\n ONE VOLTPAY ACCOUNT',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: scheme.surface,
//                               fontSize: 32,
//                               height: 1.15,
//                               fontWeight: FontWeight.w800,
//                               letterSpacing: -0.2,
//                               fontFamily: 'Poppins',
//                               wordSpacing: 0.5,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           AppButton(
//                             text: 'Check our rates',
//                             type: ButtonType.tertiary,
//                             size: ButtonSize.medium,
//                             underline: true,
//                             customForegroundColor: scheme.primary,
//                             onPressed: () {
//                               _resetIdle();
//                               widget.onCheckRates();
//                             },
//                           ),
//                           const Spacer(),
//                           AppButton(
//                             text: 'Get started',
//                             customForegroundColor: scheme.onPrimary,
//                             customBackgroundColor: scheme.primary,
//                             type: ButtonType.primary,
//                             size: ButtonSize.large,
//                             isRounded: true,
//                             isFullWidth: true,
//                             onPressed: () {
//                               _resetIdle();
//                               context.goNamed(AppRoute.obnlastpg.name);
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/features/onboarding/screens/onboarding_initial_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/router/app_routes.dart';
import 'package:voltpay/core/utils/buttons/app_buttons.dart';
import 'package:voltpay/presentation/widgets/onboarding_step_bar.dart';

class OnboardingInitialScreen extends StatefulWidget {
  const OnboardingInitialScreen({
    required this.onCheckRates,
    required this.onGetStarted,
    required this.onAutoNext,
    required this.totalSteps,
    required this.stepIndex,
    this.isActive = false,
    this.autoAdvance = false,
    this.idleDuration = const Duration(seconds: 6),
    super.key,
  });

  final VoidCallback onCheckRates;
  final VoidCallback onGetStarted;
  final bool isActive;
  final bool autoAdvance;
  final VoidCallback onAutoNext;

  final int totalSteps;
  final int stepIndex;
  final Duration idleDuration;

  @override
  State<OnboardingInitialScreen> createState() =>
      _OnboardingInitialScreenState();
}

class _OnboardingInitialScreenState extends State<OnboardingInitialScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _float;
  late final Animation<double> _fadeIn;
  late final Animation<double> _rise;
  late final Animation<double> _bob;

  late final AnimationController _idle;

  void _resetIdle() {
    if (!mounted) {
      return;
    }
    _idle
      ..stop()
      ..reset()
      ..forward();
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

    _idle = AnimationController(vsync: this, duration: widget.idleDuration)
      ..addStatusListener((AnimationStatus s) {
        if (s == AnimationStatus.completed) {
          widget.onAutoNext();
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) => _idle.forward());
  }

  @override
  void dispose() {
    _enter.dispose();
    _float.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Size size = MediaQuery.of(context).size;
    final double h = size.height;
    final bool compact = h < 720; // trims spacers/fonts on small screens

    // Responsive sizing
    const double heroMax = 260;
    const double heroMin = 140;
    final double heroHeight = (size.height * 0.26).clamp(heroMin, heroMax);

    const double titleBase = 32;
    final double titleByWidth = (size.width * 0.075); // ~30 at 400px
    final double titleFont = titleByWidth.clamp(20, titleBase);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _resetIdle,
      onPanDown: (_) => _resetIdle(),
      child: Scaffold(
        backgroundColor: scheme.onSurface,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              AnimatedBuilder(
                animation: _idle,
                builder: (_, _) => OnboardingStepBar(
                  total: widget.totalSteps,
                  current: widget.stepIndex,
                  progress: _idle.value,
                ),
              ),

              // Scrollable content to eliminate pixel overflow on short screens
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: compact ? 12 : 20,
                            // keep content above keyboard and avoid bottom overflow
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom +
                                (compact ? 16 : 24),
                          ),
                          child: ConstrainedBox(
                            // ensure content can fill the viewport (for nice centering)
                            constraints: BoxConstraints(
                              minHeight:
                                  constraints.maxHeight - (compact ? 12 : 20),
                            ),
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: compact ? 12 : 24),

                                // Hero image with gentle float
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
                                          tag: 'pots-hero',
                                          child: Image.asset(
                                            'assets/images/voltpay_jar.png',
                                            height: heroHeight,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(height: compact ? 20 : 32),

                                // Headline – responsive, wraps safely
                                Text(
                                  'SEND AND RECEIVE IN 40+ CURRENCIES\nACROSS 160 COUNTRIES WITH\n ONE VOLTPAY ACCOUNT',
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  maxLines: 6,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    color: scheme.surface,
                                    fontSize: titleFont,
                                    height: 1.15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                    fontFamily: 'Poppins',
                                    wordSpacing: 0.5,
                                  ),
                                ),

                                SizedBox(height: compact ? 12 : 16),

                                AppButton(
                                  text: 'Check our rates',
                                  type: ButtonType.tertiary,
                                  size: ButtonSize.medium,
                                  underline: true,
                                  customForegroundColor: scheme.primary,
                                  onPressed: () {
                                    _resetIdle();
                                    widget.onCheckRates();
                                  },
                                ),

                                // Spacer is okay inside Column; with scroll view we won’t overflow
                                SizedBox(height: compact ? 24 : 40),

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
                              ],
                            ),
                          ),
                        );
                      },
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
