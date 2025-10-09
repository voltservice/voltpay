import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:voltpay/core/auth/interface/i_auth_repository.dart';

class FirebaseAuthRepository implements IAuthRepository {
  FirebaseAuthRepository(this._auth);
  final fb.FirebaseAuth _auth;

  @override
  Stream<bool> authChanges() =>
      _auth.authStateChanges().map((fb.User? u) => u != null);

  @override
  bool get isLoggedIn => _auth.currentUser != null;

  @override
  Future<fb.UserCredential> signInAnonymously() => _auth.signInAnonymously();

  @override
  Future<fb.UserCredential> signInWithCredential(fb.AuthCredential c) =>
      _auth.signInWithCredential(c);

  @override
  Future<fb.UserCredential> linkWithCredential(fb.AuthCredential c) async {
    final fb.User? user = _auth.currentUser;
    if (user == null) {
      throw StateError('No current user to link credential to.');
    }
    return user.linkWithCredential(c);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  fb.User? get currentUser => _auth.currentUser;
}
