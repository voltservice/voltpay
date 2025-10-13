import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voltpay/core/auth/provider/password_rules.dart';

part 'password_state.freezed.dart';
part 'password_state.g.dart';

@freezed
abstract class PasswordState with _$PasswordState {
  const factory PasswordState({
    @Default('') String password,
    @Default('') String confirm,
    @Default(true) bool obscure1,
    @Default(true) bool obscure2,
  }) = _PasswordState;

  factory PasswordState.fromJson(Map<String, dynamic> json) =>
      _$PasswordStateFromJson(json);
}

extension PasswordStateX on PasswordState {
  PasswordRules get rules => PasswordRules.eval(password);
  bool get matches => confirm.isNotEmpty && confirm == password;
  bool get canSubmit => rules.valid && matches;
  bool get canClear => password.isNotEmpty;
  bool get canConfirm => confirm.isNotEmpty;
  bool get canToggle => password.isNotEmpty;
  bool get canToggleConfirm => confirm.isNotEmpty;
  bool get canToggleObscure1 => password.isNotEmpty;
  bool get canToggleObscure2 => confirm.isNotEmpty;
}
