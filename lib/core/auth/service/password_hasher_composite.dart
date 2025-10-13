// lib/auth/services/password_hasher_composite.dart
import 'package:voltpay/core/auth/interface/i_password_hasher.dart';
import 'package:voltpay/core/auth/service/password_hasher_argon2id.dart';
import 'package:voltpay/core/auth/service/password_hasher_pbkdf2.dart';

class PasswordHasherComposite implements IPasswordHasher {
  PasswordHasherComposite({IPasswordHasher? argon2, IPasswordHasher? pbkdf2})
    : _argon2 = argon2 ?? PasswordHasherArgon2id(),
      _pbkdf2 = pbkdf2 ?? PasswordHasherPbkdf2();

  final IPasswordHasher _argon2;
  final IPasswordHasher _pbkdf2;
  bool _argon2Broken = false; // memoize failure to avoid repeated crashes

  @override
  Future<String> hash(String password) async {
    if (!_argon2Broken) {
      try {
        return await _argon2.hash(password);
      }
      // dargon2_flutter throws UnimplementedError / ArgumentError on missing .so
      catch (_) {
        _argon2Broken = true;
      }
    }
    return _pbkdf2.hash(password);
  }

  @override
  Future<bool> verify(String password, String stored) async {
    if (stored.startsWith(r'$argon2id$') && !_argon2Broken) {
      try {
        return await _argon2.verify(password, stored);
      } catch (_) {
        _argon2Broken = true;
        return false;
      }
    }
    if (stored.startsWith('v1\$pbkdf2\$')) {
      return _pbkdf2.verify(password, stored);
    }
    // Unknown format
    return false;
  }

  @override
  bool needsRehash(String stored) {
    if (stored.startsWith(r'$argon2id$')) {
      return _argon2.needsRehash(stored);
    }
    if (stored.startsWith('v1\$pbkdf2\$')) {
      return true; // prefer Argon2 eventually
    }
    return true;
  }
}
