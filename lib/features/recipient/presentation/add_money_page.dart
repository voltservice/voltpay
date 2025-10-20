import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/router/app_routes.dart';
import 'package:voltpay/core/utils/buttons/app_cancel_button.dart';
import 'package:voltpay/features/currency/domain/currency.dart';
import 'package:voltpay/features/currency/presentation/currency_picker.dart';
import 'package:voltpay/features/rates/domain/quote.dart'; // your existing AmountCard
import 'package:voltpay/features/rates/presentation/widgets/details_block.dart';
import 'package:voltpay/features/rates/presentation/widgets/error_txt.dart';
import 'package:voltpay/features/rates/presentation/widgets/payment_card.dart';
import 'package:voltpay/features/rates/presentation/widgets/rate_pill.dart';
import 'package:voltpay/features/rates/presentation/widgets/recipient_card.dart';
import 'package:voltpay/features/rates/presentation/widgets/skeleton.dart';
import 'package:voltpay/features/rates/providers/quote_provider.dart';
import 'package:voltpay/features/recipient/ui/layout/center_width.dart';
import 'package:voltpay/features/recipient/ui/layout/section_card.dart';
import 'package:with_opacity/with_opacity.dart';

class AddMoneyPage extends ConsumerStatefulWidget {
  const AddMoneyPage({super.key});
  @override
  ConsumerState<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends ConsumerState<AddMoneyPage> {
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    final QuoteParams p = ref.read(quoteParamsProvider);
    _amountCtrl = TextEditingController(
      text: p.amount <= 0 ? '' : p.amount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    final QuoteParams params = ref.watch(quoteParamsProvider);
    final AsyncValue<Quote> quoteAsync = ref.watch(quoteProvider);

    final bool hasAmount = params.amount > 0;

    // inside AddMoneyPage build()
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(quoteProvider.future),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: <Widget>[
            CenterWidth(
              maxWidth: 720,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Top: close + pill in one row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        AppCloseButton(
                          onPressed: () => context.goNamed(AppRoute.home.name),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: RatePill(
                              leading: params.source,
                              trailing: params.target,
                              quoteAsync: quoteAsync,
                              // gradient: BrandGradients.notification,
                              gradient: LinearGradient(
                                colors: <Color>[
                                  const Color(
                                    0xFF1B4D4F,
                                  ).withCustomOpacity(0.85), // deep teal 85%
                                  const Color(
                                    0xFF2D2D34,
                                  ).withCustomOpacity(0.65), // charcoal fade
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section: You send
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'You send',
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AmountCard(
                            controller: _amountCtrl,
                            currency: params.source,
                            onChanged: (String v) {
                              final double parsed = double.tryParse(v) ?? 0;
                              ref
                                  .read(quoteParamsProvider.notifier)
                                  .patch(amount: parsed);
                            },
                            onPickCurrency: () async {
                              final Currency? picked = await showCurrencyPicker(
                                context,
                                ref,
                              );
                              if (picked != null && mounted) {
                                ref
                                    .read(quoteParamsProvider.notifier)
                                    .patch(source: picked.code);
                                _amountCtrl.text = params.amount
                                    .toStringAsFixed(0);
                                _amountCtrl
                                    .selection = TextSelection.fromPosition(
                                  TextPosition(offset: _amountCtrl.text.length),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Section: Recipient (only when amount > 0)
                  if (hasAmount)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: quoteAsync.when(
                        loading: () =>
                            SectionCard(child: Skeleton(scheme: scheme)),
                        error: (Object e, _) => SectionCard(
                          child: ErrorText(error: e.toString(), scheme: scheme),
                        ),
                        data: (Quote q) => SectionCard(
                          child: RecipientCard(
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
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                  // Section: Details (only when amount > 0)
                  if (hasAmount)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: quoteAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (Object e, _) => const SizedBox.shrink(),
                        data: (Quote q) => SectionCard(
                          child: DetailsBlock(
                            params: params,
                            quote: q,
                            scheme: scheme,
                          ),
                          margin: const EdgeInsets.only(
                            top: 0,
                            bottom: 16,
                            left: 0,
                            right: 0,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom CTA
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: const StadiumBorder(),
              backgroundColor: hasAmount
                  ? scheme.primary
                  : scheme.onSurfaceVariant,
              foregroundColor: hasAmount ? scheme.onPrimary : scheme.onSurface,
              disabledForegroundColor: scheme.onSurface.withCustomOpacity(.38),
              disabledBackgroundColor: scheme.onSurface.withCustomOpacity(.12),
            ),
            onPressed: hasAmount
                ? () {
                    // navigate to recipient picker / add recipient flow
                    context.goNamed(AppRoute.recipientPicker.name);
                  }
                : null,
            child: Text(
              hasAmount ? 'Add recipient' : 'Continue',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
