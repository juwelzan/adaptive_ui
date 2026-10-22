import 'package:flutter/foundation.dart';

import 'adaptive_colors.dart';
import 'adaptive_density.dart';
import 'adaptive_elevations.dart';
import 'adaptive_radii.dart';
import 'adaptive_sizing.dart';
import 'adaptive_spacing.dart';
import 'adaptive_typography.dart';

/// Aggregation of design tokens used by the adaptive UI framework.
@immutable
class AdaptiveTokens {
  const AdaptiveTokens({
    this.spacing = AdaptiveSpacing.standard,
    this.sizing = AdaptiveSizing.standard,
    this.radii = AdaptiveRadii.standard,
    this.colors = AdaptiveColors.light,
    this.typography = AdaptiveTypography.standard,
    this.elevations = AdaptiveElevations.standard,
    this.density = AdaptiveDensity.comfortable,
  });

  /// Default light tokens bundle.
  static const AdaptiveTokens light = AdaptiveTokens(
    colors: AdaptiveColors.light,
  );

  /// Default dark tokens bundle.
  static const AdaptiveTokens dark = AdaptiveTokens(
    colors: AdaptiveColors.dark,
  );

  final AdaptiveSpacing spacing;
  final AdaptiveSizing sizing;
  final AdaptiveRadii radii;
  final AdaptiveColors colors;
  final AdaptiveTypography typography;
  final AdaptiveElevations elevations;
  final AdaptiveDensity density;

  AdaptiveTokens copyWith({
    AdaptiveSpacing? spacing,
    AdaptiveSizing? sizing,
    AdaptiveRadii? radii,
    AdaptiveColors? colors,
    AdaptiveTypography? typography,
    AdaptiveElevations? elevations,
    AdaptiveDensity? density,
  }) {
    return AdaptiveTokens(
      spacing: spacing ?? this.spacing,
      sizing: sizing ?? this.sizing,
      radii: radii ?? this.radii,
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      elevations: elevations ?? this.elevations,
      density: density ?? this.density,
    );
  }

  /// Linearly interpolates between two [AdaptiveTokens] bundles.
  static AdaptiveTokens lerp(AdaptiveTokens a, AdaptiveTokens b, double t) {
    return AdaptiveTokens(
      spacing: AdaptiveSpacing.lerp(a.spacing, b.spacing, t),
      sizing: AdaptiveSizing.lerp(a.sizing, b.sizing, t),
      radii: AdaptiveRadii.lerp(a.radii, b.radii, t),
      colors: AdaptiveColors.lerp(a.colors, b.colors, t),
      typography: AdaptiveTypography.lerp(a.typography, b.typography, t),
      elevations: AdaptiveElevations.lerp(a.elevations, b.elevations, t),
      density: AdaptiveDensity.lerp(a.density, b.density, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveTokens &&
          runtimeType == other.runtimeType &&
          spacing == other.spacing &&
          sizing == other.sizing &&
          radii == other.radii &&
          colors == other.colors &&
          typography == other.typography &&
          elevations == other.elevations &&
          density == other.density;

  @override
  int get hashCode => Object.hash(
        spacing,
        sizing,
        radii,
        colors,
        typography,
        elevations,
        density,
      );
}
