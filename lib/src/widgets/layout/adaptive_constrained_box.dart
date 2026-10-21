import 'package:flutter/widgets.dart';

import '../../core/adaptive_constraints.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_value.dart';
import '../adaptive_builder.dart';

/// A constrained box widget resolving responsive minimum and maximum constraints.
class AdaptiveConstrainedBox extends StatelessWidget {
  const AdaptiveConstrainedBox({
    super.key,
    this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
    this.fallback = const BoxConstraints(),
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    required this.child,
  });

  final BoxConstraints? compact;
  final BoxConstraints? medium;
  final BoxConstraints? expanded;
  final BoxConstraints? large;
  final BoxConstraints? extraLarge;
  final BoxConstraints fallback;

  final AdaptiveValue<double>? minWidth;
  final AdaptiveValue<double>? maxWidth;
  final AdaptiveValue<double>? minHeight;
  final AdaptiveValue<double>? maxHeight;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        BoxConstraints baseConstraints = AdaptiveConstraints.responsive(
          layout: layout,
          compact: compact,
          medium: medium,
          expanded: expanded,
          large: large,
          extraLarge: extraLarge,
          fallback: fallback,
        );

        if (minWidth != null ||
            maxWidth != null ||
            minHeight != null ||
            maxHeight != null) {
          baseConstraints = AdaptiveConstraints.clamp(
            constraints: baseConstraints,
            minWidth: minWidth?.resolve(layout),
            maxWidth: maxWidth?.resolve(layout),
            minHeight: minHeight?.resolve(layout),
            maxHeight: maxHeight?.resolve(layout),
          );
        }

        return ConstrainedBox(constraints: baseConstraints, child: child);
      },
    );
  }
}
