import 'package:flutter/widgets.dart';

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
    this.columns,
    this.spacing = 16.0,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio = 1.0,
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
    this.columns,
    this.spacing = 16.0,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    required this.itemCount,
    required this.itemBuilder,
  }) : children = const [];

  /// Minimum width required for an individual grid cell before adding another column.
  final double minItemWidth;

  /// Explicit responsive column override. If null, columns are calculated dynamically via [AdaptiveEngine].
  final AdaptiveValue<int>? columns;

  /// Default uniform spacing between columns and rows.
  final double spacing;

  /// Specific spacing along the main axis. Falls back to [spacing].
  final double? mainAxisSpacing;

  /// Specific spacing along the cross axis. Falls back to [spacing].
  final double? crossAxisSpacing;

  /// Aspect ratio (width / height) of grid cells. Defaults to 1.0.
  final double childAspectRatio;

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
        final int resolvedColumns = columns?.resolve(layout) ??
            AdaptiveEngine.calculateColumns(
              layout.availableWidth,
              minItemWidth: minItemWidth,
              spacing: crossAxisSpacing ?? spacing,
            );

        final SliverGridDelegateWithFixedCrossAxisCount delegate =
            SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: resolvedColumns,
          mainAxisSpacing: mainAxisSpacing ?? spacing,
          crossAxisSpacing: crossAxisSpacing ?? spacing,
          childAspectRatio: childAspectRatio,
        );

        if (itemBuilder != null && itemCount != null) {
          return GridView.builder(
            gridDelegate: delegate,
            itemCount: itemCount!,
            itemBuilder: itemBuilder!,
            shrinkWrap: shrinkWrap,
            physics: physics,
            padding: padding,
          );
        }

        return GridView(
          gridDelegate: delegate,
          shrinkWrap: shrinkWrap,
          physics: physics,
          padding: padding,
          children: children,
        );
      },
    );
  }
}
