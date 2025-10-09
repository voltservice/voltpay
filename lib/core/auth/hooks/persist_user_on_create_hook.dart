// lib/core/auth/hooks/persist_user_on_create_hook.dart
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:voltpay/core/auth/hooks/auth_hooks.dart';
import 'package:voltpay/core/auth/interface/i_user_profile_repository.dart';
import 'package:voltpay/core/auth/model/auth_user_model.dart';

class PersistUserOnCreateHook extends AuthHook {
  PersistUserOnCreateHook(this._profiles);
  final IUserProfileRepository _profiles;

  @override
  Future<HookDecision> beforeCreateUser(fb.UserCredential cred) async {
    final AuthUserModel model = AuthUserModel.fromCredential(
      cred,
    ); // no Firestore here
    // Derive provider id for rules (e.g. google, facebook, apple, password)
    final String provider = cred.credential?.providerId ??
        cred.additionalUserInfo?.providerId ??
        (cred.user?.providerData.isNotEmpty == true
            ? cred.user!.providerData.first.providerId
            : 'password');

    await _profiles.upsertNewUser(model, providerId: provider);
    return HookDecision.allow;
  }
}
