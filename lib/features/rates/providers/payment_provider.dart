// lib/features/rates/providers/payment_methods_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:voltpay/features/rates/domain/payment_method.dart';
import 'package:voltpay/features/rates/infrastructure/payment_method_repository.dart';
import 'package:voltpay/features/rates/providers/rate_providers.dart';

part 'payment_provider.g.dart';

/// In Riverpod 3, we use @riverpod to create an AsyncNotifier that exposes
/// AsyncValue<List<PaymentMethodOption) automatically.
@riverpod
class PaymentMethods extends _$PaymentMethods {
  @override
  FutureOr<List<PaymentMethodOption>> build() async {
    // Repository injected via ref
    final PaymentMethodRepository repo = ref.read(paymentMethodRepoProvider);

    // You can await repo.loadAll() or similar
    final List<PaymentMethodOption> list = await repo.list();

    return list;
  }

  /// Optional manual refresh
  Future<void> refresh() async {
    state = const AsyncLoading<List<PaymentMethodOption>>();
    try {
      final PaymentMethodRepository repo = ref.read(paymentMethodRepoProvider);
      final List<PaymentMethodOption> list = await repo.list();
      state = AsyncData<List<PaymentMethodOption>>(list);
    } catch (e, st) {
      state = AsyncError<List<PaymentMethodOption>>(e, st);
    }
  }

  /// Optional filter method etc.
  void select(PaymentMethodOption option) {
    // Example mutation — if your controller logic needs to track selection
  }
}
