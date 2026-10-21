import 'package:flutter/foundation.dart';

import 'adaptive_colors.dart';
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

  AdaptiveTokens copyWith({
    AdaptiveSpacing? spacing,
    AdaptiveSizing? sizing,
    AdaptiveRadii? radii,
    AdaptiveColors? colors,
    AdaptiveTypography? typography,
  }) {
    return AdaptiveTokens(
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
      other is AdaptiveTokens &&
          runtimeType == other.runtimeType &&
          spacing == other.spacing &&
          sizing == other.sizing &&
          radii == other.radii &&
          colors == other.colors &&
          typography == other.typography;

  @override
  int get hashCode => Object.hash(spacing, sizing, radii, colors, typography);
}
