import 'package:flutter/material.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';

/// An icon button that maintains WCAG minimum touch target bounds (>= 48x48dp) on touch devices.
class AdaptiveIconButton extends StatelessWidget {
  const AdaptiveIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconSize,
    this.color,
  });

  /// The icon widget.
  final Widget icon;

  /// Callback when pressed. If null, renders disabled.
  final VoidCallback? onPressed;

  /// Optional accessibility tooltip.
  final String? tooltip;

  /// Icon visual size.
  final double? iconSize;

  /// Icon color override.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveThemeData theme = AdaptiveScope.themeOf(ctx);
        final double minSize =
            layout.isCompact ? theme.sizing.touchTargetMin : 36.0;

        Widget button = IconButton(
          icon: icon,
          iconSize: iconSize ?? theme.sizing.iconMd,
          color: color,
          tooltip: tooltip,
          onPressed: onPressed,
          constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
        );

        return button;
      },
    );
  }
}
