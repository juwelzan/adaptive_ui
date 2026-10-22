import 'package:flutter/widgets.dart';

import '../../core/adaptive_breakpoints.dart';
import '../../core/adaptive_engine.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_value.dart';
import '../adaptive_builder.dart';

/// A row layout that automatically collapses into a column or wraps on constrained viewports.
class AdaptiveRow extends StatelessWidget {
  const AdaptiveRow({
    super.key,
    this.autoCollapse = false,
    this.collapseBelowBreakpoint = Breakpoint.medium,
    this.minRowWidth,
    this.minItemWidth,
    this.wrap = false,
    this.runSpacing,
    this.wrapAlignment = WrapAlignment.start,
    this.wrapCrossAlignment = WrapCrossAlignment.center,
    this.direction,
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

  /// Minimum total container width required to maintain row arrangement.
  final double? minRowWidth;

  /// Minimum individual item width required.
  ///
  /// When provided and [autoCollapse] is true, if the sum of child widths and spacing
  /// exceeds available width, the row automatically collapses into a column.
  final double? minItemWidth;

  /// Whether to arrange children using a [Wrap] widget instead of a single-line [Row].
  final bool wrap;

  /// Spacing between runs when [wrap] is true. Defaults to [spacing].
  final double? runSpacing;

  /// Alignment of runs along the main axis when [wrap] is true.
  final WrapAlignment wrapAlignment;

  /// Alignment of children within a run along the cross axis when [wrap] is true.
  final WrapCrossAlignment wrapCrossAlignment;

  /// Explicit layout direction override.
  ///
  /// If specified, forces horizontal ([Axis.horizontal]) or vertical ([Axis.vertical])
  /// arrangement regardless of breakpoints.
  final Axis? direction;

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
        final double resolvedSpacing = spacing?.resolve(layout) ?? 0.0;
        final double resolvedRunSpacing = runSpacing ?? resolvedSpacing;

        bool shouldCollapse;
        if (direction != null) {
          shouldCollapse = direction == Axis.vertical;
        } else {
          final bool requiredWidthExceeded = minItemWidth != null &&
              layout.availableWidth > 0 &&
              (children.length * minItemWidth! +
                      (children.length - 1) * resolvedSpacing) >
                  layout.availableWidth;

          shouldCollapse = autoCollapse &&
              (AdaptiveEngine.shouldCollapseRow(
                    layout,
                    collapseBelowBreakpoint: collapseBelowBreakpoint,
                    minRowWidth: minRowWidth,
                  ) ||
                  requiredWidthExceeded);
        }

        if (wrap && !shouldCollapse) {
          List<Widget> wrapChildren = children;
          if (minItemWidth != null) {
            wrapChildren = children
                .map((Widget w) => ConstrainedBox(
                      constraints: BoxConstraints(minWidth: minItemWidth!),
                      child: w,
                    ))
                .toList();
          }
          return Wrap(
            direction: Axis.horizontal,
            alignment: wrapAlignment,
            crossAxisAlignment: wrapCrossAlignment,
            spacing: resolvedSpacing,
            runSpacing: resolvedRunSpacing,
            children: wrapChildren,
          );
        }

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
            children: spacedChildren.map((Widget w) {
              if (w is Expanded) return w.child;
              return w;
            }).toList(),
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
