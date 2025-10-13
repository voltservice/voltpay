import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:voltpay/core/auth/interface/i_password_hasher.dart';
import 'package:voltpay/core/auth/repository/local_login_repo.dart';

import '../mocks.mocks.dart';

class FakeHasher implements IPasswordHasher {
  @override
  Future<String> hash(String p) async => 'H($p)';
  @override
  Future<bool> verify(String p, String s) async => s == 'H($p)';
  @override
  bool needsRehash(String s) => false;
}

String hashedKeyFor(String email) {
  final String e = email.trim().toLowerCase();
  final String b64 = base64Url.encode(sha256.convert(utf8.encode(e)).bytes);
  return 'login.$b64';
}

void main() {
  test('set & verify by email (hashed key namespace)', () async {
    final MockFlutterSecureStorage storage = MockFlutterSecureStorage();
    final LocalLoginRepo repo = LocalLoginRepo(
      storage: storage,
      hasher: FakeHasher(),
    );

    // Stub write({key, value, ...}) and read({key, ...}) including extra named params
    when(
      storage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
        aOptions: anyNamed('aOptions'),
        iOptions: anyNamed('iOptions'),
        lOptions: anyNamed('lOptions'),
        webOptions: anyNamed('webOptions'),
        mOptions: anyNamed('mOptions'),
        wOptions: anyNamed('wOptions'),
      ),
    ).thenAnswer((_) => Future<void>.value());

    when(
      storage.read(
        key: anyNamed('key'),
        aOptions: anyNamed('aOptions'),
        iOptions: anyNamed('iOptions'),
        lOptions: anyNamed('lOptions'),
        webOptions: anyNamed('webOptions'),
        mOptions: anyNamed('mOptions'),
        wOptions: anyNamed('wOptions'),
      ),
    ).thenAnswer((_) async => 'H(secret)');

    // Act
    const String email = 'a@b.co';
    await repo.setForEmail(email, 'secret');
    final bool ok = await repo.verifyForEmail(email, 'secret');
    expect(ok, isTrue);

    // Assert exact key used
    final String expectedKey = hashedKeyFor(email);

    verify(
      storage.write(
        key: expectedKey,
        value: 'H(secret)',
        aOptions: anyNamed('aOptions'),
        iOptions: anyNamed('iOptions'),
        lOptions: anyNamed('lOptions'),
        webOptions: anyNamed('webOptions'),
        mOptions: anyNamed('mOptions'),
        wOptions: anyNamed('wOptions'),
      ),
    ).called(1);

    verify(
      storage.read(
        key: expectedKey,
        aOptions: anyNamed('aOptions'),
        iOptions: anyNamed('iOptions'),
        lOptions: anyNamed('lOptions'),
        webOptions: anyNamed('webOptions'),
        mOptions: anyNamed('mOptions'),
        wOptions: anyNamed('wOptions'),
      ),
    ).called(1);
  });
}
