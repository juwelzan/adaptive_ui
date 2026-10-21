import 'package:flutter/widgets.dart';

import '../../core/adaptive_context.dart';
import '../../core/adaptive_layout_data.dart';

/// A flex child that automatically demotes from [Expanded] to an unconstrained child on collapsed or compact viewports.
///
/// Uses [AdaptiveContext.maybeOf] to inspect ambient layout without inserting intermediate
/// [LayoutBuilder] elements between this widget and its parent [Flex], preserving Flutter's
/// strict [ParentDataWidget] hierarchy contract.
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

    final AdaptiveLayoutData? layout = AdaptiveContext.maybeOf(context);
    if (layout != null && layout.isCompact) {
      return child;
    }

    return Expanded(flex: flex, child: child);
  }
}
