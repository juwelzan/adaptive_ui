import 'package:flutter/material.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';

/// A toggle switch with touch target padding ensuring accessible tap areas.
class AdaptiveSwitch extends StatelessWidget {
  const AdaptiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveThemeData theme = AdaptiveScope.themeOf(ctx);
        final double minSize =
            layout.isCompact ? theme.sizing.touchTargetMin : 36.0;

        return ConstrainedBox(
          constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
          child: Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: activeColor ?? theme.colors.primary,
          ),
        );
      },
    );
  }
}
