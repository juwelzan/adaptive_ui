import 'package:flutter/foundation.dart';

/// Design tokens representing responsive spacing and gap metrics.
@immutable
class AdaptiveSpacing {
  const AdaptiveSpacing({
    this.xxs = 2.0,
    this.xs = 4.0,
    this.sm = 8.0,
    this.md = 16.0,
    this.lg = 24.0,
    this.xl = 32.0,
    this.xxl = 48.0,
  });

  /// Standard spacing scale.
  static const AdaptiveSpacing standard = AdaptiveSpacing();

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  AdaptiveSpacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return AdaptiveSpacing(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  /// Linearly interpolates between two [AdaptiveSpacing] instances.
  static AdaptiveSpacing lerp(AdaptiveSpacing a, AdaptiveSpacing b, double t) {
    return AdaptiveSpacing(
      xxs: a.xxs + (b.xxs - a.xxs) * t,
      xs: a.xs + (b.xs - a.xs) * t,
      sm: a.sm + (b.sm - a.sm) * t,
      md: a.md + (b.md - a.md) * t,
      lg: a.lg + (b.lg - a.lg) * t,
      xl: a.xl + (b.xl - a.xl) * t,
      xxl: a.xxl + (b.xxl - a.xxl) * t,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveSpacing &&
          runtimeType == other.runtimeType &&
          xxs == other.xxs &&
          xs == other.xs &&
          sm == other.sm &&
          md == other.md &&
          lg == other.lg &&
          xl == other.xl &&
          xxl == other.xxl;

  @override
  int get hashCode => Object.hash(xxs, xs, sm, md, lg, xl, xxl);
}
