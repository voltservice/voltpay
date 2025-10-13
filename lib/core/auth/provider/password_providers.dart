import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:voltpay/core/auth/interface/i_password.dart';
import 'package:voltpay/core/auth/interface/i_password_hasher.dart';
import 'package:voltpay/core/auth/model/auth_user_model.dart';
import 'package:voltpay/core/auth/provider/auth_user_provider.dart';
import 'package:voltpay/core/auth/repository/local_password_repo.dart';
import 'package:voltpay/core/auth/service/password_hasher_argon2id.dart';
import 'package:voltpay/core/auth/service/password_hasher_composite.dart';

part 'password_providers.g.dart';

@riverpod
FlutterSecureStorage secureStorage(Ref ref) => const FlutterSecureStorage();

@riverpod
IPasswordHasher passwordHasherArgon2(Ref ref) => PasswordHasherArgon2id();

@riverpod
IPasswordHasher passwordHasher(Ref ref) => PasswordHasherComposite();

@riverpod
Future<IPasswordRepo> passwordRepo(Ref ref) async {
  final FlutterSecureStorage storage = ref.watch(secureStorageProvider);
  final IPasswordHasher hasher = ref.watch(passwordHasherProvider);
  final AuthUserModel? user = await ref.watch(authUserProvider.future);
  if (user == null) {
    throw StateError('No signed-in user.');
  }
  return LocalPasswordRepo(storage: storage, hasher: hasher, user: user);
}

@riverpod
String chosenHasherType(Ref ref) =>
    ref.watch(passwordHasherProvider).runtimeType.toString();
