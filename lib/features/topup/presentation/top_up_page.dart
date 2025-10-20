import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/router/app_routes.dart';
import 'package:voltpay/core/utils/buttons/app_back_button.dart'; // your dynamic back
import 'package:voltpay/features/currency/domain/currency.dart';
import 'package:voltpay/features/currency/presentation/currency_picker.dart';
import 'package:voltpay/features/currency/provider/currency_family_provider.dart';
import 'package:voltpay/features/paymentmethod/domain/pay_method_type.dart';
import 'package:voltpay/features/rates/presentation/widgets/change_chip.dart';
import 'package:voltpay/features/rates/presentation/widgets/payment_card.dart'; // AmountCard
import 'package:voltpay/features/recipient/ui/layout/section_card.dart';
import 'package:voltpay/features/topup/domain/topup_params.dart';
import 'package:voltpay/features/topup/providers/topup_controller.dart';
import 'package:with_opacity/with_opacity.dart';

class TopUpPage extends ConsumerStatefulWidget {
  const TopUpPage({super.key});
  @override
  ConsumerState<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends ConsumerState<TopUpPage> {
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    final TopUpParams s = ref.read(topUpControllerProvider);
    _amountCtrl = TextEditingController(
      text: s.amount <= 0 ? '' : s.amount.toStringAsFixed(2),
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
    final TopUpParams s = ref.watch(topUpControllerProvider);
    final TopUpController c = ref.read(topUpControllerProvider.notifier);
    final bool hasAmount = s.isValid;
    final Currency? cur = ref.watch(currencyByCodeProvider(s.currency));
    final String displayName = cur?.name ?? s.currency;
    final String displayFlag = cur?.flag ?? '🏳️';
    final String chosen = s.payMethod.label;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(), // pops by default
        title: const Text(''),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: <Widget>[
          Text(
            'You add',
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Amount input (reuses your AmountCard styling)
          AmountCard(
            controller: _amountCtrl,
            currency: s.currency,
            onChanged: (String v) => c.setAmount(double.tryParse(v) ?? 0),
            onPickCurrency: () async {
              final Currency? picked = await showCurrencyPicker(context, ref);
              if (picked != null && mounted) {
                c.setCurrency(picked.code);
              }
            },
          ),

          const SizedBox(height: 12),

          // Helper when empty
          if (!hasAmount)
            Row(
              children: <Widget>[
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Enter an amount you wish to add',
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

          // Details (visible when amount entered)
          if (hasAmount) ...<Widget>[
            const SizedBox(height: 16),

            // Paying in row
            SectionCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  Text(
                    displayFlag,
                    style: text.labelLarge?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Paying in',
                          style: text.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          displayName,
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ChangeChip(
                    onTap: () async {
                      final Currency? picked = await showCurrencyPicker(
                        context,
                        ref,
                      );
                      if (picked != null && mounted) {
                        c.setCurrency(picked.code);
                      }
                    },
                  ),
                ],
              ),
            ),
            // Paying in row
            SectionCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  Icon(Icons.account_balance_rounded, color: scheme.onSurface),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Paying with',
                          style: text.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          chosen,
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ChangeChip(
                    onTap: () => context.goNamed(AppRoute.paymentMethod.name),
                  ),
                ],
              ),
            ),

            // Arrives row
            SectionCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  Icon(Icons.bolt_rounded, color: scheme.onSurface),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Arrives',
                          style: text.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${s.arrivalLabel} - in seconds',
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ChangeChip(
                    onTap: () {
                      // open arrival/speed sheet if you add one
                    },
                  ),
                ],
              ),
            ),

            // You pay row
            SectionCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  Icon(Icons.receipt_long_rounded, color: scheme.onSurface),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'You pay',
                          style: text.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Total – no fees to pay',
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${s.formattedAmountNoCents} ${s.currency}',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ],
        ],
      ),

      // CTA
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
              disabledBackgroundColor: scheme.onSurface.withCustomOpacity(.12),
              disabledForegroundColor: scheme.onSurface.withCustomOpacity(.38),
            ),
            onPressed: hasAmount
                ? () {
                    // proceed → add recipient flow
                    context.goNamed('add-recipient'); // your route
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
