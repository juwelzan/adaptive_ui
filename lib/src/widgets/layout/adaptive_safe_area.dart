import 'package:flutter/widgets.dart';

import '../../core/adaptive_layout_data.dart';
import '../adaptive_builder.dart';

/// An adaptive safe area that intelligently applies padding based on breakpoint and notch presence.
class AdaptiveSafeArea extends StatelessWidget {
  const AdaptiveSafeArea({
    super.key,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
    this.onlyCompact = false,
    required this.child,
  });

  final bool left;
  final bool top;
  final bool right;
  final bool bottom;
  final EdgeInsets minimum;
  final bool maintainBottomViewPadding;

  /// If true, safe area padding is strictly applied on [Breakpoint.compact] devices (phones with notches).
  final bool onlyCompact;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!onlyCompact) {
      return SafeArea(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        minimum: minimum,
        maintainBottomViewPadding: maintainBottomViewPadding,
        child: child,
      );
    }

    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        if (!layout.isCompact) return child;

        return SafeArea(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          minimum: minimum,
          maintainBottomViewPadding: maintainBottomViewPadding,
          child: child,
        );
      },
    );
  }
}
