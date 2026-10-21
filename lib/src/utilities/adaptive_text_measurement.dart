import 'package:flutter/widgets.dart';

/// Performance-optimized text measurement utility executing off-screen layout tests.
class AdaptiveTextMeasurement {
  const AdaptiveTextMeasurement._();

  /// Determines whether [text] rendered with [style] fits completely within [constraints].
  static bool doesTextFit({
    required String text,
    required TextStyle style,
    required BoxConstraints constraints,
    int maxLines = 1,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    if (constraints.maxWidth <= 0 ||
        (constraints.hasBoundedHeight && constraints.maxHeight <= 0)) {
      return false;
    }

    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      maxLines: maxLines,
    )..layout(maxWidth: constraints.maxWidth);

    final bool fitsHorizontally;
    if (maxLines == 1) {
      fitsHorizontally = painter.maxIntrinsicWidth <= constraints.maxWidth;
    } else {
      fitsHorizontally = painter.minIntrinsicWidth <= constraints.maxWidth &&
          !painter.didExceedMaxLines;
    }

    final bool fitsVertically = !constraints.hasBoundedHeight ||
        painter.height <= constraints.maxHeight;

    painter.dispose();
    return fitsHorizontally && fitsVertically;
  }

  /// Calculates the bounding [Size] of [text] rendered with [style].
  static Size measureTextSize({
    required String text,
    required TextStyle style,
    double maxWidth = double.infinity,
    int maxLines = 1,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);

    final Size size = painter.size;
    painter.dispose();
    return size;
  }

  /// Executes an optimized binary search to identify the largest font size
  /// between [minFontSize] and [maxFontSize] that fits within [constraints].
  static double findOptimalFontSize({
    required String text,
    required TextStyle baseStyle,
    required BoxConstraints constraints,
    required double minFontSize,
    required double maxFontSize,
    double step = 0.5,
    int maxLines = 1,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    assert(minFontSize <= maxFontSize, 'minFontSize must be <= maxFontSize');

    // First test if maxFontSize fits immediately
    if (doesTextFit(
      text: text,
      style: baseStyle.copyWith(fontSize: maxFontSize),
      constraints: constraints,
      maxLines: maxLines,
      textDirection: textDirection,
    )) {
      return maxFontSize;
    }

    // If even minFontSize does not fit, return minFontSize as guaranteed floor
    if (!doesTextFit(
      text: text,
      style: baseStyle.copyWith(fontSize: minFontSize),
      constraints: constraints,
      maxLines: maxLines,
      textDirection: textDirection,
    )) {
      return minFontSize;
    }

    // Binary search for optimal font size
    double low = minFontSize;
    double high = maxFontSize;
    double bestFit = minFontSize;

    while (high - low >= step) {
      final double mid = ((low + high) / 2 * 2).round() / 2;
      final bool fits = doesTextFit(
        text: text,
        style: baseStyle.copyWith(fontSize: mid),
        constraints: constraints,
        maxLines: maxLines,
        textDirection: textDirection,
      );

      if (fits) {
        bestFit = mid;
        low = mid + step;
      } else {
        high = mid - step;
      }
    }

    return bestFit;
  }
}
