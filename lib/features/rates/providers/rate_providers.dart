import 'package:riverpod/riverpod.dart';
import 'package:voltpay/features/rates/infrastructure/payment_method_repository.dart';

final Provider<PaymentMethodRepository> paymentMethodRepoProvider =
    Provider<PaymentMethodRepository>(
  (Ref ref) => InMemoryPaymentMethodRepository(),
);
