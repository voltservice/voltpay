// lib/core/auth/providers/provider_factory.dart
import 'package:voltpay/core/auth/interface/i_is_sign_in_provider.dart';
import 'package:voltpay/core/auth/provider/email_password_provider.dart';
import 'package:voltpay/core/auth/provider/facebook_sign_in_provider.dart';
import 'package:voltpay/core/auth/provider/google_sign_in_provider.dart';
import 'package:voltpay/core/auth/ui/login_providers_style.dart';

ISignInProvider providerFor(
  LoginProviders p, {
  String? email,
  String? password,
}) {
  switch (p) {
    case LoginProviders.google:
      return GoogleSignInProvider();
    case LoginProviders.facebook:
      return FacebookSignInProvider();
    case LoginProviders.emailPassword:
      return EmailPasswordProvider(
        email: email ?? '',
        password: password ?? '',
      );
  }
}
