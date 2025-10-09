import 'package:firebase_auth/firebase_auth.dart' as fb;

enum HookDecision { allow, deny }

class HookContext {
  HookContext({
    required this.providerId,
    this.email,
    this.oauthIdToken,
    this.oauthAccessToken,
    this.scopes = const <String>[],
  });

  final String providerId;
  final String? email;
  final String? oauthIdToken;
  final String? oauthAccessToken;
  final List<String> scopes;
}

abstract class AuthHook {
  /// Called before we call FirebaseAuth.* (good for device/app-check, geo, rate-limit, etc.)
  Future<HookDecision> beforeSignIn(HookContext ctx) async =>
      HookDecision.allow;

  /// Called when Firebase returns a new user (first sign-in).
  /// Good place to block creation if KYC fails or you need pre-provisioning.
  Future<HookDecision> beforeCreateUser(fb.UserCredential cred) async =>
      HookDecision.allow;

  /// After any successful sign-in (existing or new).
  Future<void> afterSignIn(fb.UserCredential cred) async {}
}
