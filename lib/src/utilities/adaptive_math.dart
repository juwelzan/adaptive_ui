import 'dart:math' as math;

/// Mathematical utility functions for continuous scaling, interpolation, and geometric calculations.
class AdaptiveMath {
  const AdaptiveMath._();

  /// Computes a damped scale factor to prevent linear font explosion on ultra-wide screens.
  ///
  /// [currentDimension] is typically the available parent width or screen width.
  /// [baseDimension] is the reference screen width (e.g., 390.0).
  /// [damping] controls scaling sensitivity (0.0 = fixed size, 1.0 = linear proportional scaling).
  static double scaleWithDamping(
    double baseValue,
    double currentDimension,
    double baseDimension, {
    double damping = 0.45,
    double minScale = 0.8,
    double maxScale = 1.6,
  }) {
    if (baseDimension <= 0.0 || currentDimension <= 0.0) return baseValue;
    final double rawRatio = currentDimension / baseDimension;
    final double dampedRatio = 1.0 + (rawRatio - 1.0) * damping;
    final double clampedScale = dampedRatio.clamp(minScale, maxScale);
    return (baseValue * clampedScale * 100).round() / 100;
  }

  /// Linearly interpolates between [start] and [end] by [progress].
  static double lerp(double start, double end, double progress) {
    return start + (end - start) * progress.clamp(0.0, 1.0);
  }

  /// Clamps a numeric value between [min] and [max].
  static double clamp(double value, double min, double max) {
    return math.min(math.max(value, min), max);
  }
}
