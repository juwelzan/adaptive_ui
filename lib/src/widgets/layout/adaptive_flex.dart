import 'package:flutter/widgets.dart';

import '../../core/adaptive_breakpoints.dart';
import '../../core/adaptive_layout_data.dart';
import '../adaptive_builder.dart';

/// Defines how [AdaptiveFlex] arranges its children across different viewport constraints.
enum AdaptiveFlexArrangement {
  /// Always arranges children horizontally in a [Row].
  row,

  /// Always arranges children vertically in a [Column].
  column,

  /// Arranges children horizontally and wraps overflowing items to new lines via [Wrap].
  wrap,

  /// Automatically arranges horizontally on wide containers and switches to a vertical [Column]
  /// when available width falls below [AdaptiveFlex.collapseBreakpoint] or [AdaptiveFlex.minRowWidth].
  rowOrColumn,
}

/// A responsive, constraint-aware flex container that handles arrangement switching,
/// content wrapping, maximum content widths, safe flex unwrapping, and scrollable fallbacks.
class AdaptiveFlex extends StatelessWidget {
  /// Creates an adaptive flex layout.
  const AdaptiveFlex({
    super.key,
    this.arrangement = AdaptiveFlexArrangement.rowOrColumn,
    this.collapseBreakpoint = Breakpoint.medium,
    this.minRowWidth,
    this.spacing = 0.0,
    this.runSpacing,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.collapsedCrossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisSize = MainAxisSize.max,
    this.maxContentWidth,
    this.scrollableFallback = false,
    required this.children,
  });

  /// The arrangement policy for positioning children.
  final AdaptiveFlexArrangement arrangement;

  /// Breakpoint threshold below which [AdaptiveFlexArrangement.rowOrColumn] collapses into a column.
  final Breakpoint collapseBreakpoint;

  /// Explicit minimum parent width required to maintain a horizontal [Row] arrangement.
  final double? minRowWidth;

  /// Separation spacing between adjacent items along the main axis.
  final double spacing;

  /// Separation spacing between lines/runs when in [AdaptiveFlexArrangement.wrap] mode.
  /// Falls back to [spacing] if omitted.
  final double? runSpacing;

  /// Alignment along the main axis for [Row] or [Column].
  final MainAxisAlignment mainAxisAlignment;

  /// Alignment along the cross axis for [Row] or [Column].
  final CrossAxisAlignment crossAxisAlignment;

  /// Cross-axis alignment applied when collapsed into a vertical column. Defaults to [CrossAxisAlignment.stretch].
  final CrossAxisAlignment collapsedCrossAxisAlignment;

  /// How much space should be occupied along the main axis.
  final MainAxisSize mainAxisSize;

  /// Optional maximum content width. If available width exceeds this value, content is constrained
  /// and centered horizontally.
  final double? maxContentWidth;

  /// If true, automatically embeds the layout in a [SingleChildScrollView] along the active axis
  /// when parent constraints are tightly bounded or when collapsed to prevent RenderFlex overflow.
  final bool scrollableFallback;

  /// The child widgets.
  final List<Widget> children;

  List<Widget> _buildSpacedChildren(bool isColumn, double effectiveSpacing) {
    if (children.isEmpty) return const [];
    if (effectiveSpacing <= 0.0) return children;

    final List<Widget> result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(
          isColumn
              ? SizedBox(height: effectiveSpacing)
              : SizedBox(width: effectiveSpacing),
        );
      }
    }
    return result;
  }

  List<Widget> _unwrapExpandedForUnboundedColumn(
      List<Widget> list, bool hasBoundedHeight) {
    if (hasBoundedHeight) return list;
    return list.map((Widget w) {
      if (w is Expanded) return w.child;
      if (w is Flexible && w.fit == FlexFit.tight) return w.child;
      return w;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final double width = layout.availableWidth;
        final bool shouldCollapse =
            arrangement == AdaptiveFlexArrangement.column ||
                (arrangement == AdaptiveFlexArrangement.rowOrColumn &&
                    (minRowWidth != null
                        ? width < minRowWidth!
                        : layout.containerBreakpoint < collapseBreakpoint));

        final bool isWrap = arrangement == AdaptiveFlexArrangement.wrap;

        Widget content;

        if (isWrap) {
          content = Wrap(
            spacing: spacing,
            runSpacing: runSpacing ?? spacing,
            alignment: _mapMainAxisAlignmentToWrap(mainAxisAlignment),
            crossAxisAlignment:
                _mapCrossAxisAlignmentToWrap(crossAxisAlignment),
            children: children,
          );
        } else if (shouldCollapse) {
          final List<Widget> spaced = _buildSpacedChildren(true, spacing);
          final List<Widget> safeChildren = _unwrapExpandedForUnboundedColumn(
            spaced,
            layout.constraints.hasBoundedHeight,
          );

          Widget col = Column(
            mainAxisSize: mainAxisSize,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: collapsedCrossAxisAlignment,
            children: safeChildren,
          );

          if (scrollableFallback) {
            col = SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: col,
            );
          }
          content = col;
        } else {
          final List<Widget> spaced = _buildSpacedChildren(false, spacing);
          Widget row = Row(
            mainAxisSize: mainAxisSize,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: spaced,
          );

          if (scrollableFallback) {
            row = SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: row,
            );
          }
          content = row;
        }

        if (maxContentWidth != null && width > maxContentWidth!) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth!),
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }

  static WrapAlignment _mapMainAxisAlignmentToWrap(
      MainAxisAlignment alignment) {
    switch (alignment) {
      case MainAxisAlignment.start:
        return WrapAlignment.start;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
    }
  }

  static WrapCrossAlignment _mapCrossAxisAlignmentToWrap(
      CrossAxisAlignment alignment) {
    switch (alignment) {
      case CrossAxisAlignment.start:
        return WrapCrossAlignment.start;
      case CrossAxisAlignment.end:
        return WrapCrossAlignment.end;
      case CrossAxisAlignment.center:
      case CrossAxisAlignment.baseline:
      case CrossAxisAlignment.stretch:
        return WrapCrossAlignment.center;
    }
  }
}
