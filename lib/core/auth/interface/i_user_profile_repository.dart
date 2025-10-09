// lib/core/user/interface/i_user_profile_repository.dart
import 'package:voltpay/core/auth/model/auth_user_model.dart';

abstract class IUserProfileRepository {
  Stream<AuthUserModel?> watchByUid(String uid); // optional: read side
  Future<void> upsertNewUser(AuthUserModel user, {required String providerId});
  Future<void> touchLastSignedIn(String uid);
}
