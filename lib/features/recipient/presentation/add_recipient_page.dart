import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voltpay/core/router/app_routes.dart';
import 'package:voltpay/core/utils/buttons/app_back_button.dart';
import 'package:voltpay/features/recipient/provider/recipient_controller.dart';
import 'package:voltpay/features/recipient/provider/recipient_provider.dart'; // for enum
import 'package:voltpay/features/recipient/ui/widget/divider.dart';
import 'package:voltpay/features/recipient/ui/widget/info_pill.dart';
import 'package:voltpay/features/recipient/ui/widget/option_tile.dart';
import 'package:voltpay/features/recipient/ui/widget/v.dart';
import 'package:with_opacity/with_opacity.dart';

class AddRecipientPage extends ConsumerWidget {
  const AddRecipientPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme _ = Theme.of(context).textTheme;
    final RecipientController ctrl = ref.read(
      recipientControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          onPressed: () => context.goNamed(AppRoute.addMoney.name),
        ),
        title: const Text('Add a recipient'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: <Widget>[
          // Find on Voltpay
          OptionTile(
            icon: const VoltIcon(),
            title: 'Find on Voltpay',
            subtitle: 'search  by Voltpay, email, or mobile number',
            leadingBg: scheme.primary.withCustomOpacity(.12),
            onTap: () {
              ctrl.selectMethod(RecipientMethod.voltpayLookup);
              context.goNamed('recipient-search'); // implement route
            },
          ),
          const SizedBox(height: 8),
          const InfoPill(
            text: 'Instant and convienient',
            icon: Icons.emoji_emotions_rounded,
            background: Colors.blue,
          ),
          const DividerLine(),
          // Bank details
          OptionTile(
            icon: Icon(Icons.account_balance_rounded, color: scheme.onSurface),
            title: 'Bank details',
            subtitle: 'Enter name and IBAN',
            onTap: () {
              ctrl.selectMethod(RecipientMethod.bankDetails);
              context.goNamed('recipient-bank'); // implement route
            },
          ),

          const DividerLine(),
          // Upload screenshot or invoice (OCR)
          OptionTile(
            icon: Icon(Icons.upload_rounded, color: scheme.onSurface),
            title: 'Upload screenshot or invoice',
            subtitle:
                'We’ll fill their details from a screenshot, photo or PDF',
            onTap: () {
              ctrl.selectMethod(RecipientMethod.documentUpload);
              context.goNamed('recipient-ocr'); // implement route
            },
          ),

          const DividerLine(),
          // Pay by email
          OptionTile(
            icon: Icon(Icons.mail_outline_rounded, color: scheme.onSurface),
            title: 'Pay by email',
            subtitle:
                'We’ll email your recipient to request their bank details',
            onTap: () {
              ctrl.selectMethod(RecipientMethod.emailRequest);
              context.goNamed('recipient-email'); // implement route
            },
          ),
          const DividerLine(),
        ],
      ),
    );
  }
}
