import 'package:flutter/widgets.dart';

/// Design tokens representing visual surface elevations and ambient shadow metrics.
@immutable
class AdaptiveElevations {
  const AdaptiveElevations({
    this.none = 0.0,
    this.low = 1.0,
    this.medium = 3.0,
    this.high = 6.0,
    this.extraHigh = 12.0,
  });

  /// Standard Material-aligned elevation scale.
  static const AdaptiveElevations standard = AdaptiveElevations();

  /// Flat zero-elevation surface.
  final double none;

  /// Subtle elevation for resting cards and cards on flat backgrounds (1.0 dp).
  final double low;

  /// Medium elevation for raised buttons, bottom sheets, and sticky headers (3.0 dp).
  final double medium;

  /// High elevation for floating action buttons, menus, and sidebars (6.0 dp).
  final double high;

  /// Extra high elevation for dialogs, popups, and modal surfaces (12.0 dp).
  final double extraHigh;

  /// Generates a realistic two-tier ambient and directional [BoxShadow] list for [elevation].
  List<BoxShadow> shadowOf(double elevation, {Color? color}) {
    if (elevation <= 0.0) return const [];
    final Color base = color ?? const Color(0x33000000);
    return [
      BoxShadow(
        color: base.withValues(alpha: 0.08),
        blurRadius: elevation * 2.0,
        offset: Offset(0.0, elevation * 0.5),
      ),
      BoxShadow(
        color: base.withValues(alpha: 0.05),
        blurRadius: elevation * 3.5,
        offset: Offset(0.0, elevation * 1.2),
      ),
    ];
  }

  AdaptiveElevations copyWith({
    double? none,
    double? low,
    double? medium,
    double? high,
    double? extraHigh,
  }) {
    return AdaptiveElevations(
      none: none ?? this.none,
      low: low ?? this.low,
      medium: medium ?? this.medium,
      high: high ?? this.high,
      extraHigh: extraHigh ?? this.extraHigh,
    );
  }

  /// Linearly interpolates between two [AdaptiveElevations] instances.
  static AdaptiveElevations lerp(
      AdaptiveElevations a, AdaptiveElevations b, double t) {
    return AdaptiveElevations(
      none: a.none + (b.none - a.none) * t,
      low: a.low + (b.low - a.low) * t,
      medium: a.medium + (b.medium - a.medium) * t,
      high: a.high + (b.high - a.high) * t,
      extraHigh: a.extraHigh + (b.extraHigh - a.extraHigh) * t,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveElevations &&
          runtimeType == other.runtimeType &&
          none == other.none &&
          low == other.low &&
          medium == other.medium &&
          high == other.high &&
          extraHigh == other.extraHigh;

  @override
  int get hashCode => Object.hash(none, low, medium, high, extraHigh);
}
