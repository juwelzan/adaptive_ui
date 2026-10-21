import 'package:flutter/widgets.dart';

import '../core/adaptive_context.dart';
import '../core/adaptive_layout_data.dart';
import '../core/adaptive_scope.dart';

/// Signature for builders that consume [AdaptiveLayoutData].
typedef AdaptiveWidgetBuilder = Widget Function(
  BuildContext context,
  AdaptiveLayoutData layout,
);

/// A widget that evaluates parent constraints via [LayoutBuilder] and supplies [AdaptiveLayoutData] to its builder.
class AdaptiveBuilder extends StatelessWidget {
  const AdaptiveBuilder({
    super.key,
    required this.builder,
  });

  /// The widget builder receiving contextual layout data.
  final AdaptiveWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final AdaptiveLayoutData layout =
            AdaptiveContext.resolve(context, constraints);
        final AdaptiveScope? scope = AdaptiveScope.maybeOf(context);

        if (scope != null) {
          return AdaptiveScope(
            config: scope.config,
            theme: scope.theme,
            layout: layout,
            child: builder(context, layout),
          );
        }

        return builder(context, layout);
      },
    );
  }
}
