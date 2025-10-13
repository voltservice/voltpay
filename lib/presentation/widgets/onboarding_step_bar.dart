import 'package:flutter/material.dart';
import 'package:with_opacity/with_opacity.dart';

/// Tiny segmented bar like Instagram stories.
/// - [total] total number of screens.
/// - [current] zero-based index of the current screen.
/// - [progress] 0..1 for the active segment fill.

// onboarding_step_bar.dart
class OnboardingStepBar extends StatelessWidget {
  const OnboardingStepBar({
    required this.total,
    required this.current,
    required this.progress,
    super.key,
    this.onTap, // NEW
  });

  final int total;
  final int current;
  final double progress;
  final ValueChanged<int>? onTap; // NEW

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color bg = scheme.surface.withCustomOpacity(0.25);
    final Color fg = scheme.primary;
    final int t = total.clamp(1, 1000);
    final int c = current.clamp(0, t - 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: List<Widget>.generate(t, (int i) {
          final bool done = i < c, active = i == c;
          final Container seg = Container(
            height: 3,
            margin: EdgeInsets.only(right: i == t - 1 ? 0 : 6),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(2),
            ),
            child: (done || active)
                ? FractionallySizedBox(
                    widthFactor: done ? 1 : progress.clamp(0, 1),
                    alignment: Alignment.centerLeft,
                    child: Container(color: fg),
                  )
                : const SizedBox.shrink(),
          );
          return Expanded(
            child: onTap == null
                ? seg
                : GestureDetector(onTap: () => onTap!(i), child: seg),
          );
        }),
      ),
    );
  }
}
