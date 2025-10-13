// lib/features/send_money/security/repo/local_password_repo.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:voltpay/core/auth/interface/i_password.dart';
import 'package:voltpay/core/auth/interface/i_password_hasher.dart';
import 'package:voltpay/core/auth/model/auth_user_model.dart';

class LocalPasswordRepo implements IPasswordRepo {
  LocalPasswordRepo({
    required FlutterSecureStorage storage,
    required IPasswordHasher hasher,
    required AuthUserModel user,
  }) : _storage = storage,
       _hasher = hasher,
       _kKey = 'payment_password_v1_${user.uid}';

  final FlutterSecureStorage _storage;
  final IPasswordHasher _hasher;
  final String _kKey;

  @override
  Future<void> setPaymentPassword(String plain) async {
    final String phc = await _hasher.hash(plain);
    await _storage.write(key: _kKey, value: phc);
  }

  @override
  Future<bool> verify(String plain) async {
    final String? stored = await _storage.read(key: _kKey);
    if (stored == null || stored.isEmpty) {
      return false;
    }

    final bool ok = await _hasher.verify(plain, stored);
    if (ok && _hasher.needsRehash(stored)) {
      // migrate forward (e.g., PBKDF2 -> Argon2id, or stronger params)
      final String newPhc = await _hasher.hash(plain);
      await _storage.write(key: _kKey, value: newPhc);
    }
    return ok;
  }

  @override
  Future<void> clear() => _storage.delete(key: _kKey);
}
