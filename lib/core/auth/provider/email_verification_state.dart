// lib/features/auth/application/email_verification_provider.dart
import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'email_verification_state.freezed.dart';
part 'email_verification_state.g.dart';

@freezed
abstract class EmailVerificationState with _$EmailVerificationState {
  const factory EmailVerificationState({
    @Default('user@example.com') String email,
    @Default(120) int remainingSeconds,
    @Default(false) bool canResend,
  }) = _EmailVerificationState;

  const EmailVerificationState._();

  String get mmSs {
    final int mm = remainingSeconds ~/ 60;
    final int ss = remainingSeconds % 60;
    return '${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
  }
}

@riverpod
class EmailVerificationNotifier extends _$EmailVerificationNotifier {
  Timer? _ticker;

  @override
  EmailVerificationState build(
      {required String email, int initialCountdown = 120}) {
    // initialize countdown
    final EmailVerificationState init = EmailVerificationState(
      email: email,
      remainingSeconds: initialCountdown,
    );
    _start();
    ref.onDispose(() => _ticker?.cancel());
    return init;
  }

  void _start() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final int next = state.remainingSeconds - 1;
      if (next <= 0) {
        timer.cancel();
        state = state.copyWith(remainingSeconds: 0, canResend: true);
      } else {
        state = state.copyWith(remainingSeconds: next);
      }
    });
  }

  void restartCountdown({int seconds = 120}) {
    state = state.copyWith(remainingSeconds: seconds, canResend: false);
    _start();
  }
}
