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

        Widget content = Padding(
          padding: resolvedPadding,
          child: child,
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
