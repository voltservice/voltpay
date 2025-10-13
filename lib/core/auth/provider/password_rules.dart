import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_rules.freezed.dart';

@freezed
abstract class PasswordRules with _$PasswordRules {
  const factory PasswordRules({
    @Default(false) bool hasMinLength,
    @Default(false) bool hasUpperCase,
    @Default(false) bool hasLowerCase,
    @Default(false) bool hasDigit,
    @Default(false) bool hasSpecialChar,
  }) = _PasswordRules;

  const PasswordRules._();

  factory PasswordRules.eval(String password) {
    return PasswordRules(
      hasMinLength: password.length >= 8,
      hasUpperCase: password.contains(RegExp(r'[A-Z]')),
      hasLowerCase: password.contains(RegExp(r'[a-z]')),
      hasDigit: password.contains(RegExp(r'[0-9]')),
      hasSpecialChar: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    );
  }

  bool get valid =>
      hasMinLength &&
      hasUpperCase &&
      hasLowerCase &&
      hasDigit &&
      hasSpecialChar;
}
