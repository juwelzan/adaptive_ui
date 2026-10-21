import 'package:flutter/widgets.dart';

import 'adaptive_colors.dart';
import 'adaptive_radii.dart';
import 'adaptive_sizing.dart';
import 'adaptive_spacing.dart';
import 'adaptive_typography.dart';

/// Complete theme data specification for the adaptive UI framework.
@immutable
class AdaptiveThemeData {
  /// Creates an adaptive theme configuration.
  const AdaptiveThemeData({
    this.brightness = Brightness.light,
    AdaptiveSpacing? spacing,
    AdaptiveSizing? sizing,
    AdaptiveRadii? radii,
    AdaptiveColors? colors,
    AdaptiveTypography? typography,
  })  : spacing = spacing ?? AdaptiveSpacing.standard,
        sizing = sizing ?? AdaptiveSizing.standard,
        radii = radii ?? AdaptiveRadii.standard,
        colors = colors ??
            (brightness == Brightness.dark
                ? AdaptiveColors.dark
                : AdaptiveColors.light),
        typography = typography ?? AdaptiveTypography.standard;

  /// Default light adaptive theme.
  factory AdaptiveThemeData.light() =>
      const AdaptiveThemeData(brightness: Brightness.light);

  /// Default dark adaptive theme.
  factory AdaptiveThemeData.dark() =>
      const AdaptiveThemeData(brightness: Brightness.dark);

  final Brightness brightness;
  final AdaptiveSpacing spacing;
  final AdaptiveSizing sizing;
  final AdaptiveRadii radii;
  final AdaptiveColors colors;
  final AdaptiveTypography typography;

  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;

  AdaptiveThemeData copyWith({
    Brightness? brightness,
    AdaptiveSpacing? spacing,
    AdaptiveSizing? sizing,
    AdaptiveRadii? radii,
    AdaptiveColors? colors,
    AdaptiveTypography? typography,
  }) {
    return AdaptiveThemeData(
      brightness: brightness ?? this.brightness,
      spacing: spacing ?? this.spacing,
      sizing: sizing ?? this.sizing,
      radii: radii ?? this.radii,
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveThemeData &&
          runtimeType == other.runtimeType &&
          brightness == other.brightness &&
          spacing == other.spacing &&
          sizing == other.sizing &&
          radii == other.radii &&
          colors == other.colors &&
          typography == other.typography;

  @override
  int get hashCode =>
      Object.hash(brightness, spacing, sizing, radii, colors, typography);
}
