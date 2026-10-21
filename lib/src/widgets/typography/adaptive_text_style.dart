import 'package:flutter/widgets.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_value.dart';

/// A responsive text style that resolves dynamic font sizes and metrics based on layout data.
@immutable
class AdaptiveTextStyle {
  const AdaptiveTextStyle({
    this.fontSize,
    this.color,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.fontFamily,
    this.decoration,
  });

  /// Factory creating an [AdaptiveTextStyle] from a standard Flutter [TextStyle].
  factory AdaptiveTextStyle.fromTextStyle(TextStyle style) {
    return AdaptiveTextStyle(
      fontSize:
          style.fontSize != null ? AdaptiveValue.fixed(style.fontSize!) : null,
      color: style.color,
      fontWeight: style.fontWeight,
      fontStyle: style.fontStyle,
      letterSpacing: style.letterSpacing,
      wordSpacing: style.wordSpacing,
      height: style.height,
      fontFamily: style.fontFamily,
      decoration: style.decoration,
    );
  }

  /// Responsive or fixed font size.
  final AdaptiveValue<double>? fontSize;

  final Color? color;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? height;
  final String? fontFamily;
  final TextDecoration? decoration;

  /// Resolves a concrete [TextStyle] for the given [layout] snapshot.
  TextStyle resolve(AdaptiveLayoutData layout) {
    return TextStyle(
      fontSize: fontSize?.resolve(layout),
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      fontFamily: fontFamily,
      decoration: decoration,
    );
  }

  AdaptiveTextStyle copyWith({
    AdaptiveValue<double>? fontSize,
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    String? fontFamily,
    TextDecoration? decoration,
  }) {
    return AdaptiveTextStyle(
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      height: height ?? this.height,
      fontFamily: fontFamily ?? this.fontFamily,
      decoration: decoration ?? this.decoration,
    );
  }
}
