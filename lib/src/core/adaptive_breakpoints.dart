import 'package:flutter/foundation.dart';

/// Standard responsive breakpoint tiers for classifying viewport and parent container widths.
enum Breakpoint {
  /// Compact viewports (< 600 dp) such as phones in portrait and narrow side panels.
  compact,

  /// Medium viewports (600 - 839 dp) such as tablets in portrait and foldables.
  medium,

  /// Expanded viewports (840 - 1199 dp) such as tablets in landscape and small laptops.
  expanded,

  /// Large viewports (1200 - 1599 dp) such as desktop monitors and large laptops.
  large,

  /// Extra-large viewports (>= 1600 dp) such as ultra-wide monitors and multi-window displays.
  extraLarge;

  /// Whether this breakpoint represents a handheld phone or narrow container.
  bool get isCompact => this == Breakpoint.compact;

  /// Whether this breakpoint represents a medium display.
  bool get isMedium => this == Breakpoint.medium;

  /// Whether this breakpoint represents an expanded tablet or small desktop display.
  bool get isExpanded => this == Breakpoint.expanded;

  /// Whether this breakpoint represents a large desktop display.
  bool get isLarge => this == Breakpoint.large;

  /// Whether this breakpoint represents an ultra-wide or high-res desktop display.
  bool get isExtraLarge => this == Breakpoint.extraLarge;

  /// Returns true if this breakpoint is larger than or equal to [other].
  bool isAtLeast(Breakpoint other) => index >= other.index;

  /// Returns true if this breakpoint is smaller than or equal to [other].
  bool isAtMost(Breakpoint other) => index <= other.index;
}

/// Configurable width thresholds for classifying container and screen dimensions.
@immutable
class AdaptiveBreakpoints {
  /// Creates an immutable set of breakpoint thresholds.
  const AdaptiveBreakpoints({
    this.compactMax = 600.0,
    this.mediumMax = 840.0,
    this.expandedMax = 1200.0,
    this.largeMax = 1600.0,
  })  : assert(compactMax > 0, 'compactMax must be positive'),
        assert(mediumMax > compactMax,
            'mediumMax must be greater than compactMax'),
        assert(expandedMax > mediumMax,
            'expandedMax must be greater than mediumMax'),
        assert(largeMax > expandedMax,
            'largeMax must be greater than expandedMax');

  /// The standard Material 3 responsive breakpoint configuration.
  static const AdaptiveBreakpoints standard = AdaptiveBreakpoints();

  /// Maximum width for the [Breakpoint.compact] tier. Default: 600.0.
  final double compactMax;

  /// Maximum width for the [Breakpoint.medium] tier. Default: 840.0.
  final double mediumMax;

  /// Maximum width for the [Breakpoint.expanded] tier. Default: 1200.0.
  final double expandedMax;

  /// Maximum width for the [Breakpoint.large] tier. Default: 1600.0.
  final double largeMax;

  /// Resolves the corresponding [Breakpoint] for a given [width] in logical pixels.
  Breakpoint resolve(double width) {
    if (width < compactMax) {
      return Breakpoint.compact;
    } else if (width < mediumMax) {
      return Breakpoint.medium;
    } else if (width < expandedMax) {
      return Breakpoint.expanded;
    } else if (width < largeMax) {
      return Breakpoint.large;
    } else {
      return Breakpoint.extraLarge;
    }
  }

  /// Copies this breakpoint configuration with optional overrides.
  AdaptiveBreakpoints copyWith({
    double? compactMax,
    double? mediumMax,
    double? expandedMax,
    double? largeMax,
  }) {
    return AdaptiveBreakpoints(
      compactMax: compactMax ?? this.compactMax,
      mediumMax: mediumMax ?? this.mediumMax,
      expandedMax: expandedMax ?? this.expandedMax,
      largeMax: largeMax ?? this.largeMax,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveBreakpoints &&
          runtimeType == other.runtimeType &&
          compactMax == other.compactMax &&
          mediumMax == other.mediumMax &&
          expandedMax == other.expandedMax &&
          largeMax == other.largeMax;

  @override
  int get hashCode => Object.hash(compactMax, mediumMax, expandedMax, largeMax);

  @override
  String toString() =>
      'AdaptiveBreakpoints(compact: <$compactMax, medium: <$mediumMax, expanded: <$expandedMax, large: <$largeMax)';
}
