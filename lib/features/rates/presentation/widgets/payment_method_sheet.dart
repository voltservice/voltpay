import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/features/rates/domain/pay_method_type.dart';
import 'package:voltpay/features/rates/domain/payment_method.dart';
import 'package:voltpay/features/rates/presentation/widgets/payment_row.dart';
import 'package:voltpay/features/rates/providers/payment_provider.dart';

Future<PaymentMethodType?> showPaymentMethodSheet(
  BuildContext context,
  WidgetRef ref, {
  required PaymentMethodType? selected,
}) {
  ref.read(paymentMethodsProvider.notifier).build();

  return showModalBottomSheet<PaymentMethodType>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext ctx) {
      final AsyncValue<List<PaymentMethodOption>> asyncList = ref.watch(
        paymentMethodsProvider,
      );

      return asyncList.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (dynamic e, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Failed to load payment methods: $e'),
        ),
        data: (List<PaymentMethodOption> methods) => ListView(
          shrinkWrap: true,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                'Choose a payment method',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            for (final PaymentMethodOption m in methods)
              PaymentMethodRow(
                key: ValueKey<PaymentMethodType>(m.type),
                method: m,
                selected: selected == m.type,
                onTap: m.available ? () => Navigator.of(ctx).pop(m.type) : null,
              ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}
