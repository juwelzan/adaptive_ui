import 'package:flutter/widgets.dart';

import '../../core/adaptive_constraints.dart';
import '../../core/adaptive_engine.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_value.dart';
import '../../theme/adaptive_motion.dart';
import '../adaptive_builder.dart';

/// A responsive container that resolves padding, margins, and constraints per viewport,
/// with optional composable implicit animations for visual property transitions.
class AdaptiveContainer extends StatefulWidget {
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
    this.hoverDecoration,
    this.pressDecoration,
    this.alignment,
    this.clipBehavior = Clip.none,
    this.animateChanges = false,
    this.animationDuration,
    this.animationCurve = AdaptiveMotion.standardCurve,
    this.onEnd,
    this.opacity = 1.0,
    this.onTap,
    this.onHover,
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

  /// Optional decoration applied when the mouse hovers over this container.
  final Decoration? hoverDecoration;

  /// Optional decoration applied when the container is pressed.
  final Decoration? pressDecoration;

  /// Child alignment within the container.
  final AlignmentGeometry? alignment;

  /// Clipping strategy applied to the container.
  final Clip clipBehavior;

  /// Whether changes to decoration, size, padding, alignment, and opacity should animate smoothly.
  /// Defaults to `false` for zero-overhead static rendering.
  final bool animateChanges;

  /// Duration of property transition animations. Defaults to [AdaptiveMotion.standard] (300ms).
  final Duration? animationDuration;

  /// Easing curve for animated transitions. Defaults to [AdaptiveMotion.standardCurve].
  final Curve animationCurve;

  /// Optional callback invoked when the property animation completes.
  final VoidCallback? onEnd;

  /// Opacity multiplier (0.0 to 1.0).
  final double opacity;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Optional hover state change callback.
  final ValueChanged<bool>? onHover;

  /// Child widget.
  final Widget? child;

  @override
  State<AdaptiveContainer> createState() => _AdaptiveContainerState();
}

class _AdaptiveContainerState extends State<AdaptiveContainer> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _handleHover(bool hovered) {
    if (_isHovered != hovered) {
      setState(() => _isHovered = hovered);
      widget.onHover?.call(hovered);
    }
  }

  Decoration? _resolveEffectiveDecoration() {
    if (_isPressed && widget.pressDecoration != null) {
      return widget.pressDecoration;
    }
    if (_isHovered && widget.hoverDecoration != null) {
      return widget.hoverDecoration;
    }
    return widget.decoration;
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final EdgeInsets resolvedPadding =
            AdaptiveEngine.resolvePadding(layout, widget.padding);
        final EdgeInsets resolvedMargin =
            AdaptiveEngine.resolvePadding(layout, widget.margin);

        final double? resolvedWidth = widget.width?.resolve(layout);
        final double? resolvedHeight = widget.height?.resolve(layout);

        BoxConstraints constraints = BoxConstraints(
          minWidth: widget.minWidth ?? (resolvedWidth ?? 0.0),
          maxWidth: widget.maxWidth ?? (resolvedWidth ?? double.infinity),
          minHeight: widget.minHeight ?? (resolvedHeight ?? 0.0),
          maxHeight: widget.maxHeight ?? (resolvedHeight ?? double.infinity),
        );

        // Clamp safely if parent constraints are bounded
        if (layout.constraints.hasBoundedWidth) {
          constraints = AdaptiveConstraints.clamp(
            constraints: constraints,
            maxWidth: layout.constraints.maxWidth,
          );
        }

        final Decoration? effectiveDecoration = _resolveEffectiveDecoration();
        final bool reducedMotion = AdaptiveMotion.isReducedMotion(ctx);
        final Duration effectiveDuration =
            (reducedMotion || !widget.animateChanges)
                ? Duration.zero
                : (widget.animationDuration ?? AdaptiveMotion.standard);

        Widget current = widget.child ?? const SizedBox.shrink();

        // Animated changes active:
        if (widget.animateChanges && !reducedMotion) {
          current = AnimatedContainer(
            duration: effectiveDuration,
            curve: widget.animationCurve,
            alignment: widget.alignment,
            padding: resolvedPadding,
            margin: resolvedMargin,
            decoration: effectiveDecoration,
            foregroundDecoration: widget.foregroundDecoration,
            constraints: constraints,
            clipBehavior: widget.clipBehavior,
            onEnd: widget.onEnd,
            child: current,
          );

          if (widget.opacity < 1.0) {
            current = AnimatedOpacity(
              duration: effectiveDuration,
              curve: widget.animationCurve,
              opacity: widget.opacity.clamp(0.0, 1.0),
              child: current,
            );
          }
        } else {
          // Standard static layout:
          if (widget.alignment != null) {
            current = Align(alignment: widget.alignment!, child: current);
          }

          if (resolvedPadding != EdgeInsets.zero) {
            current = Padding(padding: resolvedPadding, child: current);
          }

          if (widget.foregroundDecoration != null) {
            current = DecoratedBox(
              decoration: widget.foregroundDecoration!,
              position: DecorationPosition.foreground,
              child: current,
            );
          }

          if (effectiveDecoration != null) {
            current = DecoratedBox(
              decoration: effectiveDecoration,
              position: DecorationPosition.background,
              child: current,
            );
          }

          if (widget.clipBehavior != Clip.none) {
            current =
                ClipRect(clipBehavior: widget.clipBehavior, child: current);
          }

          current = ConstrainedBox(constraints: constraints, child: current);

          if (resolvedMargin != EdgeInsets.zero) {
            current = Padding(padding: resolvedMargin, child: current);
          }

          if (widget.opacity < 1.0) {
            current = Opacity(
              opacity: widget.opacity.clamp(0.0, 1.0),
              child: current,
            );
          }
        }

        // Add interactive hover / tap handling if configured:
        final bool isInteractive = widget.onTap != null ||
            widget.hoverDecoration != null ||
            widget.pressDecoration != null ||
            widget.onHover != null;

        if (isInteractive) {
          current = MouseRegion(
            onEnter: (_) => _handleHover(true),
            onExit: (_) => _handleHover(false),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: widget.onTap,
              child: current,
            ),
          );
        }

        return current;
      },
    );
  }
}
