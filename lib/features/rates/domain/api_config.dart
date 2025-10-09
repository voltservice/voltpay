import 'package:voltpay/features/rates/domain/pay_method_type.dart';

class ApiConfig {
  const ApiConfig(this.baseUrl);

  /// Expect this to be the service root; with or without trailing `/api`.
  final String baseUrl;

  String get _apiBase => baseUrl.endsWith('/api') ? baseUrl : '$baseUrl/api';

  Uri quotesUri({
    required String source,
    required String target,
    required double amount,
    required PaymentMethodType method,
  }) {
    final Map<String, String> q = <String, String>{
      'source': source,
      'target': target,
      'amount': amount.toStringAsFixed(2),
      'method': method.asParam,
    };
    return Uri.parse('$_apiBase/quotes').replace(queryParameters: q);
  }

  Uri healthUri() => Uri.parse('$_apiBase/health');
}

extension PaymentMethodTypeX on PaymentMethodType {
  String get asParam => switch (this) {
        PaymentMethodType.wire => 'wire',
        PaymentMethodType.debitCard => 'debitCard',
        PaymentMethodType.creditCard => 'creditCard',
        PaymentMethodType.accountTransfer => 'accountTransfer',
      };
}
