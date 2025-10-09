import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voltpay/features/rates/domain/fee_line.dart';

part 'quote.freezed.dart';
part 'quote.g.dart';

@freezed
abstract class Quote with _$Quote {
  const factory Quote({
    required String sourceCurrency, // "USD"
    required String targetCurrency, // "EUR"
    required double sourceAmount, // 1000
    required double rate, // 0.8517
    required double recipientAmount, // 843.27 (server-computed)
    required List<FeeLine> fees, // breakdown lines
    required int guaranteeSeconds, // 11h -> 39600
    required int arrivalSeconds, // 4h   -> 14400
  }) = _Quote;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
}

extension QuoteX on Quote {
  double get totalFees => fees.fold(0.0, (double p, FeeLine e) => p + e.amount);
  double get amountConverted => sourceAmount - totalFees;
  Duration get guarantee => Duration(seconds: guaranteeSeconds);
  Duration get arrivalEta => Duration(seconds: arrivalSeconds);
}
