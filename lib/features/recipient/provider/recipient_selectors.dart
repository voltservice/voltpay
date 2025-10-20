// lib/features/recipient/providers/recipient_selectors.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/features/recipient/provider/recipient_controller.dart';
import 'package:voltpay/features/recipient/provider/recipient_provider.dart';

final Provider<RecipientMethod> recipientMethodProvider =
    Provider<RecipientMethod>((Ref ref) {
      final RecipientParams p = ref.watch(recipientControllerProvider);
      return p.method;
    });

final Provider<bool> recipientValidProvider = Provider<bool>((Ref ref) {
  final RecipientParams p = ref.watch(recipientControllerProvider);
  return p.isMeaningful;
});

final Provider<Map<String, Object?>> recipientPayloadProvider =
    Provider<Map<String, Object?>>((Ref ref) {
      final RecipientParams p = ref.watch(recipientControllerProvider);
      return p.toPayload();
    });
