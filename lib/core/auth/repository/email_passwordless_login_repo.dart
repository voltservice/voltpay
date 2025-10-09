import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encapsulates Email Link (passwordless) auth only.
/// UI calls into here; no UI code inside.
class EmailPasswordlessLoginRepo {
  EmailPasswordlessLoginRepo({
    required fb.FirebaseAuth auth,
    required ActionCodeFactory codeFactory,
    FlutterSecureStorage? secureStorage,
  })  : _auth = auth,
        _codeFactory = codeFactory,
        _secure = secureStorage ?? const FlutterSecureStorage();

  final fb.FirebaseAuth _auth;
  final ActionCodeFactory _codeFactory;
  final FlutterSecureStorage _secure;

  static const String _kStoredEmail = 'emailLink.pendingEmail';

  /// Sends the sign-in link to [email].
  Future<void> sendEmailLink(String email) async {
    final fb.ActionCodeSettings settings = _codeFactory();
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: settings,
    );
    // Persist email locally so we can finish sign-in when link returns.
    await _secure.write(key: _kStoredEmail, value: email.trim());
  }

  /// Returns the locally stored pending email (if any).
  Future<String?> getPendingEmail() => _secure.read(key: _kStoredEmail);

  /// Clears the pending email.
  Future<void> clearPendingEmail() => _secure.delete(key: _kStoredEmail);

  /// Determines whether [link] is an email sign-in link.
  bool isEmailLink(String link) => _auth.isSignInWithEmailLink(link);

  /// Completes sign-in if [link] is a valid email sign-in deep link.
  ///
  /// If [email] is null we try the secure stored email.
  /// Returns the signed-in Firebase user.
  Future<fb.User> completeSignInFromLink({
    required String link,
    String? email,
  }) async {
    final String? e = (email ?? await getPendingEmail())?.trim();
    if (e == null || e.isEmpty) {
      throw StateError('No pending email for email-link sign-in.');
    }
    final fb.UserCredential cred = await _auth.signInWithEmailLink(
      email: e,
      emailLink: link,
    );
    // If we got here, sign-in succeeded — clear local state.
    await clearPendingEmail();
    final fb.User? u = cred.user;
    if (u == null) {
      throw StateError('Firebase returned null user after email-link sign-in.');
    }
    return u;
  }

  /// Convenience — checks clipboard for a deep link on desktop/dev, optional.
  Future<String?> maybeExtractLinkFromClipboard() async {
    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      final String? txt = data?.text;
      if (txt != null && txt.contains('mode=signIn')) {
        return txt.trim();
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

/// Factory typedef for creating ActionCodeSettings (keeps env wiring outside).
typedef ActionCodeFactory = fb.ActionCodeSettings Function();
