import 'package:flutter/foundation.dart';

/// Standard responsive breakpoint tiers for classifying viewport and parent container widths.
///
/// Threshold intervals adhere to standard half-open intervals `[min, max)`:
/// - [compact]: `[0.0, compactMax)` (default: `< 600 dp`)
/// - [medium]: `[compactMax, mediumMax)` (default: `600 - 839 dp`)
/// - [expanded]: `[mediumMax, expandedMax)` (default: `840 - 1199 dp`)
/// - [large]: `[expandedMax, largeMax)` (default: `1200 - 1599 dp`)
/// - [extraLarge]: `[largeMax, ∞)` (default: `≥ 1600 dp`)
///
/// Lower bounds are inclusive; upper bounds are exclusive.
enum Breakpoint implements Comparable<Breakpoint> {
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

  /// Returns true if this breakpoint is strictly smaller than [other].
  bool operator <(Breakpoint other) => index < other.index;

  /// Returns true if this breakpoint is smaller than or equal to [other].
  bool operator <=(Breakpoint other) => index <= other.index;

  /// Returns true if this breakpoint is strictly greater than [other].
  bool operator >(Breakpoint other) => index > other.index;

  /// Returns true if this breakpoint is greater than or equal to [other].
  bool operator >=(Breakpoint other) => index >= other.index;

  @override
  int compareTo(Breakpoint other) => index.compareTo(other.index);

  /// Returns true if this breakpoint is larger than or equal to [other].
  bool isAtLeast(Breakpoint other) => index >= other.index;

  /// Returns true if this breakpoint is smaller than or equal to [other].
  bool isAtMost(Breakpoint other) => index <= other.index;

  /// Pattern-matches over breakpoint tiers using functions, cascading gracefully to smaller tiers or [fallback].
  T when<T>({
    required T Function() compact,
    T Function()? medium,
    T Function()? expanded,
    T Function()? large,
    T Function()? extraLarge,
    T Function()? fallback,
  }) {
    switch (this) {
      case Breakpoint.compact:
        return compact();
      case Breakpoint.medium:
        return (medium ?? fallback ?? compact)();
      case Breakpoint.expanded:
        return (expanded ?? medium ?? fallback ?? compact)();
      case Breakpoint.large:
        return (large ?? expanded ?? medium ?? fallback ?? compact)();
      case Breakpoint.extraLarge:
        return (extraLarge ??
            large ??
            expanded ??
            medium ??
            fallback ??
            compact)();
    }
  }

  /// Resolves a value corresponding to this breakpoint tier, cascading gracefully to smaller tiers or [fallback].
  T value<T>({
    required T compact,
    T? medium,
    T? expanded,
    T? large,
    T? extraLarge,
    T? fallback,
  }) {
    switch (this) {
      case Breakpoint.compact:
        return compact;
      case Breakpoint.medium:
        return medium ?? fallback ?? compact;
      case Breakpoint.expanded:
        return expanded ?? medium ?? fallback ?? compact;
      case Breakpoint.large:
        return large ?? expanded ?? medium ?? fallback ?? compact;
      case Breakpoint.extraLarge:
        return extraLarge ?? large ?? expanded ?? medium ?? fallback ?? compact;
    }
  }
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

  /// Returns the `(min, max)` width range in logical pixels for [breakpoint].
  ({double min, double max}) rangeFor(Breakpoint breakpoint) {
    switch (breakpoint) {
      case Breakpoint.compact:
        return (min: 0.0, max: compactMax);
      case Breakpoint.medium:
        return (min: compactMax, max: mediumMax);
      case Breakpoint.expanded:
        return (min: mediumMax, max: expandedMax);
      case Breakpoint.large:
        return (min: expandedMax, max: largeMax);
      case Breakpoint.extraLarge:
        return (min: largeMax, max: double.infinity);
    }
  }

  /// True if [width] falls within the compact tier (`[0.0, compactMax)`).
  bool isCompact(double width) => width < compactMax;

  /// True if [width] falls within the medium tier (`[compactMax, mediumMax)`).
  bool isMedium(double width) => width >= compactMax && width < mediumMax;

  /// True if [width] falls within the expanded tier (`[mediumMax, expandedMax)`).
  bool isExpanded(double width) => width >= mediumMax && width < expandedMax;

  /// True if [width] falls within the large tier (`[expandedMax, largeMax)`).
  bool isLarge(double width) => width >= expandedMax && width < largeMax;

  /// True if [width] falls within the extra-large tier (`[largeMax, ∞)`).
  bool isExtraLarge(double width) => width >= largeMax;

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
