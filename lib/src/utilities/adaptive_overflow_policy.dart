import 'package:flutter/widgets.dart';

/// Defines how adaptive components handle constrained text or content overflow.
enum AdaptiveOverflowPolicy {
  /// Clips the overflowing content cleanly at the component boundary.
  clip,

  /// Truncates the overflowing content and displays an ellipsis (...).
  ellipsis,

  /// Wraps content into subsequent lines or rows where possible.
  wrap,

  /// Enables scrolling automatically when content overflows available bounds.
  scroll,

  /// Fades the overflowing edge of the content smoothly.
  fade;

  /// Converts this policy to a standard Flutter [TextOverflow] where applicable.
  TextOverflow toTextOverflow() {
    switch (this) {
      case AdaptiveOverflowPolicy.clip:
        return TextOverflow.clip;
      case AdaptiveOverflowPolicy.ellipsis:
        return TextOverflow.ellipsis;
      case AdaptiveOverflowPolicy.fade:
        return TextOverflow.fade;
      case AdaptiveOverflowPolicy.wrap:
      case AdaptiveOverflowPolicy.scroll:
        return TextOverflow.visible;
    }
  }
}
