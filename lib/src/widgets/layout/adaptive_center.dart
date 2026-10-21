import 'package:flutter/widgets.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_value.dart';
import '../adaptive_builder.dart';

/// Centers its child horizontally while constraining its maximum width to maintain readability.
class AdaptiveCenter extends StatelessWidget {
  const AdaptiveCenter({
    super.key,
    this.maxWidth = const AdaptiveValue.fixed(720.0),
    this.widthFactor,
    this.heightFactor,
    required this.child,
  });

  /// Maximum readable content width constraint. Defaults to 720 dp.
  final AdaptiveValue<double> maxWidth;

  /// Optional width factor for [Center].
  final double? widthFactor;

  /// Optional height factor for [Center].
  final double? heightFactor;

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final double resolvedMaxWidth = maxWidth.resolve(layout);

        return Center(
          widthFactor: widthFactor,
          heightFactor: heightFactor,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
            child: child,
          ),
        );
      },
    );
  }
}
