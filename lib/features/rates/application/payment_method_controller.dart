// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:voltpay/features/rates/domain/payment_method.dart';
// import 'package:voltpay/features/rates/infrastructure/payment_method_repository.dart';
//
// class PaymentMethodController
//     extends StateNotifier<AsyncValue<List<PaymentMethodOption>>> {
//   PaymentMethodController(this._repo)
//     : super(const AsyncLoading<List<PaymentMethodOption>>());
//   final PaymentMethodRepository _repo;
//
//   Future<void> load() async {
//     try {
//       state = const AsyncLoading<List<PaymentMethodOption>>();
//       final List<PaymentMethodOption> list = await _repo.list();
//       state = AsyncData<List<PaymentMethodOption>>(list);
//     } catch (e, st) {
//       state = AsyncError<List<PaymentMethodOption>>(e, st);
//     }
//   }
// }
