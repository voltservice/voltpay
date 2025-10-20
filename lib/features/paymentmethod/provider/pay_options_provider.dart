import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/features/paymentmethod/domain/pay_method_type.dart';
import 'package:voltpay/features/paymentmethod/domain/pay_option.dart';
import 'package:voltpay/features/topup/domain/topup_params.dart';
import 'package:voltpay/features/topup/providers/topup_controller.dart';

/// All options for current top-up context (currency/amount).
final Provider<List<PayOption>> payOptionsProvider = Provider<List<PayOption>>((
  Ref ref,
) {
  final TopUpParams s = ref.watch(topUpControllerProvider);
  final String ccy = s.currency;

  // You can compute fees by amount/method here or fetch from backend.
  return <PayOption>[
    PayOption(
      type: PayMethodType.bankTransfer,
      feeCurrency: ccy,
      feeAmount: 0.00,
      etaLabel: 'in seconds',
    ),
    PayOption(
      type: PayMethodType.debitCard,
      feeCurrency: ccy,
      feeAmount: 0.33,
      etaLabel: 'in seconds',
    ),
    PayOption(
      type: PayMethodType.creditCard,
      feeCurrency: ccy,
      feeAmount: 1.14,
      etaLabel: 'in seconds',
    ),
    PayOption(
      type: PayMethodType.swiftTransfer,
      feeCurrency: ccy,
      feeAmount: 0.00,
      etaLabel: 'by tuesday',
    ),
  ];
});

/// Cheapest subset (ties kept in order).
final Provider<List<PayOption>> cheapestPayOptionsProvider =
    Provider<List<PayOption>>((Ref ref) {
      final List<PayOption> all = ref.watch(payOptionsProvider);
      if (all.isEmpty) {
        return const <PayOption>[];
      }
      final double minFee = all
          .map((PayOption e) => e.feeAmount)
          .reduce((double a, double b) => a < b ? a : b);
      return all.where((PayOption o) => o.feeAmount == minFee).toList();
    });
