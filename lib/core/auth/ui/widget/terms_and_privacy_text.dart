import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndPrivacyText extends StatelessWidget {
  const TermsAndPrivacyText({super.key});

  static const String _privacy = 'https://metalbrain.net/privacy';
  static const String _terms = 'https://metalbrain.net/terms-of-service';

  Future<void> _open(String url) async {
    final Uri u = Uri.parse(url);
    if (!await launchUrl(u, mode: LaunchMode.externalApplication)) {
      // Fail silently; could show a SnackBar if desired.
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle base = Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Theme.of(context).colorScheme.outline,
        );

    final TextStyle link = base.copyWith(
      decoration: TextDecoration.underline,
      decorationThickness: 1.5,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.primary,
    );

    return Text.rich(
      TextSpan(
        text: 'By signing up you agree to our ',
        style: base,
        children: <InlineSpan>[
          TextSpan(
            text: 'terms of use',
            style: link,
            recognizer: TapGestureRecognizer()..onTap = () => _open(_terms),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy policy',
            style: link,
            recognizer: TapGestureRecognizer()..onTap = () => _open(_privacy),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
