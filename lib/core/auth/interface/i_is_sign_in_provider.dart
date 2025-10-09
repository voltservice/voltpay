import 'package:firebase_auth/firebase_auth.dart' as fb;

abstract class ISignInProvider {
  /// e.g. "google.com", "facebook.com", "password"
  String get providerId;

  /// Acquire an AuthCredential (UX / SDK specific), but do NOT call FirebaseAuth here.
  Future<fb.AuthCredential> getCredential();
}
