import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:voltpay/core/auth/interface/i_is_sign_in_provider.dart';
import 'package:voltpay/core/auth/provider/web_provider.dart';

class GoogleSignInProvider implements ISignInProvider {
  GoogleSignInProvider({
    GoogleSignIn? googleSignIn,
    this.webClientId,
    this.iosClientId,
    this.macosClientId,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignIn _googleSignIn;
  final String? webClientId;
  final String? iosClientId;
  final String? macosClientId;

  @override
  String get providerId => fb.GoogleAuthProvider.PROVIDER_ID;

  @override
  Future<fb.AuthCredential> getCredential() async {
    // ✅ Web: use Firebase popup flow instead of GoogleSignIn
    if (kIsWeb) {
      final fb.GoogleAuthProvider webProvider = fb.GoogleAuthProvider();
      if (webClientId != null) {
        webProvider.setCustomParameters(<dynamic, dynamic>{
          'client_id': webClientId!,
        });
      }
      throw WebProviderRequired(webProvider);
    }

    _googleSignIn.initialize(
      serverClientId:
          '1018663726434-v2t5nm4npt6taf2j51pp9oaiit89k958.apps.googleusercontent.com',
    );

    // ✅ Native (Android/iOS/macOS)
    final GoogleSignInAccount account = await _googleSignIn.authenticate();

    final GoogleSignInAuthentication auth = account.authentication;

    // ⚠️ accessToken is null on Android/iOS (expected)
    // FirebaseAuth only needs idToken to create a credential.
    if (auth.idToken == null) {
      throw const SignInAborted('Missing Google ID Token.');
    }

    return fb.GoogleAuthProvider.credential(idToken: auth.idToken);
  }
}

/// Custom exception for when user aborts sign-in.
class SignInAborted implements Exception {
  const SignInAborted(this.message);
  final String message;
  @override
  String toString() => 'SignInAborted: $message';
}
