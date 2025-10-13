// lib/core/user/provider/user_profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/core/auth/interface/i_user_profile_repository.dart';
import 'package:voltpay/core/auth/model/auth_user_model.dart';
import 'package:voltpay/core/auth/provider/auth_provider.dart';
import 'package:voltpay/core/auth/provider/auth_user_provider.dart';

final StreamProvider<AuthUserModel?>
appUserProvider = StreamProvider<AuthUserModel?>((Ref ref) async* {
  final AuthUserModel? auth = await ref.watch(authUserProvider.future);
  if (auth == null) {
    yield null;
    return;
  }
  // Prefer the Firestore doc if present; otherwise fall back to auth snapshot.
  final IUserProfileRepository repo = ref.read(userProfileRepoProvider);
  yield* repo.watchByUid(auth.uid).map((AuthUserModel? doc) => doc ?? auth);
});
