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

  /// The column children.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    if (spacing == null) {
      return Column(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    }

    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final double resolvedSpacing = spacing!.resolve(layout);
        final List<Widget> spacedChildren = <Widget>[];

        for (int i = 0; i < children.length; i++) {
          spacedChildren.add(children[i]);
          if (i < children.length - 1 && resolvedSpacing > 0.0) {
            spacedChildren.add(SizedBox(height: resolvedSpacing));
          }
        }

        return Column(
          mainAxisSize: mainAxisSize,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: spacedChildren,
        );
      },
    );
  }
}
