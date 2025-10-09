import 'package:firebase_auth/firebase_auth.dart' as fb;

abstract class IAuthRepository {
  Stream<bool> authChanges(); // true if logged in
  bool get isLoggedIn;
  // New: a minimal surface that other layers call
  Future<fb.UserCredential> signInAnonymously();
  Future<fb.UserCredential> signInWithCredential(fb.AuthCredential credential);
  Future<fb.UserCredential> linkWithCredential(fb.AuthCredential credential);
  Future<void> signOut();
  fb.User? get currentUser;
}
