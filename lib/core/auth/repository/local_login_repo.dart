// lib/core/auth/repository/local_login_repo.dart
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:voltpay/core/auth/interface/i_password.dart';
import 'package:voltpay/core/auth/interface/i_password_hasher.dart';

class LocalLoginRepo implements IPasswordRepo {
  LocalLoginRepo({
    required FlutterSecureStorage storage,
    required IPasswordHasher hasher,
  }) : _storage = storage,
       _hasher = hasher;

  final FlutterSecureStorage _storage;
  final IPasswordHasher _hasher;

  // Key namespace is per-email (lowercased). You can SHA-256 the email if you prefer.
  String _keyFor(String email) {
    final String e = email.trim().toLowerCase();
    final Digest digest = sha256.convert(utf8.encode(e));
    final String b64 = base64Url.encode(digest.bytes);
    return 'login.$b64';
  }

  /// Set or update the local login secret for an email.
  Future<void> setForEmail(String email, String plain) async {
    final String phc = await _hasher.hash(plain);
    await _storage.write(key: _keyFor(email), value: phc);
  }

  /// Verify local login for an email.
  Future<bool> verifyForEmail(String email, String plain) async {
    final String? stored = await _storage.read(key: _keyFor(email));
    if (stored == null || stored.isEmpty) {
      return false;
    }

    final bool ok = await _hasher.verify(plain, stored);
    if (ok && _hasher.needsRehash(stored)) {
      final String newPhc = await _hasher.hash(plain);
      await _storage.write(key: _keyFor(email), value: newPhc);
    }
    return ok;
  }

  /// Optional: clear just this email’s secret
  Future<void> clearForEmail(String email) async {
    await _storage.delete(key: _keyFor(email));
  }

  // IPasswordRepo legacy API (not used for email-less calls)
  @override
  Future<void> setPaymentPassword(String plain) {
    throw UnimplementedError('Use setForEmail(email, plain).');
  }

  @override
  Future<bool> verify(String plain) async {
    throw UnimplementedError('Use verifyForEmail(email, plain).');
  }

  @override
  Future<void> clear() async {
    throw UnimplementedError('Use clearForEmail(email).');
  }
}
