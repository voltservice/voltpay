import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/auth/provider/auth_provider.dart';
import 'package:voltpay/core/auth/provider/google_sign_in_provider.dart'
    hide SignInAborted;
import 'package:voltpay/core/auth/service/auth_service.dart';
import 'package:voltpay/core/auth/ui/login_button.dart';
import 'package:voltpay/core/auth/ui/login_providers_style.dart';
import 'package:voltpay/core/router/app_routes.dart';
import 'package:voltpay/core/utils/buttons/app_buttons.dart';
import 'package:voltpay/presentation/widgets/onboarding_step_bar.dart';

class OnboardingLoginOrRegister extends ConsumerStatefulWidget {
  const OnboardingLoginOrRegister({
    // existing callbacks kept
    required this.onCheckRates,
    required this.onGetStarted,
    required this.totalSteps,
    required this.stepIndex,
    this.onAutoNext,
    this.isActive = false,
    this.autoAdvance = false,
    this.idleDuration = const Duration(seconds: 6),

    // NEW: explicit hooks; if null we fall back to onGetStarted
    this.onLogin,
    this.onRegister,
    this.onGoogleSignIn,
    super.key,
  });

  final VoidCallback onCheckRates;
  final VoidCallback onGetStarted;
  final VoidCallback? onAutoNext;

  // optional explicit callbacks for this screen
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;
  final VoidCallback? onGoogleSignIn;

  /// Progress bar config
  final int totalSteps;
  final int stepIndex;
  final bool isActive;
  final bool autoAdvance;

  /// Time to auto advance if the user is idle.
  final Duration idleDuration;

  @override
  ConsumerState<OnboardingLoginOrRegister> createState() =>
      OnboardingLoginOrRegisterState();
}

class OnboardingLoginOrRegisterState
    extends ConsumerState<OnboardingLoginOrRegister>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final AnimationController _enter;
  late final AnimationController _float;
  late final Animation<double> _fadeIn;
  late final Animation<double> _rise;
  late final Animation<double> _bob;

  AnimationController? _idle; // only created when active+autoAdvance

  void _syncIdle() {
    final bool shouldRun =
        widget.isActive && widget.autoAdvance && widget.onAutoNext != null;

    if (shouldRun) {
      _idle ??= AnimationController(vsync: this, duration: widget.idleDuration)
        ..addStatusListener((AnimationStatus s) {
          if (s == AnimationStatus.completed) {
            widget.onAutoNext?.call();
          }
        });
      _idle!
        ..stop()
        ..reset()
        ..forward();
    } else {
      _idle?.stop();
      _idle = null;
    }
  }

  void _resetIdle() {
    final AnimationController? c = _idle;
    if (c == null) {
      return;
    }
    c
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

    _syncIdle();
  }

  @override
  void didUpdateWidget(covariant OnboardingLoginOrRegister oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncIdle();
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

    final Widget topBar = (_idle != null)
        ? AnimatedBuilder(
            animation: _idle!,
            builder: (_, _) => OnboardingStepBar(
              total: widget.totalSteps,
              current: widget.stepIndex,
              progress: _idle!.value,
            ),
          )
        : OnboardingStepBar(
            total: widget.totalSteps,
            current: widget.stepIndex,
            progress: widget.autoAdvance ? 0.0 : 1.0,
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _resetIdle,
      onPanDown: (_) => _resetIdle(),
      child: Scaffold(
        backgroundColor: scheme.onSurface,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              topBar,
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 8),

                          // Globe hero (center-left float)
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
                                    tag: 'globe-hero',
                                    child: Image.asset(
                                      'assets/images/voltpay_world.png',
                                      height: size.height * 0.30,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 28),

                          // Headline (title case, line breaks like the mock)
                          Text(
                            'ONE ACCOUNT CONNECTING MONEY\n ACROSS THE WORLD',
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

                          const Spacer(),

                          // Two buttons side-by-side, each wrapped in its own Column
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    AppButton(
                                      text: 'Login',
                                      customForegroundColor: scheme.onPrimary,
                                      customBackgroundColor: scheme.primary,
                                      type: ButtonType.primary,
                                      size: ButtonSize.medium,
                                      isRounded: true,
                                      isFullWidth: true,
                                      icon: const Icon(
                                        Icons.login_outlined,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        _resetIdle();
                                        context.goNamed(AppRoute.login.name);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    AppButton(
                                      text: 'Register',
                                      customForegroundColor: scheme.onPrimary,
                                      customBackgroundColor: scheme.primary,
                                      type: ButtonType.primary,
                                      size: ButtonSize.medium,
                                      isRounded: true,
                                      isFullWidth: true,
                                      icon: const Icon(
                                        Icons.email_outlined,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        _resetIdle();
                                        (widget.onRegister ??
                                                widget.onGetStarted)
                                            .call();
                                        context.goNamed(
                                          AppRoute.emailEntry.name,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          LoginButton(
                            provider: LoginProviders.google,
                            onPressed: () async {
                              // No coupling here—only calls the service
                              final AuthService auth = ref.read(
                                authServiceProvider,
                              );
                              final UserCredential userCred = await auth.signIn(
                                GoogleSignInProvider(),
                              );
                              if (!mounted || userCred.user == null) {
                                return;
                              }
                              // navigate (or rely on a listener of authUserProvider)
                              if (context.mounted) {
                                context.goNamed(
                                  AppRoute.service.name,
                                ); // e.g. the post-verify ServiceScreen
                              }
                              // Providers will emit new AuthUserModel automatically.
                            },
                            size: ButtonSize.large,
                            enabled: true,
                            isLoading: false,
                            loadingColor: scheme.primary,
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
