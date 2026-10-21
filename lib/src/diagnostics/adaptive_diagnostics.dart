import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../core/adaptive_constraints.dart';

/// Diagnostic logger and validation utility for catching responsive bugs and accessibility issues.
class AdaptiveDiagnostics {
  const AdaptiveDiagnostics._();

  /// Logs a responsive layout violation or warning in debug mode.
  static void warn(String message, {Object? details}) {
    if (kDebugMode) {
      debugPrint(
          '⚠️ [AdaptiveUI Warning] $message${details != null ? ' | Details: $details' : ''}');
    }
  }

  /// Verifies that layout constraints are bounded where required.
  static void validateConstraints(
    BoxConstraints constraints, {
    required String component,
    bool requireBoundedWidth = false,
    bool requireBoundedHeight = false,
  }) {
    if (!kDebugMode) return;

    if (requireBoundedWidth &&
        AdaptiveConstraints.isUnboundedWidth(constraints)) {
      warn(
        '$component received unbounded width. This may trigger RenderFlex overflow or layout distortion.',
        details: constraints,
      );
    }
    if (requireBoundedHeight &&
        AdaptiveConstraints.isUnboundedHeight(constraints)) {
      warn(
        '$component received unbounded height inside a vertical layout.',
        details: constraints,
      );
    }
  }

  /// Verifies that an interactive control satisfies minimum touch target guidelines (WCAG: >= 48dp).
  static void validateTouchTarget({
    required double width,
    required double height,
    required double minSize,
    required String component,
  }) {
    if (!kDebugMode) return;

    if (width < minSize || height < minSize) {
      warn(
        '$component ($width x $height dp) is smaller than the recommended minimum touch target ($minSize dp).',
      );
    }
  }
}
