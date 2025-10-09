import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:voltpay/core/auth/interface/i_is_sign_in_provider.dart';

class EmailPasswordProvider implements ISignInProvider {
  EmailPasswordProvider({required this.email, required this.password});
  final String email;
  final String password;

  @override
  String get providerId => fb.EmailAuthProvider.PROVIDER_ID;

  @override
  Future<fb.AuthCredential> getCredential() async {
    // Keep the same contract: return a credential, do not hit FirebaseAuth here.
    return fb.EmailAuthProvider.credential(email: email, password: password);
  }
}
