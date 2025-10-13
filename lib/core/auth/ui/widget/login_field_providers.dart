import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:voltpay/core/auth/provider/email_form_state.dart';

part 'login_field_providers.g.dart';

/// Focus node for the email field (auto-disposed when the widget goes away)
@riverpod
FocusNode emailFocusNode(Ref ref) {
  final FocusNode fn = FocusNode();
  ref.onDispose(fn.dispose);
  return fn;
}

/// Controller for the email field, synced with EmailFormState
@riverpod
TextEditingController emailController(Ref ref) {
  final String initial = ref.read(emailFormProvider).email;
  final TextEditingController ctl = TextEditingController(text: initial);

  // Keep controller -> provider in sync
  void pushToProvider() {
    final String text = ctl.text;
    if (ref.read(emailFormProvider).email != text) {
      ref.read(emailFormProvider.notifier).setEmail(text);
    }
  }

  ctl.addListener(pushToProvider);

  // Keep provider -> controller in sync (but don't fight the user while typing)
  final FocusNode fn = ref.read(emailFocusNodeProvider);
  ref.listen(emailFormProvider, (EmailFormState? prev, EmailFormState next) {
    if (!fn.hasFocus && ctl.text != next.email) {
      ctl.text = next.email;
      ctl.selection = TextSelection.collapsed(offset: ctl.text.length);
    }
  });

  ref.onDispose(() {
    ctl.removeListener(pushToProvider);
    ctl.dispose();
  });
  return ctl;
}
