import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../core/adaptive_context.dart';
import '../../core/adaptive_engine.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_value.dart';
import '../adaptive_builder.dart';

/// A responsive grid layout that dynamically distributes columns based on available parent width.
class AdaptiveGrid extends StatelessWidget {
  /// Creates a responsive grid from a fixed list of [children].
  const AdaptiveGrid({
    super.key,
    this.minItemWidth = 240.0,
    this.maxItemWidth,
    this.maxContentWidth,
    this.maxColumns = 12,
    this.minColumns = 1,
    this.columns,
    this.spacing = 16.0,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    required this.children,
  })  : itemCount = null,
        itemBuilder = null;

  /// Creates a lazily-rendered responsive grid using an item builder callback.
  const AdaptiveGrid.builder({
    super.key,
    this.minItemWidth = 240.0,
    this.maxItemWidth,
    this.maxContentWidth,
    this.maxColumns = 12,
    this.minColumns = 1,
    this.columns,
    this.spacing = 16.0,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    required this.itemCount,
    required this.itemBuilder,
  }) : children = const [];

  /// Minimum width required for an individual grid cell before adding another column.
  final double minItemWidth;

  /// Optional maximum width for an individual grid cell.
  ///
  /// When specified, if wide parent constraints would cause cell width to exceed
  /// [maxItemWidth], additional columns will be automatically introduced.
  final double? maxItemWidth;

  /// Optional maximum content width for the entire grid.
  ///
  /// When parent constraints exceed this value, the grid is constrained to [maxContentWidth]
  /// and centered horizontally.
  final double? maxContentWidth;

  /// Maximum number of columns allowed. Defaults to 12.
  final int maxColumns;

  /// Minimum number of columns allowed. Defaults to 1.
  final int minColumns;

  /// Explicit responsive column override. If null, columns are calculated dynamically via [AdaptiveEngine].
  final AdaptiveValue<int>? columns;

  /// Default uniform spacing between columns and rows.
  final double spacing;

  /// Specific spacing along the main axis. Falls back to [spacing].
  final double? mainAxisSpacing;

  /// Specific spacing along the cross axis. Falls back to [spacing].
  final double? crossAxisSpacing;

  /// Aspect ratio (width / height) of grid cells. Defaults to 1.0.
  ///
  /// Ignored if [mainAxisExtent] is explicitly specified.
  final double childAspectRatio;

  /// Specific fixed height (in logical pixels) for grid items along the main axis.
  ///
  /// When provided, this overrides [childAspectRatio].
  final double? mainAxisExtent;

  /// Whether the grid should shrink-wrap its content height.
  final bool shrinkWrap;

  /// Scroll physics for the grid.
  final ScrollPhysics? physics;

  /// Grid outer padding.
  final EdgeInsetsGeometry? padding;

  /// Static children list.
  final List<Widget> children;

  /// Total count for builder constructor.
  final int? itemCount;

  /// Item builder callback.
  final IndexedWidgetBuilder? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final double rawWidth = layout.availableWidth > 0
            ? layout.availableWidth
            : layout.screenSize.width;

        final double effectiveGridWidth = maxContentWidth != null
            ? math.min(rawWidth, maxContentWidth!)
            : rawWidth;

        final int resolvedColumns = columns?.resolve(layout) ??
            AdaptiveEngine.calculateColumns(
              effectiveGridWidth,
              minItemWidth: minItemWidth,
              maxItemWidth: maxItemWidth,
              spacing: crossAxisSpacing ?? spacing,
              maxColumns: maxColumns,
              minColumns: minColumns,
            );

        final double resolvedSpacing = crossAxisSpacing ?? spacing;
        final double itemWidth = resolvedColumns > 0
            ? (effectiveGridWidth - (resolvedSpacing * (resolvedColumns - 1))) /
                resolvedColumns
            : effectiveGridWidth;

        double effectiveAspectRatio = childAspectRatio;
        if (mainAxisExtent == null &&
            itemWidth > 0 &&
            itemWidth < minItemWidth) {
          final double ratioFactor =
              (itemWidth / minItemWidth).clamp(0.55, 1.0);
          effectiveAspectRatio = childAspectRatio * ratioFactor;
        }

        final SliverGridDelegateWithFixedCrossAxisCount delegate =
            SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: resolvedColumns,
          mainAxisSpacing: mainAxisSpacing ?? spacing,
          crossAxisSpacing: resolvedSpacing,
          childAspectRatio: effectiveAspectRatio,
          mainAxisExtent: mainAxisExtent,
        );

        Widget grid;
        if (itemBuilder != null && itemCount != null) {
          grid = GridView.builder(
            gridDelegate: delegate,
            itemCount: itemCount!,
            itemBuilder: itemBuilder!,
            shrinkWrap: shrinkWrap,
            physics: physics,
            padding: padding,
          );
        } else {
          grid = GridView(
            gridDelegate: delegate,
            shrinkWrap: shrinkWrap,
            physics: physics,
            padding: padding,
            children: children,
          );
        }

        if (maxContentWidth != null && rawWidth > maxContentWidth!) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth!),
              child: grid,
            ),
          );
        }

        return grid;
      },
    );
  }
}

/// A responsive grid sliver that dynamically calculates cross-axis column count based on available sliver constraints.
///
/// Ideal for embedding responsive grids inside a [CustomScrollView] alongside sliver app bars,
/// headers, or other sliver elements.
class SliverAdaptiveGrid extends StatelessWidget {
  /// Creates a responsive sliver grid from a static list of [children].
  const SliverAdaptiveGrid({
    super.key,
    this.minItemWidth = 240.0,
    this.maxItemWidth,
    this.maxContentWidth,
    this.maxColumns = 12,
    this.minColumns = 1,
    this.columns,
    this.spacing = 16.0,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
    required this.children,
  })  : itemCount = null,
        itemBuilder = null;

  /// Creates a lazily-rendered responsive sliver grid using an [itemBuilder] callback.
  const SliverAdaptiveGrid.builder({
    super.key,
    this.minItemWidth = 240.0,
    this.maxItemWidth,
    this.maxContentWidth,
    this.maxColumns = 12,
    this.minColumns = 1,
    this.columns,
    this.spacing = 16.0,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
    required this.itemCount,
    required this.itemBuilder,
  }) : children = const [];

  /// Minimum width required for an individual grid cell before adding another column.
  final double minItemWidth;

  /// Optional maximum width for an individual grid cell.
  final double? maxItemWidth;

  /// Optional maximum content width for the entire grid.
  final double? maxContentWidth;

  /// Maximum number of columns allowed. Defaults to 12.
  final int maxColumns;

  /// Minimum number of columns allowed. Defaults to 1.
  final int minColumns;

  /// Explicit responsive column override.
  final AdaptiveValue<int>? columns;

  /// Default uniform spacing between columns and rows.
  final double spacing;

  /// Specific spacing along the main axis. Falls back to [spacing].
  final double? mainAxisSpacing;

  /// Specific spacing along the cross axis. Falls back to [spacing].
  final double? crossAxisSpacing;

  /// Aspect ratio (width / height) of grid cells. Defaults to 1.0.
  final double childAspectRatio;

  /// Specific fixed height (in logical pixels) for grid items along the main axis.
  final double? mainAxisExtent;

  /// Static children list.
  final List<Widget> children;

  /// Total count for builder constructor.
  final int? itemCount;

  /// Item builder callback.
  final NullableIndexedWidgetBuilder? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        final double rawWidth = constraints.crossAxisExtent;
        final double effectiveGridWidth = maxContentWidth != null
            ? math.min(rawWidth, maxContentWidth!)
            : rawWidth;

        final AdaptiveLayoutData layout = AdaptiveContext.resolve(
          context,
          BoxConstraints.tightFor(width: effectiveGridWidth),
        );

        final int resolvedColumns = columns?.resolve(layout) ??
            AdaptiveEngine.calculateColumns(
              effectiveGridWidth,
              minItemWidth: minItemWidth,
              maxItemWidth: maxItemWidth,
              spacing: crossAxisSpacing ?? spacing,
              maxColumns: maxColumns,
              minColumns: minColumns,
            );

        final double resolvedSpacing = crossAxisSpacing ?? spacing;
        final double itemWidth = resolvedColumns > 0
            ? (effectiveGridWidth - (resolvedSpacing * (resolvedColumns - 1))) /
                resolvedColumns
            : effectiveGridWidth;

        double effectiveAspectRatio = childAspectRatio;
        if (mainAxisExtent == null &&
            itemWidth > 0 &&
            itemWidth < minItemWidth) {
          final double ratioFactor =
              (itemWidth / minItemWidth).clamp(0.55, 1.0);
          effectiveAspectRatio = childAspectRatio * ratioFactor;
        }

        final SliverGridDelegateWithFixedCrossAxisCount delegate =
            SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: resolvedColumns,
          mainAxisSpacing: mainAxisSpacing ?? spacing,
          crossAxisSpacing: resolvedSpacing,
          childAspectRatio: effectiveAspectRatio,
          mainAxisExtent: mainAxisExtent,
        );

        Widget sliver;
        if (itemBuilder != null && itemCount != null) {
          sliver = SliverGrid(
            gridDelegate: delegate,
            delegate: SliverChildBuilderDelegate(
              itemBuilder!,
              childCount: itemCount!,
            ),
          );
        } else {
          sliver = SliverGrid(
            gridDelegate: delegate,
            delegate: SliverChildListDelegate(children),
          );
        }

        if (maxContentWidth != null && rawWidth > maxContentWidth!) {
          final double horizontalInset = (rawWidth - maxContentWidth!) / 2.0;
          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalInset),
            sliver: sliver,
          );
        }

        return sliver;
      },
    );
  }
}
