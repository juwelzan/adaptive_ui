import 'package:flutter/material.dart';

import '../../core/adaptive_engine.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../core/adaptive_value.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';

/// A foundational surface supporting customizable elevation, borders, and responsive padding.
class AdaptiveSurface extends StatelessWidget {
  const AdaptiveSurface({
    super.key,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.elevation = 0.0,
    required this.child,
  });

  final AdaptiveInsets? padding;
  final AdaptiveInsets? margin;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final double elevation;
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
            borderRadius ?? theme.radii.toBorderRadius(theme.radii.md);

        Widget surface = Material(
          color: color ?? theme.colors.surface,
          elevation: elevation,
          borderRadius: resolvedRadius,
          clipBehavior: Clip.antiAlias,
          shape: borderColor != null
              ? RoundedRectangleBorder(
                  borderRadius: resolvedRadius,
                  side: BorderSide(color: borderColor!, width: borderWidth),
                )
              : null,
          child: Padding(
            padding: resolvedPadding,
            child: child,
          ),
        );

        if (resolvedMargin != EdgeInsets.zero) {
          surface = Padding(padding: resolvedMargin, child: surface);
        }

        return surface;
      },
    );
  }
}
