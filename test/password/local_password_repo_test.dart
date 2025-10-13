// test/password_providers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:voltpay/core/auth/interface/i_password_hasher.dart';
import 'package:voltpay/core/auth/model/auth_user_model.dart';
import 'package:voltpay/core/auth/repository/local_password_repo.dart';

// generated mocks
import '../mocks.mocks.dart';

/// Optional fake hasher if you want to override passwordHasherProvider
class _FakeHasher implements IPasswordHasher {
  _FakeHasher({this.needsRehashFlag = false});
  bool needsRehashFlag;

  @override
  Future<String> hash(String password) async => 'HASH($password)';

  @override
  Future<bool> verify(String password, String stored) async =>
      stored == 'HASH($password)' || stored == 'OLD($password)';

  @override
  bool needsRehash(String stored) => needsRehashFlag;
}

void main() {
  late MockFlutterSecureStorage storage;
  late IPasswordHasher hasher;
  late AuthUserModel u1;
  late AuthUserModel u2;

  setUp(() {
    storage = MockFlutterSecureStorage();
    hasher = _FakeHasher();
    u1 = const AuthUserModel(uid: 'u-123');
    u2 = const AuthUserModel(uid: 'u-456');
  });

  test('setPaymentPassword writes hashed under per-user key', () async {
    final LocalPasswordRepo repo = LocalPasswordRepo(
      storage: storage,
      hasher: hasher,
      user: u1,
    );

    when(
      storage.write(key: anyNamed('key'), value: anyNamed('value')),
    ).thenAnswer((_) async {});

    await repo.setPaymentPassword('p@ss');

    verify(
      storage.write(key: 'payment_password_v1_u-123', value: 'HASH(p@ss)'),
    ).called(1);
  });

  test('verify true for correct password; false otherwise', () async {
    final LocalPasswordRepo repo = LocalPasswordRepo(
      storage: storage,
      hasher: hasher,
      user: u1,
    );
    when(
      storage.read(key: anyNamed('key')),
    ).thenAnswer((_) async => 'HASH(p@ss)');

    expect(await repo.verify('p@ss'), isTrue);
    expect(await repo.verify('nope'), isFalse);
  });

  test('verify false when nothing stored', () async {
    final LocalPasswordRepo repo = LocalPasswordRepo(
      storage: storage,
      hasher: hasher,
      user: u1,
    );
    when(storage.read(key: anyNamed('key'))).thenAnswer((_) async => null);

    expect(await repo.verify('x'), isFalse);
  });

  test('per-user namespacing', () async {
    final LocalPasswordRepo repo1 = LocalPasswordRepo(
      storage: storage,
      hasher: hasher,
      user: u1,
    );
    final LocalPasswordRepo repo2 = LocalPasswordRepo(
      storage: storage,
      hasher: hasher,
      user: u2,
    );

    when(
      storage.read(key: 'payment_password_v1_u-123'),
    ).thenAnswer((_) async => 'HASH(p1)');
    when(
      storage.read(key: 'payment_password_v1_u-456'),
    ).thenAnswer((_) async => 'HASH(p2)');

    expect(await repo1.verify('p1'), isTrue);
    expect(await repo1.verify('p2'), isFalse);

    expect(await repo2.verify('p2'), isTrue);
    expect(await repo2.verify('p1'), isFalse);
  });

  test('rehash on verify when needsRehash=true', () async {
    final LocalPasswordRepo repo = LocalPasswordRepo(
      storage: storage,
      hasher: _FakeHasher(needsRehashFlag: true),
      user: u1,
    );

    when(
      storage.read(key: 'payment_password_v1_u-123'),
    ).thenAnswer((_) async => 'OLD(p@ss)');
    when(
      storage.write(key: anyNamed('key'), value: anyNamed('value')),
    ).thenAnswer((_) async {});

    expect(await repo.verify('p@ss'), isTrue);

    verify(
      storage.write(key: 'payment_password_v1_u-123', value: 'HASH(p@ss)'),
    ).called(1);
  });
}
