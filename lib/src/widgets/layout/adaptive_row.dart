import 'package:flutter/widgets.dart';

import '../../core/adaptive_breakpoints.dart';
import '../../core/adaptive_engine.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_value.dart';
import '../adaptive_builder.dart';

/// A row layout that automatically collapses into a column on constrained viewports.
class AdaptiveRow extends StatelessWidget {
  const AdaptiveRow({
    super.key,
    this.autoCollapse = false,
    this.collapseBelowBreakpoint = Breakpoint.medium,
    this.minRowWidth,
    this.spacing,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.collapsedCrossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisSize = MainAxisSize.max,
    required this.children,
  });

  /// Whether this row automatically collapses into a vertical [Column] on narrow viewports.
  final bool autoCollapse;

  /// Breakpoint threshold below which the row collapses. Defaults to [Breakpoint.medium].
  final Breakpoint collapseBelowBreakpoint;

  /// Minimum width required to maintain row arrangement.
  final double? minRowWidth;

  /// Separation spacing inserted between adjacent children.
  final AdaptiveValue<double>? spacing;

  /// Main axis alignment for row layout.
  final MainAxisAlignment mainAxisAlignment;

  /// Cross axis alignment for row layout.
  final CrossAxisAlignment crossAxisAlignment;

  /// Cross axis alignment applied when collapsed into a column.
  final CrossAxisAlignment collapsedCrossAxisAlignment;

  /// Main axis sizing.
  final MainAxisSize mainAxisSize;

  /// The row children.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final bool shouldCollapse = autoCollapse &&
            AdaptiveEngine.shouldCollapseRow(
              layout,
              collapseBelowBreakpoint: collapseBelowBreakpoint,
              minRowWidth: minRowWidth,
            );

        final double resolvedSpacing = spacing?.resolve(layout) ?? 0.0;
        final List<Widget> spacedChildren = <Widget>[];

        for (int i = 0; i < children.length; i++) {
          spacedChildren.add(children[i]);
          if (i < children.length - 1 && resolvedSpacing > 0.0) {
            spacedChildren.add(
              shouldCollapse
                  ? SizedBox(height: resolvedSpacing)
                  : SizedBox(width: resolvedSpacing),
            );
          }
        }

        if (shouldCollapse) {
          return Column(
            mainAxisSize: mainAxisSize,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: collapsedCrossAxisAlignment,
            children: spacedChildren,
          );
        }

        return Row(
          mainAxisSize: mainAxisSize,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: spacedChildren,
        );
      },
    );
  }
}
