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
