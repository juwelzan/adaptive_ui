import 'package:flutter/widgets.dart';

import '../../core/adaptive_layout_data.dart';
import '../adaptive_builder.dart';

/// A flex child that automatically demotes from [Expanded] to an unconstrained child on collapsed or compact viewports.
class AdaptiveExpanded extends StatelessWidget {
  const AdaptiveExpanded({
    super.key,
    this.flex = 1,
    this.disableWhenCollapsed = true,
    required this.child,
  });

  /// The flex factor to use when expanded in a horizontal row.
  final int flex;

  /// Whether to disable [Expanded] behavior and render [child] directly on compact viewports.
  final bool disableWhenCollapsed;

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!disableWhenCollapsed) {
      return Expanded(flex: flex, child: child);
    }

    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        if (layout.isCompact) {
          return child;
        }
        return Expanded(flex: flex, child: child);
      },
    );
  }
}
