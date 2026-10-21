import 'package:flutter/rendering.dart';

import 'adaptive_breakpoints.dart';
import 'adaptive_layout_data.dart';

/// Utilities and factory helpers for computing responsive [BoxConstraints].
class AdaptiveConstraints {
  const AdaptiveConstraints._();

  /// Creates responsive constraints based on breakpoint tiers.
  static BoxConstraints responsive({
    required AdaptiveLayoutData layout,
    BoxConstraints? compact,
    BoxConstraints? medium,
    BoxConstraints? expanded,
    BoxConstraints? large,
    BoxConstraints? extraLarge,
    BoxConstraints fallback = const BoxConstraints(),
  }) {
    switch (layout.containerBreakpoint) {
      case Breakpoint.compact:
        return compact ?? fallback;
      case Breakpoint.medium:
        return medium ?? compact ?? fallback;
      case Breakpoint.expanded:
        return expanded ?? medium ?? compact ?? fallback;
      case Breakpoint.large:
        return large ?? expanded ?? medium ?? compact ?? fallback;
      case Breakpoint.extraLarge:
        return extraLarge ?? large ?? expanded ?? medium ?? compact ?? fallback;
    }
  }

  /// Clamps [constraints] within guaranteed [minWidth], [maxWidth], [minHeight], and [maxHeight] bounds.
  static BoxConstraints clamp({
    required BoxConstraints constraints,
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    final double resolvedMinWidth = minWidth != null
        ? minWidth.clamp(0.0, constraints.maxWidth)
        : constraints.minWidth;
    final double resolvedMaxWidth = maxWidth != null
        ? maxWidth.clamp(resolvedMinWidth, constraints.maxWidth)
        : constraints.maxWidth;
    final double resolvedMinHeight = minHeight != null
        ? minHeight.clamp(0.0, constraints.maxHeight)
        : constraints.minHeight;
    final double resolvedMaxHeight = maxHeight != null
        ? maxHeight.clamp(resolvedMinHeight, constraints.maxHeight)
        : constraints.maxHeight;

    return BoxConstraints(
      minWidth: resolvedMinWidth,
      maxWidth: resolvedMaxWidth,
      minHeight: resolvedMinHeight,
      maxHeight: resolvedMaxHeight,
    );
  }

  /// Returns true if [constraints] have an unbounded horizontal dimension.
  static bool isUnboundedWidth(BoxConstraints constraints) =>
      !constraints.hasBoundedWidth || constraints.maxWidth == double.infinity;

  /// Returns true if [constraints] have an unbounded vertical dimension.
  static bool isUnboundedHeight(BoxConstraints constraints) =>
      !constraints.hasBoundedHeight || constraints.maxHeight == double.infinity;
}
