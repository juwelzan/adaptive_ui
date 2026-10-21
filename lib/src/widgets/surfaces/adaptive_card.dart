import 'package:flutter/material.dart';

import '../../core/adaptive_engine.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../core/adaptive_value.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';

/// A responsive surface card providing adaptive padding, elevation, and rounded corners.
class AdaptiveCard extends StatelessWidget {
  const AdaptiveCard({
    super.key,
    this.padding = const AdaptiveInsets.auto(),
    this.margin,
    this.color,
    this.elevation = 1.0,
    this.borderRadius,
    this.minContentWidth,
    this.horizontalScrollableOnConstrained = true,
    this.onTap,
    required this.child,
  });

  /// Internal responsive padding. Defaults to [AdaptiveInsets.auto()].
  final AdaptiveInsets padding;

  /// External responsive margin.
  final AdaptiveInsets? margin;

  /// Background surface color. Defaults to [AdaptiveColors.surface].
  final Color? color;

  /// Visual elevation. Defaults to 1.0.
  final double elevation;

  /// Corner radius override.
  final BorderRadius? borderRadius;

  /// Optional minimum content width. When bounded incoming width is smaller than this threshold,
  /// the card content is safely preserved inside a horizontal scroll view rather than crushing children.
  final double? minContentWidth;

  /// Whether to gracefully scroll content horizontally if parent width is critically narrow (< 72dp).
  /// Defaults to `true`.
  final bool horizontalScrollableOnConstrained;

  /// Optional click/tap callback.
  final VoidCallback? onTap;

  /// Card content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveThemeData theme = AdaptiveScope.themeOf(ctx);
        final EdgeInsets resolvedPadding =
            AdaptiveEngine.resolvePadding(layout, padding);
        final EdgeInsets resolvedMargin =
            AdaptiveEngine.resolvePadding(layout, margin);
        final BorderRadius resolvedRadius =
            borderRadius ?? theme.radii.toBorderRadius(theme.radii.lg);

        EdgeInsets safePadding = resolvedPadding;
        if (layout.constraints.hasBoundedWidth &&
            layout.constraints.maxWidth > 0) {
          final double maxH = (layout.constraints.maxWidth * 0.15)
              .clamp(0.0, resolvedPadding.left);
          if (safePadding.horizontal >= layout.constraints.maxWidth * 0.4) {
            safePadding = EdgeInsets.symmetric(
              horizontal: maxH,
              vertical: safePadding.vertical,
            );
          }
        }
        if (layout.constraints.hasBoundedHeight &&
            layout.constraints.maxHeight > 0) {
          final double maxV = (layout.constraints.maxHeight * 0.12)
              .clamp(0.0, resolvedPadding.top);
          if (safePadding.vertical >= layout.constraints.maxHeight * 0.4) {
            safePadding = EdgeInsets.symmetric(
              horizontal: safePadding.horizontal,
              vertical: maxV,
            );
          }
        }

        Widget innerContent = child;
        if (horizontalScrollableOnConstrained &&
            layout.constraints.hasBoundedWidth &&
            layout.constraints.maxWidth > 0) {
          final double effectiveMin = minContentWidth ?? 180.0;
          if (layout.constraints.maxWidth < effectiveMin) {
            innerContent = SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: effectiveMin,
                child: child,
              ),
            );
          }
        }

        Widget content = Padding(
          padding: safePadding,
          child: ClipRect(
            clipBehavior: Clip.antiAlias,
            child: innerContent,
          ),
        );

        if (onTap != null) {
          content = InkWell(
            onTap: onTap,
            borderRadius: resolvedRadius,
            child: content,
          );
        }

        Widget card = Material(
          color: color ?? theme.colors.surface,
          elevation: elevation,
          borderRadius: resolvedRadius,
          clipBehavior: Clip.antiAlias,
          child: content,
        );

        if (resolvedMargin != EdgeInsets.zero) {
          card = Padding(padding: resolvedMargin, child: card);
        }

        return card;
      },
    );
  }
}
