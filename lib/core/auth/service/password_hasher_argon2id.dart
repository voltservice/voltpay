// lib/auth/services/password_hasher_argon2id.dart
import 'package:dargon2_flutter/dargon2_flutter.dart';
import 'package:voltpay/core/auth/interface/i_password_hasher.dart';

class PasswordHasherArgon2id implements IPasswordHasher {
  final int memoryKiB, iterations, parallelism, hashLength;

  PasswordHasherArgon2id({
    this.memoryKiB = 65536, // 64 MiB
    this.iterations = 3,
    this.parallelism = 1,
    this.hashLength = 32,
  });

  @override
  Future<String> hash(String password) async {
    final Salt salt = Salt.newSalt(length: 16);
    final DArgon2Result res = await argon2.hashPasswordString(
      password,
      salt: salt,
      iterations: iterations,
      memory: memoryKiB,
      parallelism: parallelism,
      length: hashLength,
      type: Argon2Type.id,
      version: Argon2Version.V13,
    );
    return res.encodedString; // $argon2id$...
  }

  @override
  Future<bool> verify(String password, String stored) {
    return argon2.verifyHashString(password, stored, type: Argon2Type.id);
  }

  @override
  bool needsRehash(String phc) {
    final RegExpMatch? m = RegExp(
      r'^\$argon2id\$v=\d+\$m=(\d+),t=(\d+),p=(\d+)\$',
    ).firstMatch(phc);
    if (m == null) {
      return true;
    }
    final int mem = int.parse(m.group(1)!);
    final int it = int.parse(m.group(2)!);
    final int par = int.parse(m.group(3)!);
    return mem < 65536 || it < 3 || par < 1;
  }
}
