// lib/core/auth/ui/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/auth/provider/auth_provider.dart';
import 'package:voltpay/core/auth/provider/email_form_state.dart';
import 'package:voltpay/core/auth/provider/facebook_sign_in_provider.dart';
import 'package:voltpay/core/auth/provider/google_sign_in_provider.dart';
import 'package:voltpay/core/auth/provider/local_login_password_provider.dart';
import 'package:voltpay/core/auth/provider/login_repo_providers.dart';
import 'package:voltpay/core/auth/repository/local_login_repo.dart';
import 'package:voltpay/core/auth/service/auth_service.dart';
import 'package:voltpay/core/auth/ui/login_button.dart';
import 'package:voltpay/core/auth/ui/login_providers_style.dart';
import 'package:voltpay/core/auth/ui/widget/login_field_providers.dart';
import 'package:voltpay/core/auth/ui/widget/password_field.dart';
import 'package:voltpay/core/router/app_routes.dart';
import 'package:voltpay/core/utils/buttons/app_buttons.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final EmailFormState emailState = ref.watch(emailFormProvider);
    final TextEditingController emailCtl = ref.watch(emailControllerProvider);
    final FocusNode emailFn = ref.watch(emailFocusNodeProvider);

    // Small-height devices tweak (e.g., older iPhones, small Androids)
    final double h = MediaQuery.of(context).size.height;
    final bool compact = h < 700;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 8,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // Align(
                        //   alignment: Alignment.centerLeft,
                        //   child: IconButton(
                        //     icon: const Icon(Icons.arrow_back),
                        //     onPressed: () =>
                        //         context.goNamed(AppRoute.flow.name),
                        //     tooltip: 'Back',
                        //   ),
                        // ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Log in',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        const SizedBox(height: 8),

                        TextField(
                          key: const Key('login_email'),
                          controller: emailCtl,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const <String>[AutofillHints.email],
                          focusNode: emailFn,
                          enableSuggestions: true,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          scrollPadding: const EdgeInsets.only(bottom: 120),
                          onChanged: ref
                              .read(emailFormProvider.notifier)
                              .setEmail,
                          decoration: InputDecoration(
                            hintText: 'name@example.com',
                            errorText:
                                (emailState.isDirty && !emailState.isValid)
                                ? 'Enter a valid email'
                                : null,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Password',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const PasswordField(),

                        SizedBox(height: compact ? 12 : 16),

                        AppButton(
                          key: const Key('login_forgot'),
                          text: 'Log in',
                          onPressed: emailState.isValid
                              ? () async {
                                  final String email = emailState.email.trim();
                                  final String pwd = ref.read(
                                    loginPasswordProvider,
                                  );
                                  final LocalLoginRepo repo = ref.read(
                                    localLoginRepoProvider,
                                  );
                                  final bool ok = await repo.verifyForEmail(
                                    email,
                                    pwd,
                                  );
                                  if (!ok) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Invalid email or password',
                                          ),
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                  if (context.mounted) {
                                    context.goNamed(AppRoute.service.name);
                                  }
                                }
                              : null,
                          type: ButtonType.primary,
                          size: compact ? ButtonSize.medium : ButtonSize.large,
                          isLoading: false,
                        ),

                        const SizedBox(height: 6),

                        TextButton(
                          onPressed: () {
                            /* forgot flow */
                          },
                          child: const Text(
                            'Trouble logging in?',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationThickness: 1.0,
                              decorationColor: Colors.blue,
                              decorationStyle: TextDecorationStyle.solid,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // const Text('or log in with'),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'or log in with',
                            style: Theme.of(context).textTheme.labelLarge,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ),
                        // const SizedBox(height: 12),
                        const SizedBox(height: 24),

                        // --- Federated providers: single horizontal row (scrolls on tiny screens) ---
                        LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints c) {
                            const double spacing = 12;
                            final double target =
                                (c.maxWidth - (spacing * 2)) /
                                3; // 3 buttons in view
                            final double btnWidth = target.clamp(112.0, 164.0);
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    width: btnWidth,
                                    child: LoginButton(
                                      provider: LoginProviders.google,
                                      showLabel: false,
                                      onPressed: () async {
                                        final AuthService auth = ref.read(
                                          authServiceProvider,
                                        );
                                        await auth.signIn(
                                          GoogleSignInProvider(),
                                        );
                                        if (context.mounted) {
                                          context.goNamed(
                                            AppRoute.service.name,
                                          );
                                        }
                                      },
                                      size: ButtonSize.medium,
                                      loadingColor: scheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: spacing),
                                  SizedBox(
                                    width: btnWidth,
                                    child: LoginButton(
                                      provider: LoginProviders.facebook,
                                      showLabel: false,
                                      onPressed: () async {
                                        final AuthService auth = ref.read(
                                          authServiceProvider,
                                        );
                                        await auth.signIn(
                                          FacebookSignInProvider(),
                                        );
                                        if (context.mounted) {
                                          context.goNamed(
                                            AppRoute.service.name,
                                          );
                                        }
                                      },
                                      loadingColor: scheme.primary,
                                      size: ButtonSize.medium,
                                      type: ButtonType.fill,
                                    ),
                                  ),
                                  const SizedBox(width: spacing),
                                  SizedBox(
                                    width: btnWidth,
                                    child: LoginButton(
                                      provider: LoginProviders.apple,
                                      showLabel: false,
                                      onPressed: () {
                                        /* TODO */
                                      },
                                      loadingColor: scheme.secondary,
                                      size: ButtonSize.medium,
                                      type: ButtonType.outline,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // Passkey remains separate (vertical)
                        LoginButton(
                          provider: LoginProviders.passkey,
                          onPressed: () {
                            /* TODO: WebAuthn/Passkeys */
                          },
                          loadingColor: scheme.primary,
                          size: compact ? ButtonSize.medium : ButtonSize.large,
                          type: ButtonType.outline,
                        ),

                        SizedBox(height: compact ? 8 : 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
