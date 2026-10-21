import 'package:flutter/material.dart';

import '../../core/adaptive_scope.dart';
import '../../theme/adaptive_theme_data.dart';

/// A slider control that adapts colors and layout dimensions to current theme tokens.
class AdaptiveSlider extends StatelessWidget {
  const AdaptiveSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final AdaptiveThemeData theme = AdaptiveScope.themeOf(context);

    return Slider.adaptive(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      divisions: divisions,
      label: label,
      activeColor: activeColor ?? theme.colors.primary,
      inactiveColor: inactiveColor ?? theme.colors.surfaceVariant,
    );
  }
}
