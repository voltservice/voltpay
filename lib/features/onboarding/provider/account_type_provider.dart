import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_type_provider.freezed.dart';
part 'account_type_provider.g.dart';

enum AccountType { unknown, personal, business }

@freezed
abstract class AccountTypeState with _$AccountTypeState {
  const factory AccountTypeState({
    @Default(AccountType.unknown) AccountType selected,
  }) = _AccountTypeState;
}

@riverpod
class AccountTypeNotifier extends _$AccountTypeNotifier {
  @override
  AccountTypeState build() => const AccountTypeState();

  void choose(AccountType type) {
    state = state.copyWith(selected: type);
  }
}
