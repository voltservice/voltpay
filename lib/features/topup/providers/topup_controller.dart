import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:voltpay/features/paymentmethod/domain/pay_method_type.dart';
import 'package:voltpay/features/topup/domain/topup_params.dart';

part 'topup_controller.g.dart';

@riverpod
class TopUpController extends _$TopUpController {
  @override
  TopUpParams build() => const TopUpParams();

  void setAmount(double v) => state = state.copyWith(amount: v < 0 ? 0 : v);
  void setCurrency(String code) => state = state.copyWith(currency: code);
  void setPayMethod(PayMethodType t) => state = state.copyWith(payMethod: t);
  void setArrival(String label) => state = state.copyWith(arrivalLabel: label);
}
