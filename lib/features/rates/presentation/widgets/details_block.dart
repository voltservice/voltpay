import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <- add this
import 'package:voltpay/features/rates/domain/fee_line.dart';
import 'package:voltpay/features/rates/domain/pay_method_type.dart';
import 'package:voltpay/features/rates/domain/quote.dart';
import 'package:voltpay/features/rates/presentation/widgets/change_chip.dart';
import 'package:voltpay/features/rates/presentation/widgets/free_row.dart';
import 'package:voltpay/features/rates/presentation/widgets/payment_method_sheet.dart';
import 'package:voltpay/features/rates/providers/quote_provider.dart';

class DetailsBlock extends ConsumerWidget {
  const DetailsBlock({
    required this.params,
    required this.quote,
    required this.scheme,
  });
  final QuoteParams params;
  final Quote quote;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FeeLine wireOrFirst = quote.fees.firstWhere(
      (FeeLine f) => f.label.toLowerCase().contains('wire'),
      orElse: () => quote.fees.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Paying with…
        FeeRow(
          scheme: scheme,
          bullet: Icons.account_balance_rounded,
          left: 'Paying with',
          rightWidget: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                params.method.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              ChangeChip(
                onTap: () async {
                  final PaymentMethodType? chosen =
                      await showPaymentMethodSheet(
                        context,
                        ref,
                        selected: params.method,
                      );
                  if (chosen != null) {
                    ref
                        .read(quoteParamsProvider.notifier)
                        .patch(method: chosen);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Arrival estimate
        FeeRow(
          scheme: scheme,
          bullet: Icons.bolt_rounded,
          left: 'Arrives',
          rightWidget: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Today - in ${quote.arrivalEta.inHours}h',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              ChangeChip(
                onTap: () {
                  /* choose speed sheet */
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Fees line
        FeeRow(
          scheme: scheme,
          bullet: Icons.receipt_long_rounded,
          left: 'Included in ${quote.sourceCurrency} amount',
          rightText:
              '${wireOrFirst.amount.toStringAsFixed(2)} ${quote.sourceCurrency} >',
        ),

        const SizedBox(height: 8),

        // What we’ll convert
        FeeRow(
          scheme: scheme,
          bullet: Icons.drag_handle_rounded,
          left:
              '${quote.amountConverted.toStringAsFixed(2)} ${quote.sourceCurrency}',
          rightText: "Total amount we'll convert",
        ),
        const SizedBox(height: 8),
        // Guaranteed rate
        FeeRow(
          scheme: scheme,
          bullet: Icons.lock_clock_rounded,
          left: quote.rate.toString(),
          rightLinkText: 'Guaranteed rate (${quote.guarantee.inHours}h)',
          onRightTap: () {
            // show info dialog
          },
        ),
      ],
    );
  }
}
