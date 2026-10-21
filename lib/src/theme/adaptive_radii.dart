import 'package:flutter/widgets.dart';

/// Design tokens representing corner radii.
@immutable
class AdaptiveRadii {
  const AdaptiveRadii({
    this.none = 0.0,
    this.xs = 4.0,
    this.sm = 8.0,
    this.md = 12.0,
    this.lg = 16.0,
    this.xl = 24.0,
    this.full = 9999.0,
  });

  /// Standard corner radius tokens.
  static const AdaptiveRadii standard = AdaptiveRadii();

  final double none;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double full;

  BorderRadius toBorderRadius(double radius) => BorderRadius.circular(radius);

  AdaptiveRadii copyWith({
    double? none,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? full,
  }) {
    return AdaptiveRadii(
      none: none ?? this.none,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      full: full ?? this.full,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveRadii &&
          runtimeType == other.runtimeType &&
          none == other.none &&
          xs == other.xs &&
          sm == other.sm &&
          md == other.md &&
          lg == other.lg &&
          xl == other.xl &&
          full == other.full;

  @override
  int get hashCode => Object.hash(none, xs, sm, md, lg, xl, full);
}
