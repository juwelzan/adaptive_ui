import 'package:flutter/widgets.dart';

import '../../core/adaptive_layout_data.dart';
import '../adaptive_builder.dart';

/// A scroll view that manages keyboard avoidance and centers readable content on large screens.
class AdaptiveScrollView extends StatelessWidget {
  const AdaptiveScrollView({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.physics,
    this.controller,
    this.centerContent = false,
    this.maxContentWidth = 720.0,
    required this.child,
  });

  final Axis scrollDirection;
  final bool reverse;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  /// If true, content is constrained and centered to [maxContentWidth] on wide screens.
  final bool centerContent;

  /// Maximum content width when [centerContent] is enabled. Defaults to 720 dp.
  final double maxContentWidth;

  /// Scroll content child.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        Widget content = child;

        if (centerContent && scrollDirection == Axis.vertical) {
          content = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: content,
            ),
          );
        }

        // Apply keyboard viewInsets padding automatically if needed
        final EdgeInsets effectivePadding =
            (padding as EdgeInsets? ?? EdgeInsets.zero) +
                (layout.isKeyboardVisible
                    ? EdgeInsets.only(bottom: layout.viewInsets.bottom)
                    : EdgeInsets.zero);

        return SingleChildScrollView(
          scrollDirection: scrollDirection,
          reverse: reverse,
          padding: effectivePadding,
          physics: physics,
          controller: controller,
          child: content,
        );
      },
    );
  }
}
