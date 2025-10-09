import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/core/utils/buttons/app_back_button.dart';
import 'package:voltpay/features/currency/domain/currency.dart';
import 'package:voltpay/features/currency/presentation/currency_picker.dart';
import 'package:voltpay/features/rates/domain/fee_line.dart';
import 'package:voltpay/features/rates/domain/pay_method_type.dart';
import 'package:voltpay/features/rates/domain/quote.dart';
import 'package:voltpay/features/rates/presentation/widgets/free_row.dart';
import 'package:voltpay/features/rates/presentation/widgets/method_link.dart';
import 'package:voltpay/features/rates/presentation/widgets/payment_card.dart';
import 'package:voltpay/features/rates/presentation/widgets/payment_method_sheet.dart';
import 'package:voltpay/features/rates/presentation/widgets/recipient_card.dart';
import 'package:voltpay/features/rates/presentation/widgets/skeleton.dart';
import 'package:voltpay/features/rates/providers/quote_provider.dart';

class RatesPage extends ConsumerStatefulWidget {
  const RatesPage({super.key});
  @override
  ConsumerState<RatesPage> createState() => _RatesPageState();
}

class _RatesPageState extends ConsumerState<RatesPage> {
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    final dynamic p = ref.read(quoteParamsProvider);
    _amountCtrl = TextEditingController(text: p.amount.toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final QuoteParams params = ref.watch(quoteParamsProvider);
    final AsyncValue<Quote> quoteAsync = ref.watch(quoteProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Rates'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(quoteProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            const SizedBox(height: 8),
            Text(
              'You send exactly',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            AmountCard(
              controller: _amountCtrl,
              currency: params.source,
              onChanged: (String v) {
                final double parsed = double.tryParse(v) ?? 0;
                // ref.read(quoteParamsProvider.notifier).state = params.copyWith(
                //   amount: parsed,
                // );
                ref.read(quoteParamsProvider.notifier).patch(amount: parsed);
              },
              onPickCurrency: () async {
                final Currency? picked = await showCurrencyPicker(context, ref);
                if (picked != null && mounted) {
                  ref
                      .read(quoteParamsProvider.notifier)
                      .patch(source: picked.code);
                  // triggers re-fetch automatically via quoteFutureProvider
                  final AsyncValue<Quote> _ = ref.refresh(quoteProvider);
                }
              },
            ),
            const SizedBox(height: 16),
            quoteAsync.when(
              loading: () => Skeleton(scheme: scheme),
              error: (Object e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Failed to load quote: $e',
                  style: TextStyle(color: scheme.error),
                ),
              ),
              data: (Quote q) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FeeRow(
                    scheme: scheme,
                    bullet: Icons.circle,
                    left:
                        '${q.fees.firstWhere((FeeLine f) => f.label.contains("Wire"), orElse: () => q.fees.first).amount.toStringAsFixed(2)} ${q.sourceCurrency}',
                    rightWidget: MethodLink(
                      label: params.method.feeLinkLabel,
                      onTap: () async {
                        // open modal and update method
                        final PaymentMethodType? chosen =
                            await showPaymentMethodSheet(
                          context,
                          ref,
                          selected: params.method,
                        );
                        if (chosen != null && mounted) {
                          ref
                              .read(quoteParamsProvider.notifier)
                              .patch(method: chosen);
                          // refresh quote
                          final AsyncValue<Quote> _ = ref.refresh(
                            quoteProvider,
                          );
                          // Use the result, for example, by awaiting it or logging it.
                        }
                      },
                    ),
                  ),
                  if (q.fees.length > 1)
                    FeeRow(
                      scheme: scheme,
                      bullet: Icons.circle,
                      left:
                          '${q.fees[1].amount.toStringAsFixed(2)} ${q.sourceCurrency}',
                      rightText: 'Our fee',
                    ),
                  FeeRow(
                    scheme: scheme,
                    bullet: Icons.drag_handle_rounded,
                    left:
                        '${q.amountConverted.toStringAsFixed(2)} ${q.sourceCurrency}',
                    rightText: "Total amount we'll convert",
                  ),
                  FeeRow(
                    scheme: scheme,
                    bullet: Icons.close,
                    left: q.rate.toString(),
                    rightLinkText:
                        'Guaranteed exchange rate (${q.guarantee.inHours}h)',
                    onRightTap: () {
                      /* info dialog */
                    },
                  ),
                  const SizedBox(height: 16),
                  RecipientCard(
                    amount: q.recipientAmount.toStringAsFixed(2),
                    currency: q.targetCurrency,
                    onPickCurrency: () async {
                      final Currency? picked = await showCurrencyPicker(
                        context,
                        ref,
                      );
                      if (picked != null && mounted) {
                        ref
                            .read(quoteParamsProvider.notifier)
                            .patch(target: picked.code);
                        // Use the result, for example, by awaiting it or logging it.
                        final AsyncValue<Quote> _ = ref.refresh(quoteProvider);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        const TextSpan(text: "You'll save up to "),
                        TextSpan(
                          text:
                              '${(q.sourceAmount * 0.01919).toStringAsFixed(2)} ${q.sourceCurrency}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: '.\nShould arrive '),
                        TextSpan(
                          text: 'in ${q.arrivalEta.inHours} hours',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      /* compare screen */
                    },
                    child: Text(
                      'Compare price',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: const StadiumBorder(),
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
          ),
          onPressed: () {
            /* continue flow */
          },
          child: const Text('Get started', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
