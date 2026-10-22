import 'package:flutter/widgets.dart';

/// Density presets for the adaptive UI framework.
enum AdaptiveDensityPreset {
  /// Compact density suitable for data-dense desktop dashboards and dense lists.
  compact,

  /// Comfortable density with standard touch targets and balanced spacing (default).
  comfortable,

  /// Spacious density with generous padding and larger touch areas for mobile touch-first interfaces.
  spacious,
}

/// Responsive density configuration controlling spacing scaling, item padding, and touch target deltas.
@immutable
class AdaptiveDensity {
  const AdaptiveDensity({
    this.preset = AdaptiveDensityPreset.comfortable,
    this.verticalSpacingMultiplier = 1.0,
    this.horizontalSpacingMultiplier = 1.0,
    this.touchTargetDelta = 0.0,
  });

  /// Compact density preset (25% tighter vertical spacing, 15% tighter horizontal spacing).
  static const AdaptiveDensity compact = AdaptiveDensity(
    preset: AdaptiveDensityPreset.compact,
    verticalSpacingMultiplier: 0.75,
    horizontalSpacingMultiplier: 0.85,
    touchTargetDelta: -4.0,
  );

  /// Standard comfortable density preset.
  static const AdaptiveDensity comfortable = AdaptiveDensity(
    preset: AdaptiveDensityPreset.comfortable,
    verticalSpacingMultiplier: 1.0,
    horizontalSpacingMultiplier: 1.0,
    touchTargetDelta: 0.0,
  );

  /// Spacious density preset (25% more vertical spacing, 15% more horizontal spacing).
  static const AdaptiveDensity spacious = AdaptiveDensity(
    preset: AdaptiveDensityPreset.spacious,
    verticalSpacingMultiplier: 1.25,
    horizontalSpacingMultiplier: 1.15,
    touchTargetDelta: 4.0,
  );

  /// Current density preset tier.
  final AdaptiveDensityPreset preset;

  /// Multiplier applied to vertical component padding and gap spacing.
  final double verticalSpacingMultiplier;

  /// Multiplier applied to horizontal component padding and gap spacing.
  final double horizontalSpacingMultiplier;

  /// Additive delta in logical pixels applied to minimum touch targets.
  final double touchTargetDelta;

  /// Adjusts [insets] according to the current density multipliers.
  EdgeInsets adjustInsets(EdgeInsets insets) {
    return EdgeInsets.fromLTRB(
      insets.left * horizontalSpacingMultiplier,
      insets.top * verticalSpacingMultiplier,
      insets.right * horizontalSpacingMultiplier,
      insets.bottom * verticalSpacingMultiplier,
    );
  }

  AdaptiveDensity copyWith({
    AdaptiveDensityPreset? preset,
    double? verticalSpacingMultiplier,
    double? horizontalSpacingMultiplier,
    double? touchTargetDelta,
  }) {
    return AdaptiveDensity(
      preset: preset ?? this.preset,
      verticalSpacingMultiplier:
          verticalSpacingMultiplier ?? this.verticalSpacingMultiplier,
      horizontalSpacingMultiplier:
          horizontalSpacingMultiplier ?? this.horizontalSpacingMultiplier,
      touchTargetDelta: touchTargetDelta ?? this.touchTargetDelta,
    );
  }

  /// Linearly interpolates between two [AdaptiveDensity] instances.
  static AdaptiveDensity lerp(AdaptiveDensity a, AdaptiveDensity b, double t) {
    return AdaptiveDensity(
      preset: t < 0.5 ? a.preset : b.preset,
      verticalSpacingMultiplier: a.verticalSpacingMultiplier +
          (b.verticalSpacingMultiplier - a.verticalSpacingMultiplier) * t,
      horizontalSpacingMultiplier: a.horizontalSpacingMultiplier +
          (b.horizontalSpacingMultiplier - a.horizontalSpacingMultiplier) * t,
      touchTargetDelta:
          a.touchTargetDelta + (b.touchTargetDelta - a.touchTargetDelta) * t,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveDensity &&
          runtimeType == other.runtimeType &&
          preset == other.preset &&
          verticalSpacingMultiplier == other.verticalSpacingMultiplier &&
          horizontalSpacingMultiplier == other.horizontalSpacingMultiplier &&
          touchTargetDelta == other.touchTargetDelta;

  @override
  int get hashCode => Object.hash(
        preset,
        verticalSpacingMultiplier,
        horizontalSpacingMultiplier,
        touchTargetDelta,
      );
}
