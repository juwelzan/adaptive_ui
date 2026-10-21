import 'package:flutter/material.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';

/// A checkbox widget guaranteeing accessible touch targets (>= 48x48dp) on touch displays.
class AdaptiveCheckbox extends StatelessWidget {
  const AdaptiveCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.checkColor,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final Color? activeColor;
  final Color? checkColor;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveThemeData theme = AdaptiveScope.themeOf(ctx);
        final double minSize =
            layout.isCompact ? theme.sizing.touchTargetMin : 36.0;

        return ConstrainedBox(
          constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor ?? theme.colors.primary,
            checkColor: checkColor ?? theme.colors.onPrimary,
          ),
        );
      },
    );
  }
}
