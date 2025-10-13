// lib/auth/services/password_hasher_pbkdf2.dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:voltpay/core/auth/interface/i_password_hasher.dart';

class PasswordHasherPbkdf2 implements IPasswordHasher {
  static const int _iterations = 120000;
  static const int _saltLen = 16;
  static const int _keyLen = 32;
  static final Random _rand = Random.secure();

  @override
  Future<String> hash(String password) async {
    final List<int> salt = List<int>.generate(
      _saltLen,
      (_) => _rand.nextInt(256),
    );
    final Pbkdf2 algo = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _iterations,
      bits: _keyLen * 8,
    );
    final SecretKey key = await algo.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    final List<int> bytes = await key.extractBytes();
    return 'v1\$pbkdf2\$$_iterations\$${base64UrlEncode(salt)}\$${base64UrlEncode(bytes)}';
  }

  @override
  Future<bool> verify(String password, String stored) async {
    final List<String> parts = stored.split(r'$');
    if (parts.length != 5 || parts[1] != 'pbkdf2') {
      return false;
    }
    final int iterations = int.parse(parts[2]);
    final Uint8List salt = base64Url.decode(parts[3]);
    final Uint8List hash = base64Url.decode(parts[4]);
    final Pbkdf2 algo = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: hash.length * 8,
    );
    final SecretKey key = await algo.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    final List<int> cmp = await key.extractBytes();
    int diff = 0;
    for (int i = 0; i < cmp.length; i++) {
      diff |= cmp[i] ^ hash[i];
    }
    return diff == 0;
  }

  @override
  bool needsRehash(String stored) => stored.startsWith('v1\$pbkdf2\$');
}
