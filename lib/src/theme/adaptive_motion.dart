import 'package:flutter/widgets.dart';

/// Centralized motion tokens, easing curves, and accessibility helpers for the adaptive UI framework.
@immutable
class AdaptiveMotion {
  const AdaptiveMotion._();

  /// Instant transition duration (0ms).
  static const Duration instant = Duration.zero;

  /// Fast transition duration for micro-interactions (150ms).
  static const Duration short = Duration(milliseconds: 150);

  /// Standard transition duration for container and layout shifts (300ms).
  static const Duration standard = Duration(milliseconds: 300);

  /// Moderate duration for larger UI transitions (400ms).
  static const Duration medium = Duration(milliseconds: 400);

  /// Long transition duration for modal or drawer entrances (600ms).
  static const Duration long = Duration(milliseconds: 600);

  /// Standard duration for looping shimmer sweeps (1500ms).
  static const Duration shimmer = Duration(milliseconds: 1500);

  /// Standard marquee scroll speed in logical pixels per second (50px/sec).
  static const double marqueeSpeed = 50.0;

  /// Standard cubic easing curve for natural UI transitions.
  static const Curve standardCurve = Curves.easeInOutCubic;

  /// Emphasized curve for entering elements and responsive expand transitions.
  static const Curve emphasizedCurve = Curves.fastOutSlowIn;

  /// Deceleration curve for exiting elements.
  static const Curve decelerateCurve = Curves.easeOutCubic;

  /// Acceleration curve.
  static const Curve accelerateCurve = Curves.easeInCubic;

  /// Determines whether animations should be disabled based on accessibility preferences.
  static bool isReducedMotion(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  /// Resolves effective animation duration, immediately returning [Duration.zero]
  /// if reduced motion is enabled on the ambient [context].
  static Duration resolveDuration(BuildContext context, Duration desired) {
    if (isReducedMotion(context)) {
      return Duration.zero;
    }
    return desired;
  }
}
