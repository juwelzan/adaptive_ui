import 'package:flutter/widgets.dart';

import '../../core/adaptive_config.dart';
import '../../core/adaptive_engine.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../core/adaptive_value.dart';
import '../adaptive_builder.dart';

/// A container that bounds text and reading copy to optimal typographic line lengths (default <= 720 dp).
class AdaptiveTextContainer extends StatelessWidget {
  const AdaptiveTextContainer({
    super.key,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
    required this.child,
  });

  /// Maximum readable width. Defaults to [AdaptiveConfig.readableTextMaxWidth] (720 dp).
  final double? maxWidth;

  /// Optional responsive padding.
  final AdaptiveInsets? padding;

  /// Alignment within the available parent space. Defaults to [Alignment.topCenter].
  final AlignmentGeometry alignment;

  /// The text or content subtree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveConfig config = AdaptiveScope.configOf(ctx);
        final double effectiveMaxWidth =
            maxWidth ?? config.readableTextMaxWidth;
        final EdgeInsets resolvedPadding =
            AdaptiveEngine.resolvePadding(layout, padding);

        Widget content = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          child: child,
        );

        if (resolvedPadding != EdgeInsets.zero) {
          content = Padding(padding: resolvedPadding, child: content);
        }

        return Align(
          alignment: alignment,
          child: content,
        );
      },
    );
  }
}
