import 'package:flutter/widgets.dart';

import '../../core/adaptive_engine.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_value.dart';
import '../adaptive_builder.dart';

/// A padding widget that resolves responsive padding based on viewport breakpoint.
class AdaptivePadding extends StatelessWidget {
  const AdaptivePadding({
    super.key,
    this.padding = const AdaptiveInsets.auto(),
    required this.child,
  });

  /// The responsive insets to apply. Defaults to [AdaptiveInsets.auto()].
  final AdaptiveInsets padding;

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final EdgeInsets resolved =
            AdaptiveEngine.resolvePadding(layout, padding);
        return Padding(padding: resolved, child: child);
      },
    );
  }
}
