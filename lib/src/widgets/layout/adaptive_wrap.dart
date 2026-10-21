import 'package:flutter/widgets.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_value.dart';
import '../adaptive_builder.dart';

/// A [Wrap] layout that dynamically adapts child spacing and run spacing.
class AdaptiveWrap extends StatelessWidget {
  const AdaptiveWrap({
    super.key,
    this.spacing,
    this.runSpacing,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.direction = Axis.horizontal,
    required this.children,
  });

  /// Horizontal or run-direction spacing between items.
  final AdaptiveValue<double>? spacing;

  /// Vertical or cross-axis spacing between runs.
  final AdaptiveValue<double>? runSpacing;

  /// Alignment of children within runs.
  final WrapAlignment alignment;

  /// Alignment of runs.
  final WrapAlignment runAlignment;

  /// Cross-axis alignment.
  final WrapCrossAlignment crossAxisAlignment;

  /// Layout direction.
  final Axis direction;

  /// Wrap children.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (spacing == null && runSpacing == null) {
      return Wrap(
        alignment: alignment,
        runAlignment: runAlignment,
        crossAxisAlignment: crossAxisAlignment,
        direction: direction,
        children: children,
      );
    }

    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        return Wrap(
          spacing: spacing?.resolve(layout) ?? 0.0,
          runSpacing: runSpacing?.resolve(layout) ?? 0.0,
          alignment: alignment,
          runAlignment: runAlignment,
          crossAxisAlignment: crossAxisAlignment,
          direction: direction,
          children: children,
        );
      },
    );
  }
}
