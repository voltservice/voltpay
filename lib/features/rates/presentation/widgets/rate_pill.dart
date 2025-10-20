// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:voltpay/features/rates/domain/quote.dart';
//
// class RatePill extends StatelessWidget {
//   const RatePill({
//     required this.leading,
//     required this.trailing,
//     required this.quoteAsync,
//     this.onTap,
//   });
//
//   final String leading;
//   final String trailing;
//   final AsyncValue<Quote> quoteAsync;
//   final VoidCallback? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final ColorScheme scheme = Theme.of(context).colorScheme;
//
//     final String text = quoteAsync.maybeWhen(
//       data: (Quote q) =>
//           '1 $leading = ${q.rate.toStringAsFixed(4)} $trailing  >',
//       orElse: () => '—',
//     );
//
//     return Align(
//       alignment: Alignment.center,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(999),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//           decoration: ShapeDecoration(
//             color: scheme.surface,
//             shape: const StadiumBorder(),
//           ),
//           child: Text(
//             text,
//             style: TextStyle(
//               color: scheme.onSurface,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/core/brand/brand_colors.dart';
import 'package:voltpay/features/rates/domain/quote.dart';

class RatePill extends StatelessWidget {
  const RatePill({
    required this.leading,
    required this.trailing,
    required this.quoteAsync,
    super.key,
    this.onTap,
    this.gradient, // optional custom gradient
  });

  final String leading;
  final String trailing;
  final AsyncValue<Quote> quoteAsync;
  final VoidCallback? onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final ColorScheme _ = Theme.of(context).colorScheme;

    final String text = quoteAsync.maybeWhen(
      data: (Quote q) =>
          '1 $leading = ${q.rate.toStringAsFixed(4)} $trailing  >',
      orElse: () => '—',
    );

    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            gradient:
                gradient ??
                BrandGradients.notification, // fallback: teal/charcoal gradient
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
