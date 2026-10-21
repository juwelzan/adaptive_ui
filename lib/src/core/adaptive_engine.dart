import 'dart:math' as math;
import 'package:flutter/widgets.dart';

import '../utilities/adaptive_math.dart';
import 'adaptive_breakpoints.dart';
import 'adaptive_config.dart';
import 'adaptive_layout_data.dart';
import 'adaptive_value.dart';

/// Pure computation engine executing responsive layout mathematics and layout resolution.
class AdaptiveEngine {
  const AdaptiveEngine._();

  /// Calculates dynamic grid column count to fit within [availableWidth] given [minItemWidth] and [spacing].
  static int calculateColumns(
    double availableWidth, {
    required double minItemWidth,
    double spacing = 16.0,
    int maxColumns = 12,
    int minColumns = 1,
  }) {
    if (availableWidth <= 0 || minItemWidth <= 0) return minColumns;

    // formula: availableWidth >= columns * minItemWidth + (columns - 1) * spacing
    // columns * (minItemWidth + spacing) - spacing <= availableWidth
    // columns <= (availableWidth + spacing) / (minItemWidth + spacing)
    final double theoretical =
        (availableWidth + spacing) / (minItemWidth + spacing);
    final int count = theoretical.floor();
    return math.max(minColumns, math.min(maxColumns, count));
  }

  /// Calculates proportional, accessibility-safe font size for a text element.
  static double calculateFontSize({
    required double baseFontSize,
    required AdaptiveLayoutData layout,
    required AdaptiveConfig config,
    double? minFontSize,
    double? maxFontSize,
  }) {
    double scaled = baseFontSize;

    if (config.autoFontScaling) {
      scaled = AdaptiveMath.scaleWithDamping(
        baseFontSize,
        layout.availableWidth,
        config.designBaseWidth,
      );
    }

    // Apply accessibility TextScaler
    final double textScaled = layout.textScaler.scale(scaled);

    // Apply minimum and maximum caps
    final double minBound = minFontSize ?? 10.0;
    final double maxBound =
        maxFontSize ?? (baseFontSize * config.maxFontScaleFactor);

    return textScaled.clamp(minBound, maxBound);
  }

  /// Evaluates whether an [AdaptiveRow] should collapse vertically into a column.
  static bool shouldCollapseRow(
    AdaptiveLayoutData layout, {
    Breakpoint collapseBelowBreakpoint = Breakpoint.medium,
    double? minRowWidth,
  }) {
    if (minRowWidth != null && layout.availableWidth < minRowWidth) {
      return true;
    }
    return layout.containerBreakpoint.index < collapseBelowBreakpoint.index;
  }

  /// Resolves padding for a container given explicit or automatic [AdaptiveInsets].
  static EdgeInsets resolvePadding(
    AdaptiveLayoutData layout,
    AdaptiveInsets? insets, {
    EdgeInsets fallback = EdgeInsets.zero,
  }) {
    if (insets != null) {
      return insets.resolve(layout);
    }
    return fallback;
  }
}
