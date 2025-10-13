import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:voltpay/core/auth/hooks/auth_hooks.dart';
import 'package:voltpay/core/auth/hooks/persist_user_on_create_hook.dart';
import 'package:voltpay/core/auth/interface/i_auth_repository.dart';
import 'package:voltpay/core/auth/interface/i_user_profile_repository.dart';
import 'package:voltpay/core/auth/repository/auth_repository.dart';
import 'package:voltpay/core/auth/repository/email_link_action_code.dart';
import 'package:voltpay/core/auth/repository/email_passwordless_login_repo.dart';
import 'package:voltpay/core/auth/repository/firestore_user_profile_repository.dart';
import 'package:voltpay/core/auth/service/auth_service.dart';

final Provider<IAuthRepository> authRepoProvider = Provider<IAuthRepository>(
  (Ref ref) => FirebaseAuthRepository(fb.FirebaseAuth.instance),
);

final Provider<fb.User?> currentUserProvider = Provider<fb.User?>(
  (Ref ref) => ref.read(authRepoProvider).currentUser,
);

// Convenience stream for UI (true/false)
final StreamProvider<bool> isLoggedInStreamProvider = StreamProvider<bool>(
  (Ref ref) => ref.read(authRepoProvider).authChanges(),
);

final Provider<IUserProfileRepository> userProfileRepoProvider =
    Provider<IUserProfileRepository>(
      (Ref ref) => FirestoreUserProfileRepository(FirebaseFirestore.instance),
    );

final Provider<List<AuthHook>> authHooksProvider = Provider<List<AuthHook>>((
  Ref ref,
) {
  final IUserProfileRepository profiles = ref.read(userProfileRepoProvider);
  return <AuthHook>[
    PersistUserOnCreateHook(profiles),
    // AppCheckHook(), GeoWhitelistHook(), etc.
  ];
});

final Provider<AuthService> authServiceProvider = Provider<AuthService>((
  Ref ref,
) {
  final IAuthRepository repo = ref.read(authRepoProvider);
  final List<AuthHook> hooks = ref.read(authHooksProvider);
  return AuthService(repo, hooks: hooks);
});

final Provider<fb.FirebaseAuth> firebaseAuthProvider =
    Provider<fb.FirebaseAuth>((Ref ref) {
      return fb.FirebaseAuth.instance;
    });

final Provider<FlutterSecureStorage> secureStorageProvider =
    Provider<FlutterSecureStorage>((Ref ref) {
      return const FlutterSecureStorage();
    });

final Provider<ActionCodeFactory> actionCodeFactoryProvider =
    Provider<ActionCodeFactory>((Ref ref) {
      return buildEmailLinkActionCodeSettings;
    });

final Provider<EmailPasswordlessLoginRepo> emailPasswordlessLoginRepoProvider =
    Provider<EmailPasswordlessLoginRepo>((Ref ref) {
      return EmailPasswordlessLoginRepo(
        auth: ref.read(firebaseAuthProvider),
        codeFactory: ref.read(actionCodeFactoryProvider),
        secureStorage: ref.read(secureStorageProvider),
      );
    });

/// Optional: a stream for your app-wide auth user
final StreamProvider<fb.User?> firebaseUserChangesProvider =
    StreamProvider<fb.User?>((Ref ref) {
      return ref.read(firebaseAuthProvider).authStateChanges();
    });
