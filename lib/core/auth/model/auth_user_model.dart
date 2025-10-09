import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user_model.freezed.dart';
part 'auth_user_model.g.dart';

/// Map enum <-> string in JSON (e.g. "verified", not 1)
@JsonEnum(alwaysCreate: true)
enum UserStatus {
  @JsonValue('unverified')
  unverified,

  @JsonValue('verified')
  verified,

  @JsonValue('kycPending')
  kycPending,
}

@freezed
abstract class AuthUserModel with _$AuthUserModel {
  const factory AuthUserModel({
    required String uid,
    String? email,
    @Default(false) bool emailVerified,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    @Default(false) bool isAnonymous,
    String? tenantId,
    @Default(<String>[]) List<String> providerIds,

    /// Custom business logic status — stored as a string via @JsonEnum
    @Default(UserStatus.unverified) UserStatus status,
  }) = _AuthUserModel;

  /// Factory: Build from FirebaseAuth [User]
  factory AuthUserModel.fromFirebaseUser(fb.User user) {
    final UserStatus inferred =
        user.emailVerified ? UserStatus.verified : UserStatus.unverified;

    return AuthUserModel(
      uid: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
      displayName: user.displayName,
      photoURL: user.photoURL,
      phoneNumber: user.phoneNumber,
      isAnonymous: user.isAnonymous,
      tenantId: user.tenantId,
      providerIds: user.providerData
          .map((fb.UserInfo p) => p.providerId)
          .toList(growable: false),
      status: inferred,
    );
  }

  /// Convenience: build from sign-in result
  factory AuthUserModel.fromCredential(fb.UserCredential cred) {
    final fb.User? u = cred.user;
    if (u == null) {
      throw StateError('UserCredential.user was null');
    }
    return AuthUserModel.fromFirebaseUser(u);
  }

  /// Standard JSON serialization for Firestore / REST
  factory AuthUserModel.fromJson(Map<String, dynamic> json) =>
      _$AuthUserModelFromJson(json);
}

/// Quick extension for mapping directly from FirebaseUser
extension VoltUserX on fb.User {
  AuthUserModel toAuthModel() => AuthUserModel.fromFirebaseUser(this);
}
