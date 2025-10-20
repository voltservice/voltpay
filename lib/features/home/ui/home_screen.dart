import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/auth/provider/auth_provider.dart';
import 'package:voltpay/core/router/app_routes.dart';
// Re-use your existing pieces from Rates
import 'package:voltpay/features/currency/domain/currency.dart';
import 'package:voltpay/features/currency/presentation/currency_picker.dart';
import 'package:voltpay/features/home/widget/avater_button.dart';
import 'package:voltpay/features/home/widget/barge_icon.dart';
import 'package:voltpay/features/home/widget/calculator_card.dart';
import 'package:voltpay/features/home/widget/discover_card.dart';
import 'package:voltpay/features/home/widget/discover_row.dart';
import 'package:voltpay/features/home/widget/earn_banner.dart';
import 'package:voltpay/features/home/widget/empty_transaction.dart';
import 'package:voltpay/features/home/widget/flag_circle.dart';
import 'package:voltpay/features/home/widget/pill_action.dart';
import 'package:voltpay/features/home/widget/sprinkler_placeholder.dart';
import 'package:voltpay/features/home/widget/stat_card.dart';
import 'package:voltpay/features/profile/presentation/drawer/show_volt_drawer.dart';
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
import 'package:with_opacity/with_opacity.dart'; // for AmountCard

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    final QuoteParams params = ref.read(quoteParamsProvider);
    _amountCtrl = TextEditingController(text: params.amount.toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Calculator state
    final QuoteParams params = ref.watch(quoteParamsProvider);
    final AsyncValue<Quote> quoteAsync = ref.watch(quoteProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Top bar
              Row(
                children: <Widget>[
                  AvatarButton(
                    onTap: () {
                      showVoltDrawer(
                        context,
                        onProfile: () => context.goNamed('/profile'),
                        onManageProviders: () =>
                            context.goNamed('/settings/security'),
                        onSettings: () => context.goNamed('/settings'),
                        onHelp: () => context.goNamed('/help'),
                        onSignOut: () => ref
                            .read(authServiceProvider)
                            .signOut(), // service call elsewhere
                      );
                    },
                  ),
                  const Spacer(),
                  EarnBanner(
                    onTap: () {
                      // open referral
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Welcome
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    'Welcome to Voltpay',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.insights_rounded,
                    size: 20,
                    color: scheme.onSurface.withCustomOpacity(.8),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quick actions
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  PillAction(
                    label: 'Send',
                    onTap: () => context.goNamed(AppRoute.addMoney.name),
                  ),
                  PillAction(
                    label: 'Add money',
                    onTap: () => context.goNamed(AppRoute.topup.name),
                  ),
                  PillAction(
                    label: 'Request',
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Balance + Rewards cards
              Row(
                children: <Widget>[
                  Expanded(
                    child: StatCard(
                      title: 'GBP',
                      subtitle: '£0.00',
                      leading: const FlagCircle(codeEmoji: '🇬🇧'),
                      scheme: scheme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Rewards',
                      subtitle: '0.00 pts',
                      leading: const BadgeIcon(),
                      scheme: scheme,
                      dark: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Transactions header
              Row(
                children: <Widget>[
                  Text(
                    'Transactions',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'See all',
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Empty state
              EmptyTransactions(scheme: scheme, textTheme: textTheme),

              const SizedBox(height: 24),

              // Transfer calculator (re-uses your Rates widgets/providers)
              Text(
                'Transfer calculator',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              CalculatorCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // (Optional) mini sparkline placeholder – swap with your chart widget later
                    SparklinePlaceholder(scheme: scheme),
                    const SizedBox(height: 8),

                    Text(
                      '1 ${params.source} = '
                      '${quoteAsync.maybeWhen(data: (Quote q) => q.rate.toStringAsFixed(5), orElse: () => '—')} ${params.target}',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Send amount
                    AmountCard(
                      controller: _amountCtrl,
                      currency: params.source,
                      onChanged: (String v) {
                        final double parsed = double.tryParse(v) ?? 0;
                        ref
                            .read(quoteParamsProvider.notifier)
                            .patch(amount: parsed);
                        ref.read(quoteParamsProvider.notifier);
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
                          _amountCtrl.text = params.amount.toStringAsFixed(0);
                          _amountCtrl.selection = TextSelection.fromPosition(
                            TextPosition(offset: _amountCtrl.text.length),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 10),

                    // Receive amount + currency
                    quoteAsync.when(
                      loading: () => Skeleton(scheme: scheme),
                      error: (Object e, _) => Text(
                        'Failed to load quote: $e',
                        style: TextStyle(color: scheme.error),
                      ),
                      data: (Quote q) => Column(
                        children: <Widget>[
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
                              }
                            },
                          ),
                          const SizedBox(height: 12),

                          // Fees & method rows
                          FeeRow(
                            scheme: scheme,
                            bullet: Icons.circle,
                            left:
                                '${q.fees.firstWhere((FeeLine f) => f.label.contains("Wire"), orElse: () => q.fees.first).amount.toStringAsFixed(2)} ${q.sourceCurrency}',
                            rightWidget: MethodLink(
                              label: params.method.feeLinkLabel,
                              onTap: () async {
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
                            rightText: "Total we'll convert",
                          ),
                          FeeRow(
                            scheme: scheme,
                            bullet: Icons.close,
                            left: q.rate.toString(),
                            rightLinkText:
                                'Guaranteed rate (${q.guarantee.inHours}h)',
                            onRightTap: () {},
                          ),

                          const SizedBox(height: 10),

                          // Meta text
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                children: <InlineSpan>[
                                  const TextSpan(text: 'Includes fees '),
                                  TextSpan(
                                    text:
                                        '${q.fees.first.amount.toStringAsFixed(2)} ${q.sourceCurrency}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const TextSpan(text: ' • Should arrive '),
                                  TextSpan(
                                    text: 'in ${q.arrivalEta.inHours} hours',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Call to action
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                shape: const StadiumBorder(),
                                backgroundColor: scheme.primary,
                                foregroundColor: scheme.onPrimary,
                              ),
                              onPressed: () {
                                // continue flow
                              },
                              child: const Text('Send'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // “Do more with Wise”-like discover row (simple placeholders)
              Text(
                'Do more with Voltpay',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              DiscoverRow(
                left: DiscoverCard(
                  title: 'Send and request\nfrom contacts',
                  onClose: () {},
                  onTap: () {},
                ),
                right: DiscoverCard(
                  title: 'Schedule your\ntransfer',
                  onClose: () {},
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
