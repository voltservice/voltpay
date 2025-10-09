import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:voltpay/core/auth/hooks/auth_hooks.dart';
import 'package:voltpay/core/auth/interface/i_auth_repository.dart';
import 'package:voltpay/core/auth/interface/i_is_sign_in_provider.dart';
import 'package:voltpay/core/auth/provider/web_provider.dart';

class AuthService {
  AuthService(this._repo, {List<AuthHook>? hooks})
      : _hooks = hooks ?? const <AuthHook>[];
  final IAuthRepository _repo;
  final List<AuthHook> _hooks;

  Future<fb.UserCredential> signIn(ISignInProvider provider) async {
    // 1) Ask the provider for a credential (no Firebase calls inside providers)
    fb.AuthCredential? credential;
    fb.AuthProvider? webProvider;

    try {
      credential = await provider.getCredential();
    } on WebProviderRequired catch (e) {
      webProvider = e.webProvider; // Google on Web
    }

    // 2) Run "before sign-in" hooks
    final HookDecision gate = await _runBeforeSignIn(
      provider,
      credential,
      webProvider,
    );
    if (gate == HookDecision.deny) {
      throw Exception('Sign-in blocked by policy.');
    }

    // 3) Call FirebaseAuth via repository
    fb.UserCredential userCred;
    if (kIsWeb && webProvider != null) {
      // Web Google/Facebook popup path
      userCred = await fb.FirebaseAuth.instance.signInWithPopup(webProvider);
    } else if (credential != null) {
      userCred = await _repo.signInWithCredential(credential);
    } else {
      throw StateError('No credential or web provider available for sign-in.');
    }

    // 4) If new user, run "before create"
    if (userCred.additionalUserInfo?.isNewUser == true) {
      final HookDecision createGate = await _runBeforeCreateUser(userCred);
      if (createGate == HookDecision.deny) {
        // rollback: delete the freshly created Firebase user if needed
        try {
          await userCred.user?.delete();
        } catch (_) {}
        throw Exception('Account creation blocked by policy.');
      }
    }

    // 5) After sign-in hook(s)
    await _runAfterSignIn(userCred);

    return userCred;
  }

  Future<void> link(ISignInProvider provider) async {
    fb.AuthCredential? credential;
    fb.AuthProvider? webProvider;
    try {
      credential = await provider.getCredential();
    } on WebProviderRequired catch (e) {
      webProvider = e.webProvider;
    }

    if (kIsWeb && webProvider != null) {
      await fb.FirebaseAuth.instance.currentUser?.linkWithPopup(webProvider);
      return;
    }
    if (credential == null) {
      throw StateError('No credential to link.');
    }
    await _repo.linkWithCredential(credential);
  }

  Future<void> signOut() => _repo.signOut();

  // ---- hooks wiring ----
  Future<HookDecision> _runBeforeSignIn(
    ISignInProvider p,
    fb.AuthCredential? c,
    fb.AuthProvider? webP,
  ) async {
    final HookContext ctx = HookContext(
      providerId: p.providerId,
      email: _extractEmailIfAny(p, c),
      oauthIdToken: _extractIdToken(c),
      oauthAccessToken: _extractAccessToken(c),
    );
    for (final AuthHook h in _hooks) {
      final HookDecision d = await h.beforeSignIn(ctx);
      if (d == HookDecision.deny) {
        return d;
      }
    }
    return HookDecision.allow;
  }

  Future<HookDecision> _runBeforeCreateUser(fb.UserCredential cred) async {
    for (final AuthHook h in _hooks) {
      final HookDecision d = await h.beforeCreateUser(cred);
      if (d == HookDecision.deny) {
        return d;
      }
    }
    return HookDecision.allow;
  }

  Future<void> _runAfterSignIn(fb.UserCredential cred) async {
    for (final AuthHook h in _hooks) {
      await h.afterSignIn(cred);
    }
  }

  String? _extractEmailIfAny(ISignInProvider p, fb.AuthCredential? c) {
    if (p.providerId == fb.EmailAuthProvider.PROVIDER_ID) {
      // Email is known at UI layer; pass via a custom EmailPasswordProvider if needed.
      // Here we can’t extract it from credential directly.
    }
    return null;
  }

  String? _extractIdToken(fb.AuthCredential? c) {
    // Not strictly exposed; keep for future provider-specific parsing if needed.
    return null;
  }

  String? _extractAccessToken(fb.AuthCredential? c) => null;
}
