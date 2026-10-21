import 'package:flutter/foundation.dart';

import '../utilities/adaptive_overflow_policy.dart';
import 'adaptive_breakpoints.dart';

/// Global configuration driving default responsive behaviors across the adaptive UI framework.
@immutable
class AdaptiveConfig {
  /// Creates an immutable adaptive configuration.
  const AdaptiveConfig({
    this.breakpoints = AdaptiveBreakpoints.standard,
    this.designBaseWidth = 390.0,
    this.designBaseHeight = 844.0,
    this.defaultOverflowPolicy = AdaptiveOverflowPolicy.ellipsis,
    this.enableDiagnostics = false,
    this.readableTextMaxWidth = 720.0,
    this.minTouchTargetSize = 48.0,
    this.autoFontScaling = true,
    this.maxFontScaleFactor = 2.0,
  })  : assert(designBaseWidth > 0, 'designBaseWidth must be positive'),
        assert(designBaseHeight > 0, 'designBaseHeight must be positive'),
        assert(
            readableTextMaxWidth > 0, 'readableTextMaxWidth must be positive'),
        assert(
            minTouchTargetSize >= 0, 'minTouchTargetSize cannot be negative'),
        assert(maxFontScaleFactor >= 1.0, 'maxFontScaleFactor must be >= 1.0');

  /// Fallback configuration with sensible defaults.
  static const AdaptiveConfig fallback = AdaptiveConfig();

  /// Breakpoint tier thresholds for classifying widths.
  final AdaptiveBreakpoints breakpoints;

  /// Reference design canvas width (e.g. Figma mobile mockup width, typically 390.0 or 375.0).
  final double designBaseWidth;

  /// Reference design canvas height (e.g. Figma mobile mockup height, typically 844.0 or 812.0).
  final double designBaseHeight;

  /// Default policy applied when content overflows its bounding box.
  final AdaptiveOverflowPolicy defaultOverflowPolicy;

  /// Whether diagnostic warnings (e.g. layout overflows, sub-minimum touch targets) are active.
  final bool enableDiagnostics;

  /// Maximum recommended width for long-form reading copy (default 720.0 dp).
  final double readableTextMaxWidth;

  /// Minimum interactive touch target dimension (WCAG requires at least 48x48 dp on touchscreens).
  final double minTouchTargetSize;

  /// Whether adaptive typography automatically scales based on viewport width.
  final bool autoFontScaling;

  /// Maximum accessibility text scaling cap to prevent visual clipping.
  final double maxFontScaleFactor;

  /// Copies this configuration with optional overrides.
  AdaptiveConfig copyWith({
    AdaptiveBreakpoints? breakpoints,
    double? designBaseWidth,
    double? designBaseHeight,
    AdaptiveOverflowPolicy? defaultOverflowPolicy,
    bool? enableDiagnostics,
    double? readableTextMaxWidth,
    double? minTouchTargetSize,
    bool? autoFontScaling,
    double? maxFontScaleFactor,
  }) {
    return AdaptiveConfig(
      breakpoints: breakpoints ?? this.breakpoints,
      designBaseWidth: designBaseWidth ?? this.designBaseWidth,
      designBaseHeight: designBaseHeight ?? this.designBaseHeight,
      defaultOverflowPolicy:
          defaultOverflowPolicy ?? this.defaultOverflowPolicy,
      enableDiagnostics: enableDiagnostics ?? this.enableDiagnostics,
      readableTextMaxWidth: readableTextMaxWidth ?? this.readableTextMaxWidth,
      minTouchTargetSize: minTouchTargetSize ?? this.minTouchTargetSize,
      autoFontScaling: autoFontScaling ?? this.autoFontScaling,
      maxFontScaleFactor: maxFontScaleFactor ?? this.maxFontScaleFactor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveConfig &&
          runtimeType == other.runtimeType &&
          breakpoints == other.breakpoints &&
          designBaseWidth == other.designBaseWidth &&
          designBaseHeight == other.designBaseHeight &&
          defaultOverflowPolicy == other.defaultOverflowPolicy &&
          enableDiagnostics == other.enableDiagnostics &&
          readableTextMaxWidth == other.readableTextMaxWidth &&
          minTouchTargetSize == other.minTouchTargetSize &&
          autoFontScaling == other.autoFontScaling &&
          maxFontScaleFactor == other.maxFontScaleFactor;

  @override
  int get hashCode => Object.hash(
        breakpoints,
        designBaseWidth,
        designBaseHeight,
        defaultOverflowPolicy,
        enableDiagnostics,
        readableTextMaxWidth,
        minTouchTargetSize,
        autoFontScaling,
        maxFontScaleFactor,
      );

  @override
  String toString() =>
      'AdaptiveConfig(baseWidth: $designBaseWidth, baseHeight: $designBaseHeight, readableMaxWidth: $readableTextMaxWidth)';
}
