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
    // final TextEditingController emailCtl = TextEditingController(
    //   text: emailState.email,
    // );
    // Get stable instances from providers
    final TextEditingController emailCtl = ref.watch(emailControllerProvider);
    final FocusNode emailFn = ref.watch(emailFocusNodeProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.goNamed(AppRoute.obnlastpg.name),
                      tooltip: 'Back',
                    ),
                  ),
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
                    onChanged: ref.read(emailFormProvider.notifier).setEmail,
                    decoration: InputDecoration(
                      hintText: 'name@example.com',
                      errorText: (emailState.isDirty && !emailState.isValid)
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
                  const SizedBox(height: 16),
                  AppButton(
                    key: const Key('login_forgot'),
                    text: 'Log in',
                    onPressed: emailState.isValid
                        ? () async {
                            final String email = emailState.email.trim();
                            final String pwd = ref.read(loginPasswordProvider);
                            final LocalLoginRepo repo = ref.read(
                              localLoginRepoProvider,
                            );
                            final bool ok = await repo.verifyForEmail(
                              email,
                              pwd,
                            );
                            if (!ok) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid email or password'),
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
                    size: ButtonSize.large,
                    isLoading: false,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      /* forgot flow */
                    },
                    child: const Text(
                      'Trouble logging in?',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('or log in with'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: LoginButton(
                          provider: LoginProviders.google,
                          showLabel: false,
                          onPressed: () async {
                            final AuthService auth = ref.read(
                              authServiceProvider,
                            );
                            await auth.signIn(GoogleSignInProvider());
                            if (context.mounted) {
                              context.goNamed(AppRoute.service.name);
                            }
                          },
                          size: ButtonSize.medium,
                          loadingColor: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LoginButton(
                          provider: LoginProviders.facebook,
                          showLabel: false,
                          onPressed: () async {
                            final AuthService auth = ref.read(
                              authServiceProvider,
                            );
                            await auth.signIn(FacebookSignInProvider());
                            if (context.mounted) {
                              context.goNamed(AppRoute.service.name);
                            }
                          },
                          loadingColor: scheme.primary,
                          size: ButtonSize.medium,
                          type: ButtonType.fill,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
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
                  const SizedBox(height: 12),
                  LoginButton(
                    provider: LoginProviders.passkey,
                    onPressed: () {
                      /* TODO: WebAuthn/Passkeys */
                    },
                    loadingColor: scheme.primary,
                    size: ButtonSize.large,
                    type: ButtonType.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
