import 'package:flutter/widgets.dart';

import '../../core/adaptive_config.dart';
import '../../core/adaptive_scope.dart';
import '../../utilities/adaptive_overflow_policy.dart';
import '../../utilities/adaptive_text_measurement.dart';

/// A text widget that automatically reduces its font size via binary search to fit bounded constraints,
/// never dropping below [minFontSize].
class AdaptiveAutoSizeText extends StatelessWidget {
  const AdaptiveAutoSizeText(
    this.text, {
    super.key,
    this.style,
    this.minFontSize = 12.0,
    this.maxFontSize = 32.0,
    this.stepGranularity = 0.5,
    this.maxLines = 1,
    this.overflowPolicy,
    this.textAlign,
  }) : assert(minFontSize <= maxFontSize, 'minFontSize must be <= maxFontSize');

  /// The text string to auto-fit.
  final String text;

  /// The baseline text style.
  final TextStyle? style;

  /// Minimum acceptable font size. Defaults to 12.0 dp.
  final double minFontSize;

  /// Maximum starting font size. Defaults to 32.0 dp.
  final double maxFontSize;

  /// Step granularity for binary search.
  final double stepGranularity;

  /// Maximum lines allowed.
  final int maxLines;

  /// Overflow policy if text cannot fit even at [minFontSize]. Defaults to ellipsis.
  final AdaptiveOverflowPolicy? overflowPolicy;

  /// Text alignment.
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) {
        final AdaptiveConfig config = AdaptiveScope.configOf(ctx);
        final TextStyle baseStyle = style ?? const TextStyle();

        // If constraints are unbounded, use maxFontSize directly
        if (!constraints.hasBoundedWidth) {
          return Text(
            text,
            style: baseStyle.copyWith(fontSize: maxFontSize),
            maxLines: maxLines,
            textAlign: textAlign,
          );
        }

        final double optimalSize = AdaptiveTextMeasurement.findOptimalFontSize(
          text: text,
          baseStyle: baseStyle,
          constraints: constraints,
          minFontSize: minFontSize,
          maxFontSize: maxFontSize,
          step: stepGranularity,
          maxLines: maxLines,
        );

        final AdaptiveOverflowPolicy policy =
            overflowPolicy ?? config.defaultOverflowPolicy;

        return Text(
          text,
          style: baseStyle.copyWith(fontSize: optimalSize),
          maxLines: maxLines,
          overflow: policy.toTextOverflow(),
          textAlign: textAlign,
        );
      },
    );
  }
}
