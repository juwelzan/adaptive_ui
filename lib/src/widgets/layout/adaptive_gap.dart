import 'package:flutter/widgets.dart';

import '../../core/adaptive_breakpoints.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_value.dart';
import '../adaptive_builder.dart';

/// A responsive spacing gap that automatically adjusts separation between flex or box siblings.
class AdaptiveGap extends StatelessWidget {
  const AdaptiveGap(
    this.size, {
    super.key,
  });

  /// An automatic gap that scales with container breakpoint (8dp on compact, 16dp on medium, 24dp on expanded+).
  const AdaptiveGap.auto({super.key})
      : size = const AdaptiveValue.breakpoint(
          compact: 8.0,
          medium: 16.0,
          expanded: 24.0,
          large: 32.0,
          extraLarge: 32.0,
          fallback: 16.0,
        );

  /// Fixed gap dimension.
  AdaptiveGap.fixed(double dimension, {super.key})
      : size = AdaptiveValue.fixed(dimension);

  final AdaptiveValue<double> size;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final double dimension = size.resolve(layout, () {
          switch (layout.containerBreakpoint) {
            case Breakpoint.compact:
              return 8.0;
            case Breakpoint.medium:
              return 16.0;
            case Breakpoint.expanded:
            case Breakpoint.large:
            case Breakpoint.extraLarge:
              return 24.0;
          }
        });
        return SizedBox(width: dimension, height: dimension);
      },
    );
  }
}
