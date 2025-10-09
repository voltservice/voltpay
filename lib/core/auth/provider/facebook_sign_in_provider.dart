import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:voltpay/core/auth/interface/i_is_sign_in_provider.dart';

class FacebookSignInProvider implements ISignInProvider {
  @override
  String get providerId => fb.FacebookAuthProvider.PROVIDER_ID;

  @override
  Future<fb.AuthCredential> getCredential() async {
    final LoginResult res = await FacebookAuth.instance.login(
      permissions: const <String>['email', 'public_profile'],
      loginBehavior: LoginBehavior.nativeWithFallback, // prefer native
    );

    // Log what actually happened (remove in prod)
    // ignore: avoid_print
    print(
      'FB login status=${res.status} message=${res.message} token? ${res.accessToken != null}',
    );

    switch (res.status) {
      case LoginStatus.success:
        final String accessToken =
            res.accessToken!.tokenString; // <-- use `tokenString`
        return fb.FacebookAuthProvider.credential(accessToken);

      case LoginStatus.cancelled:
        throw const SignInAborted('Facebook sign-in cancelled by user');

      case LoginStatus.failed:
        throw Exception(
          'Facebook sign-in failed: ${res.message ?? 'unknown error'}',
        );

      case LoginStatus.operationInProgress:
        throw Exception('Facebook sign-in is already in progress');
    }
  }
}

class SignInAborted implements Exception {
  const SignInAborted(this.message);
  final String message;
  @override
  String toString() => message;
}
