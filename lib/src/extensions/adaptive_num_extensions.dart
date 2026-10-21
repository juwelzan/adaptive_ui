import 'package:flutter/widgets.dart';

import '../core/adaptive_value.dart';

/// Extension methods on numeric types for streamlined spacing, insets, and dimension definitions.
extension AdaptiveNumExtensions on num {
  /// Converts numeric value directly to logical pixels (dp).
  double get dp => toDouble();

  /// Wraps numeric value into a fixed [AdaptiveValue].
  AdaptiveValue<double> get adaptive => AdaptiveValue.fixed(toDouble());

  /// Creates a square [SizedBox] spacer.
  SizedBox get gap => SizedBox(width: toDouble(), height: toDouble());

  /// Creates a horizontal [SizedBox] spacer.
  SizedBox get hGap => SizedBox(width: toDouble());

  /// Creates a vertical [SizedBox] spacer.
  SizedBox get vGap => SizedBox(height: toDouble());

  /// Creates uniform all-around [EdgeInsets].
  EdgeInsets get insetsAll => EdgeInsets.all(toDouble());

  /// Creates uniform symmetric horizontal [EdgeInsets].
  EdgeInsets get insetsHorizontal =>
      EdgeInsets.symmetric(horizontal: toDouble());

  /// Creates uniform symmetric vertical [EdgeInsets].
  EdgeInsets get insetsVertical => EdgeInsets.symmetric(vertical: toDouble());
}
