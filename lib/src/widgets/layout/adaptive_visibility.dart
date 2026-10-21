import 'package:flutter/widgets.dart';

import '../../core/adaptive_breakpoints.dart';
import '../../core/adaptive_layout_data.dart';
import '../adaptive_builder.dart';

/// Shows or hides a child widget conditionally based on breakpoint tiers.
class AdaptiveVisibility extends StatelessWidget {
  const AdaptiveVisibility({
    super.key,
    this.visibleBreakpoints,
    this.hiddenBreakpoints,
    this.visible,
    this.replacement = const SizedBox.shrink(),
    required this.child,
  });

  /// Specific breakpoints where this child must be visible.
  final Set<Breakpoint>? visibleBreakpoints;

  /// Specific breakpoints where this child must be hidden.
  final Set<Breakpoint>? hiddenBreakpoints;

  /// Procedural visibility predicate evaluating [AdaptiveLayoutData].
  final bool Function(AdaptiveLayoutData layout)? visible;

  /// Widget rendered when hidden. Defaults to [SizedBox.shrink].
  final Widget replacement;

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        bool isVisible = true;

        if (visible != null) {
          isVisible = visible!(layout);
        } else if (visibleBreakpoints != null) {
          isVisible = visibleBreakpoints!.contains(layout.containerBreakpoint);
        } else if (hiddenBreakpoints != null) {
          isVisible = !hiddenBreakpoints!.contains(layout.containerBreakpoint);
        }

        return isVisible ? child : replacement;
      },
    );
  }
}
