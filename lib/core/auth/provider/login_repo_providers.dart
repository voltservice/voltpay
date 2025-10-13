// lib/core/auth/provider/login_repo_providers.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:voltpay/core/auth/interface/i_password_hasher.dart';
import 'package:voltpay/core/auth/repository/local_login_repo.dart';
import 'package:voltpay/core/auth/service/password_hasher_composite.dart';

part 'login_repo_providers.g.dart';

@riverpod
FlutterSecureStorage loginSecureStorage(Ref ref) =>
    const FlutterSecureStorage();

@riverpod
IPasswordHasher loginPasswordHasher(Ref ref) => PasswordHasherComposite();

@riverpod
LocalLoginRepo localLoginRepo(Ref ref) => LocalLoginRepo(
  storage: ref.watch(loginSecureStorageProvider),
  hasher: ref.watch(loginPasswordHasherProvider),
);
