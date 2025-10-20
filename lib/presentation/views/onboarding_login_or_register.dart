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
    final Size _ = MediaQuery.of(context).size;

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
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              topBar,

              // Scrollable area to prevent "overflow by XXX pixels"
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints viewport) {
                        final Size size = MediaQuery.of(context).size;
                        final bool compactH = size.height < 720;

                        // Clamp hero + title sizes for small screens
                        final double heroHeight = (size.height * 0.30).clamp(
                          140.0,
                          260.0,
                        );
                        final double titleFont = (size.width * 0.072).clamp(
                          20.0,
                          32.0,
                        );

                        // Finite bottom gap instead of Spacer (prevents flex asserts)
                        final double bottomGap = compactH ? 20.0 : 36.0;

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: compactH ? 12 : 20,
                            // keeps content above system insets/keyboard
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom +
                                (compactH ? 16 : 24),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // Hero
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
                                          height: heroHeight,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 16),

                              // Headline
                              Text(
                                'ONE ACCOUNT CONNECTING MONEY\n ACROSS THE WORLD',
                                textAlign: TextAlign.center,
                                softWrap: true,
                                maxLines: 4,
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

                              // ⛔️ REPLACED Spacer() with a finite, responsive gap
                              SizedBox(height: bottomGap),

                              // Login / Register row (stays on one line; scrolls horizontally if ever too tight)
                              LayoutBuilder(
                                builder:
                                    (BuildContext context, BoxConstraints c) {
                                      const double spacing = 12;
                                      final double btnWidth =
                                          ((c.maxWidth - spacing) / 2).clamp(
                                            140.0,
                                            220.0,
                                          );
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(
                                              width: btnWidth,
                                              child: AppButton(
                                                text: 'Login',
                                                customForegroundColor:
                                                    scheme.onPrimary,
                                                customBackgroundColor:
                                                    scheme.primary,
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
                                                  context.goNamed(
                                                    AppRoute.login.name,
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: spacing),
                                            SizedBox(
                                              width: btnWidth,
                                              child: AppButton(
                                                text: 'Register',
                                                customForegroundColor:
                                                    scheme.onPrimary,
                                                customBackgroundColor:
                                                    scheme.primary,
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
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                              ),

                              // const SizedBox(height: 16),
                              const SizedBox(height: 48),

                              // Google button
                              LoginButton(
                                provider: LoginProviders.google,
                                onPressed: () async {
                                  final AuthService auth = ref.read(
                                    authServiceProvider,
                                  );
                                  final UserCredential userCred = await auth
                                      .signIn(GoogleSignInProvider());
                                  if (!mounted || userCred.user == null) {
                                    return;
                                  }
                                  if (context.mounted) {
                                    context.goNamed(AppRoute.service.name);
                                  }
                                },
                                size: ButtonSize.large,
                                enabled: true,
                                isLoading: false,
                                loadingColor: scheme.primary,
                              ),

                              const SizedBox(height: 22),
                            ],
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
