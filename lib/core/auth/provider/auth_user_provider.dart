// // lib/core/auth/provider/auth_user_provider.dart
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/core/auth/model/auth_user_model.dart';

/// Stream of the raw FirebaseAuth user (optional, if you need direct access)
final StreamProvider<fb.User?> firebaseUserProvider = StreamProvider<fb.User?>(
  (Ref ref) => fb.FirebaseAuth.instance.authStateChanges(),
);

/// App-level view of the authenticated user, mapped to your AuthUserModel.
/// This avoids deprecated `.stream` syntax and composes cleanly.
final StreamProvider<AuthUserModel?>
authUserProvider = StreamProvider<AuthUserModel?>((Ref ref) {
  // Listen to the AsyncValue<fb.User?> from firebaseUserProvider
  final AsyncValue<fb.User?> firebaseUser = ref.watch(firebaseUserProvider);

  // If still loading or errored, pass through the same AsyncValue
  return firebaseUser.when(
    data: (fb.User? user) async* {
      // yield a single mapped model — you can also use yield* if combining streams
      yield user?.toAuthModel();
    },
    loading: () async* {
      // yield nothing while loading
      yield null;
    },
    error: (Object e, StackTrace st) async* {
      // handle gracefully
      yield null;
    },
  );
});
// lib/core/auth/provider/auth_user_provider.dart
// import 'package:firebase_auth/firebase_auth.dart' as fb;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:voltpay/core/auth/model/auth_user_model.dart';
//
// /// App-level authenticated user as `AuthUserModel?`.
// /// Uses `userChanges()` so it updates on sign-in/out & profile/token refresh.
// final StreamProvider<AuthUserModel?> authUserProvider =
//     StreamProvider<AuthUserModel?>((Ref ref) {
//       return fb.FirebaseAuth.instance.userChanges().map((fb.User? u) {
//         if (u == null) {
//           return null;
//         }
//         return AuthUserModel(
//           uid: u.uid,
//           email: u.email,
//           displayName: u.displayName,
//           phoneNumber: u.phoneNumber,
//           photoURL: u.photoURL,
//           isAnonymous: u.isAnonymous,
//           tenantId: u.tenantId,
//           providerIds: u.providerData
//               .map((fb.UserInfo p) => p.providerId)
//               .toList(),
//           emailVerified: u.emailVerified,
//           status: u.emailVerified ? UserStatus.verified : UserStatus.unverified,
//         );
//       });
//     });
