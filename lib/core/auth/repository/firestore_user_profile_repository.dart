// lib/core/user/repository/firestore_user_profile_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voltpay/core/auth/interface/i_user_profile_repository.dart';
import 'package:voltpay/core/auth/model/auth_user_model.dart';

class FirestoreUserProfileRepository implements IUserProfileRepository {
  FirestoreUserProfileRepository(this._fs);
  final FirebaseFirestore _fs;

  CollectionReference<Map<String, dynamic>> get _users =>
      _fs.collection('users');

  @override
  Stream<AuthUserModel?> watchByUid(String uid) {
    return _users.doc(uid).snapshots().map((
      DocumentSnapshot<Map<String, dynamic>> s,
    ) {
      final Map<String, dynamic>? d = s.data();
      return d == null ? null : AuthUserModel.fromJson(d);
    });
  }

  @override
  Future<void> upsertNewUser(
    AuthUserModel u, {
    required String providerId,
  }) async {
    final DocumentReference<Map<String, dynamic>> doc = _users.doc(u.uid);

    // Map provider strings to what your rules allow
    final String normalizedProvider = switch (providerId) {
      'google.com' => 'google',
      'facebook.com' => 'facebook',
      'apple.com' => 'apple',
      'password' => 'password',
      _ => 'password',
    };

    final Map<String, dynamic> data = <String, dynamic>{
      // required by rules
      'authProvider': normalizedProvider,
      'email': u.email,
      'emailVerified': u.emailVerified,
      'isAnonymous': u.isAnonymous,
      'status': switch (u.status) {
        UserStatus.verified => 'verified',
        UserStatus.kycPending => 'kycPending',
        UserStatus.unverified => 'unverified',
      },
      'providerIds': u.providerIds, // list<string>
      // server timestamps required by rules
      'createdAt': FieldValue.serverTimestamp(),
      'lastSignedIn': FieldValue.serverTimestamp(),

      // optional mirrors (only when valid)
      if (u.displayName != null && u.displayName!.isNotEmpty)
        'displayName': u.displayName,
      if (u.photoURL != null &&
          (u.photoURL!.startsWith('http://') ||
              u.photoURL!.startsWith('https://')))
        'photoURL': u.photoURL,
      if (u.phoneNumber != null && u.phoneNumber!.isNotEmpty)
        'phoneNumber': u.phoneNumber,
      if (u.tenantId != null && u.tenantId!.isNotEmpty) 'tenantId': u.tenantId,
    };

    await doc.set(data, SetOptions(merge: true));
  }

  @override
  Future<void> touchLastSignedIn(String uid) => _users.doc(uid).update(
    <Object, Object?>{'lastSignedIn': FieldValue.serverTimestamp()},
  );
}
