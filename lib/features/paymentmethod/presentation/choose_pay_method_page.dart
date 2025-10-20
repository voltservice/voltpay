import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/core/utils/buttons/app_back_button.dart';
import 'package:voltpay/features/paymentmethod/domain/pay_method_type.dart';
import 'package:voltpay/features/paymentmethod/domain/pay_option.dart';
import 'package:voltpay/features/paymentmethod/provider/pay_options_provider.dart';
import 'package:voltpay/features/paymentmethod/ui/pay_row.dart';
import 'package:voltpay/features/paymentmethod/ui/pill.dart';
import 'package:voltpay/features/topup/providers/topup_controller.dart';

class ChoosePayMethodPage extends ConsumerStatefulWidget {
  const ChoosePayMethodPage({super.key});

  @override
  ConsumerState<ChoosePayMethodPage> createState() =>
      _ChoosePayMethodPageState();
}

class _ChoosePayMethodPageState extends ConsumerState<ChoosePayMethodPage> {
  bool _showCheapest = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme _ = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    final List<PayOption> all = ref.watch(payOptionsProvider);
    final List<PayOption> cheapest = ref.watch(cheapestPayOptionsProvider);
    final List<PayOption> list = _showCheapest ? cheapest : all;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text(''),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: <Widget>[
          Text(
            'Choose how to pay',
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),

          // Segmented toggle
          Row(
            children: <Widget>[
              Pill(
                label: 'All',
                selected: !_showCheapest,
                onTap: () => setState(() => _showCheapest = false),
              ),
              const SizedBox(width: 12),
              Pill(
                label: 'Cheapest',
                outlined: true,
                selected: _showCheapest,
                onTap: () => setState(() => _showCheapest = true),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),

          // Options
          for (final PayOption o in list) ...<Widget>[
            PayRow(
              icon: o.type.icon,
              title: o.type.label,
              subtitle: o.line2,
              onTap: () {
                ref.read(topUpControllerProvider.notifier).setPayMethod(o.type);
                Navigator.of(context).maybePop(); // return to previous screen
              },
            ),
            const Divider(),
          ],
        ],
      ),
    );
  }
}
