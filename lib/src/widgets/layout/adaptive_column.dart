import 'package:flutter/widgets.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_value.dart';
import '../adaptive_builder.dart';

/// A column layout supporting responsive child spacing and reading-width alignment.
class AdaptiveColumn extends StatelessWidget {
  const AdaptiveColumn({
    super.key,
    this.spacing,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.maxContentWidth,
    this.alignment = Alignment.topCenter,
    required this.children,
  });

  /// Vertical separation spacing inserted between adjacent children.
  final AdaptiveValue<double>? spacing;

  /// Main axis alignment.
  final MainAxisAlignment mainAxisAlignment;

  /// Cross axis alignment.
  final CrossAxisAlignment crossAxisAlignment;

  /// Main axis sizing.
  final MainAxisSize mainAxisSize;

  /// Optional maximum content width for the column.
  ///
  /// When parent constraints exceed this value, the column is constrained to [maxContentWidth]
  /// and aligned according to [alignment] (defaults to [Alignment.topCenter]).
  final double? maxContentWidth;

  /// Alignment applied when [maxContentWidth] is constrained. Defaults to [Alignment.topCenter].
  final AlignmentGeometry alignment;

  /// The column children.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    if (spacing == null && maxContentWidth == null) {
      return Column(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    }

    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final double resolvedSpacing = spacing?.resolve(layout) ?? 0.0;
        final List<Widget> spacedChildren = <Widget>[];

        for (int i = 0; i < children.length; i++) {
          spacedChildren.add(children[i]);
          if (i < children.length - 1 && resolvedSpacing > 0.0) {
            spacedChildren.add(SizedBox(height: resolvedSpacing));
          }
        }

        final Widget column = Column(
          mainAxisSize: mainAxisSize,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: spacedChildren,
        );

        if (maxContentWidth != null &&
            layout.availableWidth > maxContentWidth!) {
          return Align(
            alignment: alignment,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth!),
              child: column,
            ),
          );
        }

        return column;
      },
    );
  }
}
