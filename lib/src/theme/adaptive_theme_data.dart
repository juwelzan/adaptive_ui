import 'package:flutter/material.dart';

import 'adaptive_colors.dart';
import 'adaptive_component_themes.dart';
import 'adaptive_density.dart';
import 'adaptive_elevations.dart';
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
    AdaptiveElevations? elevations,
    AdaptiveDensity? density,
    AdaptiveComponentThemes? componentThemes,
  })  : spacing = spacing ?? AdaptiveSpacing.standard,
        sizing = sizing ?? AdaptiveSizing.standard,
        radii = radii ?? AdaptiveRadii.standard,
        colors = colors ??
            (brightness == Brightness.dark
                ? AdaptiveColors.dark
                : AdaptiveColors.light),
        typography = typography ?? AdaptiveTypography.standard,
        elevations = elevations ?? AdaptiveElevations.standard,
        density = density ?? AdaptiveDensity.comfortable,
        componentThemes = componentThemes ?? const AdaptiveComponentThemes();

  /// Default light adaptive theme.
  factory AdaptiveThemeData.light() =>
      const AdaptiveThemeData(brightness: Brightness.light);

  /// Default dark adaptive theme.
  factory AdaptiveThemeData.dark() =>
      const AdaptiveThemeData(brightness: Brightness.dark);

  /// Automatically derives an [AdaptiveThemeData] from Flutter's [ThemeData].
  factory AdaptiveThemeData.fromTheme(ThemeData theme) {
    return AdaptiveThemeData(
      brightness: theme.brightness,
      colors: AdaptiveColors.fromColorScheme(theme.colorScheme),
      typography: AdaptiveTypography.fromTextTheme(theme.textTheme),
      density: theme.visualDensity == VisualDensity.compact
          ? AdaptiveDensity.compact
          : AdaptiveDensity.comfortable,
    );
  }

  /// Automatically derives an [AdaptiveThemeData] from Flutter's [ColorScheme].
  factory AdaptiveThemeData.fromColorScheme(ColorScheme scheme) {
    return AdaptiveThemeData(
      brightness: scheme.brightness,
      colors: AdaptiveColors.fromColorScheme(scheme),
    );
  }

  final Brightness brightness;
  final AdaptiveSpacing spacing;
  final AdaptiveSizing sizing;
  final AdaptiveRadii radii;
  final AdaptiveColors colors;
  final AdaptiveTypography typography;
  final AdaptiveElevations elevations;
  final AdaptiveDensity density;
  final AdaptiveComponentThemes componentThemes;

  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;

  /// Card-specific theme configuration.
  AdaptiveCardThemeData get cardTheme => componentThemes.card;

  /// Button-specific theme configuration.
  AdaptiveButtonThemeData get buttonTheme => componentThemes.button;

  /// Sidebar-specific theme configuration.
  AdaptiveSidebarThemeData get sidebarTheme => componentThemes.sidebar;

  /// Bottom navigation bar-specific theme configuration.
  AdaptiveBottomNavThemeData get bottomNavTheme => componentThemes.bottomNav;

  /// Shimmer and skeleton loading-specific theme configuration.
  AdaptiveShimmerThemeData get shimmerTheme => componentThemes.shimmer;

  /// Input and form field-specific theme configuration.
  AdaptiveInputThemeData get inputTheme => componentThemes.input;

  AdaptiveThemeData copyWith({
    Brightness? brightness,
    AdaptiveSpacing? spacing,
    AdaptiveSizing? sizing,
    AdaptiveRadii? radii,
    AdaptiveColors? colors,
    AdaptiveTypography? typography,
    AdaptiveElevations? elevations,
    AdaptiveDensity? density,
    AdaptiveComponentThemes? componentThemes,
    AdaptiveCardThemeData? cardTheme,
    AdaptiveButtonThemeData? buttonTheme,
    AdaptiveSidebarThemeData? sidebarTheme,
    AdaptiveBottomNavThemeData? bottomNavTheme,
    AdaptiveShimmerThemeData? shimmerTheme,
    AdaptiveInputThemeData? inputTheme,
  }) {
    final AdaptiveComponentThemes effectiveComponentThemes =
        (componentThemes ?? this.componentThemes).copyWith(
      card: cardTheme,
      button: buttonTheme,
      sidebar: sidebarTheme,
      bottomNav: bottomNavTheme,
      shimmer: shimmerTheme,
      input: inputTheme,
    );

    return AdaptiveThemeData(
      brightness: brightness ?? this.brightness,
      spacing: spacing ?? this.spacing,
      sizing: sizing ?? this.sizing,
      radii: radii ?? this.radii,
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      elevations: elevations ?? this.elevations,
      density: density ?? this.density,
      componentThemes: effectiveComponentThemes,
    );
  }

  /// Linearly interpolates between two [AdaptiveThemeData] instances.
  static AdaptiveThemeData lerp(
      AdaptiveThemeData a, AdaptiveThemeData b, double t) {
    return AdaptiveThemeData(
      brightness: t < 0.5 ? a.brightness : b.brightness,
      spacing: AdaptiveSpacing.lerp(a.spacing, b.spacing, t),
      sizing: AdaptiveSizing.lerp(a.sizing, b.sizing, t),
      radii: AdaptiveRadii.lerp(a.radii, b.radii, t),
      colors: AdaptiveColors.lerp(a.colors, b.colors, t),
      typography: AdaptiveTypography.lerp(a.typography, b.typography, t),
      elevations: AdaptiveElevations.lerp(a.elevations, b.elevations, t),
      density: AdaptiveDensity.lerp(a.density, b.density, t),
      componentThemes:
          AdaptiveComponentThemes.lerp(a.componentThemes, b.componentThemes, t),
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
          typography == other.typography &&
          elevations == other.elevations &&
          density == other.density &&
          componentThemes == other.componentThemes;

  @override
  int get hashCode => Object.hash(
        brightness,
        spacing,
        sizing,
        radii,
        colors,
        typography,
        elevations,
        density,
        componentThemes,
      );
}
