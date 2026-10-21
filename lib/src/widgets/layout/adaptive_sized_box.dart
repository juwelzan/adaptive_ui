import 'package:flutter/widgets.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_value.dart';
import '../adaptive_builder.dart';

/// A [SizedBox] equivalent supporting responsive [AdaptiveValue] dimensions.
class AdaptiveSizedBox extends StatelessWidget {
  const AdaptiveSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
  });

  /// Creates a square sized box where width and height share the same [dimension].
  const AdaptiveSizedBox.square({
    super.key,
    AdaptiveValue<double>? dimension,
    this.child,
  })  : width = dimension,
        height = dimension;

  /// Creates an empty sized box with zero dimensions.
  const AdaptiveSizedBox.shrink({super.key, this.child})
      : width = const AdaptiveValue.fixed(0.0),
        height = const AdaptiveValue.fixed(0.0);

  /// Creates a sized box expanding to parent bounds.
  const AdaptiveSizedBox.expand({super.key, this.child})
      : width = const AdaptiveValue.fixed(double.infinity),
        height = const AdaptiveValue.fixed(double.infinity);

  final AdaptiveValue<double>? width;
  final AdaptiveValue<double>? height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (width == null && height == null) {
      return SizedBox(child: child);
    }

    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        return SizedBox(
          width: width?.resolve(layout),
          height: height?.resolve(layout),
          child: child,
        );
      },
    );
  }
}
