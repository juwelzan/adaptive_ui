import 'package:flutter/widgets.dart';

import '../../core/adaptive_constraints.dart';
import '../../core/adaptive_engine.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_value.dart';
import '../adaptive_builder.dart';

/// A responsive container that automatically resolves padding, margins, and constraints per viewport.
class AdaptiveContainer extends StatelessWidget {
  const AdaptiveContainer({
    super.key,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.padding,
    this.margin,
    this.decoration,
    this.foregroundDecoration,
    this.alignment,
    this.clipBehavior = Clip.none,
    this.child,
  });

  /// Responsive or fixed width.
  final AdaptiveValue<double>? width;

  /// Responsive or fixed height.
  final AdaptiveValue<double>? height;

  /// Minimum width constraint.
  final double? minWidth;

  /// Maximum width constraint.
  final double? maxWidth;

  /// Minimum height constraint.
  final double? minHeight;

  /// Maximum height constraint.
  final double? maxHeight;

  /// Responsive or automatic padding.
  final AdaptiveInsets? padding;

  /// Responsive or automatic margin.
  final AdaptiveInsets? margin;

  /// Visual styling applied behind the child.
  final Decoration? decoration;

  /// Visual styling applied in front of the child.
  final Decoration? foregroundDecoration;

  /// Child alignment within the container.
  final AlignmentGeometry? alignment;

  /// Clipping strategy applied to the container.
  final Clip clipBehavior;

  /// Child widget.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final EdgeInsets resolvedPadding =
            AdaptiveEngine.resolvePadding(layout, padding);
        final EdgeInsets resolvedMargin =
            AdaptiveEngine.resolvePadding(layout, margin);

        final double? resolvedWidth = width?.resolve(layout);
        final double? resolvedHeight = height?.resolve(layout);

        BoxConstraints constraints = BoxConstraints(
          minWidth: minWidth ?? (resolvedWidth ?? 0.0),
          maxWidth: maxWidth ?? (resolvedWidth ?? double.infinity),
          minHeight: minHeight ?? (resolvedHeight ?? 0.0),
          maxHeight: maxHeight ?? (resolvedHeight ?? double.infinity),
        );

        // Clamp safely if parent constraints are bounded
        if (layout.constraints.hasBoundedWidth) {
          constraints = AdaptiveConstraints.clamp(
            constraints: constraints,
            maxWidth: layout.constraints.maxWidth,
          );
        }

        Widget current = child ?? const SizedBox.shrink();

        if (alignment != null) {
          current = Align(alignment: alignment!, child: current);
        }

        if (resolvedPadding != EdgeInsets.zero) {
          current = Padding(padding: resolvedPadding, child: current);
        }

        if (decoration != null ||
            foregroundDecoration != null ||
            clipBehavior != Clip.none) {
          current = DecoratedBox(
            decoration: decoration ?? const BoxDecoration(),
            position: DecorationPosition.background,
            child: foregroundDecoration != null
                ? DecoratedBox(
                    decoration: foregroundDecoration!,
                    position: DecorationPosition.foreground,
                    child: current,
                  )
                : current,
          );
          if (clipBehavior != Clip.none) {
            current = ClipRect(clipBehavior: clipBehavior, child: current);
          }
        }

        current = ConstrainedBox(constraints: constraints, child: current);

        if (resolvedMargin != EdgeInsets.zero) {
          current = Padding(padding: resolvedMargin, child: current);
        }

        return current;
      },
    );
  }
}
