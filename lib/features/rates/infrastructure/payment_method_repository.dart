import 'package:voltpay/features/rates/domain/pay_method_type.dart';
import 'package:voltpay/features/rates/domain/payment_method.dart';

abstract class PaymentMethodRepository {
  Future<List<PaymentMethodOption>> list();
}

class InMemoryPaymentMethodRepository implements PaymentMethodRepository {
  @override
  Future<List<PaymentMethodOption>> list() async => const <PaymentMethodOption>[
        PaymentMethodOption(
          type: PaymentMethodType.wire,
          title: 'Wire Transfer',
          subtitle: '6.11 USD fee, should arrive by Thursday',
          fixedFee: 6.11,
          available: true,
        ),
        PaymentMethodOption(
          type: PaymentMethodType.debitCard,
          title: 'Debit Card',
          subtitle: '12.35 USD fee, should arrive by Thursday',
          fixedFee: 12.35,
          available: true,
        ),
        PaymentMethodOption(
          type: PaymentMethodType.creditCard,
          title: 'Credit Card',
          subtitle: '61.65 USD fee, should arrive by Thursday',
          fixedFee: 61.65,
          available: true,
        ),
        PaymentMethodOption(
          type: PaymentMethodType.accountTransfer,
          title: 'Account transfer',
          subtitle:
              'Sorry, using a multi currency account isn’t available in your country.',
          fixedFee: 0,
          available: false,
        ),
      ];
}
