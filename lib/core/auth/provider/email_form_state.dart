// lib/features/auth/application/email_form_provider.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'email_form_state.freezed.dart';
part 'email_form_state.g.dart';

@freezed
abstract class EmailFormState with _$EmailFormState {
  const factory EmailFormState({
    @Default('') String email,
    @Default(false) bool isDirty,
  }) = _EmailFormState;

  const EmailFormState._();

  bool get isValid => _isValidEmail(email);
  bool get canSubmit => isValid;

  static bool _isValidEmail(String value) {
    final RegExp re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(value.trim());
  }
}

@riverpod
class EmailFormNotifier extends _$EmailFormNotifier {
  @override
  EmailFormState build() => const EmailFormState();

  void setEmail(String value) {
    state = state.copyWith(email: value, isDirty: true);
  }
}
