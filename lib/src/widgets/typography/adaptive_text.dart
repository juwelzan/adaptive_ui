import 'package:flutter/widgets.dart';

import '../../core/adaptive_config.dart';
import '../../core/adaptive_engine.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../core/adaptive_value.dart';
import '../../utilities/adaptive_overflow_policy.dart';
import '../adaptive_builder.dart';
import 'adaptive_text_style.dart';

/// A responsive typography widget that scales font sizes safely while strictly preserving accessibility settings.
class AdaptiveText extends StatelessWidget {
  const AdaptiveText(
    this.text, {
    super.key,
    this.size,
    this.baseFontSize = 16.0,
    this.minFontSize,
    this.maxFontSize,
    this.style,
    this.adaptiveStyle,
    this.maxLines,
    this.overflowPolicy,
    this.textAlign,
    this.softWrap = true,
    this.semanticsLabel,
  });

  /// The text to display.
  final String text;

  /// Responsive or fixed font size override.
  final AdaptiveValue<double>? size;

  /// Reference font size for proportional scaling calculations. Defaults to 16.0.
  final double baseFontSize;

  /// Guaranteed minimum font size to preserve legibility.
  final double? minFontSize;

  /// Maximum font size cap to prevent layout clipping.
  final double? maxFontSize;

  /// Baseline Flutter [TextStyle].
  final TextStyle? style;

  /// Responsive [AdaptiveTextStyle].
  final AdaptiveTextStyle? adaptiveStyle;

  /// Maximum lines before applying overflow policy.
  final int? maxLines;

  /// Overflow behavior. If null, defaults to [AdaptiveConfig.defaultOverflowPolicy].
  final AdaptiveOverflowPolicy? overflowPolicy;

  /// Text horizontal alignment.
  final TextAlign? textAlign;

  /// Whether text should wrap at soft line breaks.
  final bool softWrap;

  /// Accessibility semantic label.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveConfig config = AdaptiveScope.configOf(ctx);
        final TextStyle base = style ?? const TextStyle();
        final TextStyle resolvedAdaptive =
            adaptiveStyle?.resolve(layout) ?? base;

        double effectiveFontSize;
        if (size != null) {
          effectiveFontSize = size!.resolve(layout, () {
            return AdaptiveEngine.calculateFontSize(
              baseFontSize: baseFontSize,
              layout: layout,
              config: config,
              minFontSize: minFontSize,
              maxFontSize: maxFontSize,
            );
          });
        } else {
          final double baseSize = resolvedAdaptive.fontSize ?? baseFontSize;
          effectiveFontSize = AdaptiveEngine.calculateFontSize(
            baseFontSize: baseSize,
            layout: layout,
            config: config,
            minFontSize: minFontSize,
            maxFontSize: maxFontSize,
          );
        }

        final TextStyle finalStyle = resolvedAdaptive.copyWith(
          fontSize: effectiveFontSize,
        );

        final AdaptiveOverflowPolicy effectivePolicy =
            overflowPolicy ?? config.defaultOverflowPolicy;

        return Text(
          text,
          style: finalStyle,
          maxLines: maxLines,
          overflow: effectivePolicy.toTextOverflow(),
          textAlign: textAlign,
          softWrap: softWrap,
          semanticsLabel: semanticsLabel,
        );
      },
    );
  }
}
