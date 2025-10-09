import 'package:voltpay/features/rates/domain/pay_method_type.dart';
import 'package:voltpay/features/rates/domain/quote.dart';

abstract class QuoteRepository {
  Future<Quote> getQuote({
    required String source,
    required String target,
    required double amount,
    required PaymentMethodType method,
  });
}
