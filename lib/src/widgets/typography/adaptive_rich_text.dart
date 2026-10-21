import 'package:flutter/widgets.dart';

import '../../core/adaptive_config.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../utilities/adaptive_overflow_policy.dart';
import '../adaptive_builder.dart';

/// A rich text widget that adapts overflow policies and preserves system accessibility scaling.
class AdaptiveRichText extends StatelessWidget {
  const AdaptiveRichText({
    super.key,
    required this.text,
    this.maxLines,
    this.overflowPolicy,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
  });

  /// The text tree to display.
  final InlineSpan text;

  /// Maximum line count.
  final int? maxLines;

  /// Overflow policy. Defaults to [AdaptiveConfig.defaultOverflowPolicy].
  final AdaptiveOverflowPolicy? overflowPolicy;

  /// Text alignment.
  final TextAlign textAlign;

  /// Text direction.
  final TextDirection? textDirection;

  /// Whether text wraps across soft breaks.
  final bool softWrap;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveConfig config = AdaptiveScope.configOf(ctx);
        final AdaptiveOverflowPolicy policy =
            overflowPolicy ?? config.defaultOverflowPolicy;

        return Text.rich(
          text,
          maxLines: maxLines,
          overflow: policy.toTextOverflow(),
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: softWrap,
          textScaler: layout.textScaler,
        );
      },
    );
  }
}
