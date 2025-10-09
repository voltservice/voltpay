import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Thrown to signal that the caller should use FirebaseAuth.signInWithPopup(provider) on web.
class WebProviderRequired implements Exception {
  WebProviderRequired(this.webProvider);
  final fb.AuthProvider webProvider;
}
