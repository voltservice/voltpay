// lib/features/auth/application/login_password_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_login_password_provider.g.dart';

@riverpod
class LoginPassword extends _$LoginPassword {
  @override
  String build() => '';
  void set(String v) => state = v;
  bool get hasValue => state.isNotEmpty;
}
