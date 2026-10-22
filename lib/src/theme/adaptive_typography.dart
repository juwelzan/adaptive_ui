import 'package:flutter/material.dart';

/// Typography scale tokens providing baseline text styling.
@immutable
class AdaptiveTypography {
  const AdaptiveTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.titleLarge,
    required this.titleMedium,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    TextStyle? caption,
  }) : caption = caption ??
            const TextStyle(
                fontSize: 11.0, fontWeight: FontWeight.normal, height: 1.4);

  /// Standard Material-aligned typography scale.
  static const AdaptiveTypography standard = AdaptiveTypography(
    displayLarge:
        TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold, height: 1.2),
    displayMedium:
        TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, height: 1.25),
    headlineLarge:
        TextStyle(fontSize: 28.0, fontWeight: FontWeight.w600, height: 1.3),
    headlineMedium:
        TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600, height: 1.3),
    titleLarge:
        TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, height: 1.35),
    titleMedium:
        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, height: 1.4),
    bodyLarge:
        TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, height: 1.5),
    bodyMedium:
        TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, height: 1.5),
    bodySmall:
        TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, height: 1.5),
    labelLarge:
        TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, height: 1.3),
    labelMedium:
        TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, height: 1.3),
    caption:
        TextStyle(fontSize: 11.0, fontWeight: FontWeight.normal, height: 1.4),
  );

  /// Constructs an [AdaptiveTypography] instance from Flutter's [TextTheme].
  factory AdaptiveTypography.fromTextTheme(TextTheme textTheme) {
    const fallback = AdaptiveTypography.standard;
    return AdaptiveTypography(
      displayLarge: textTheme.displayLarge ?? fallback.displayLarge,
      displayMedium: textTheme.displayMedium ?? fallback.displayMedium,
      headlineLarge: textTheme.headlineLarge ?? fallback.headlineLarge,
      headlineMedium: textTheme.headlineMedium ?? fallback.headlineMedium,
      titleLarge: textTheme.titleLarge ?? fallback.titleLarge,
      titleMedium: textTheme.titleMedium ?? fallback.titleMedium,
      bodyLarge: textTheme.bodyLarge ?? fallback.bodyLarge,
      bodyMedium: textTheme.bodyMedium ?? fallback.bodyMedium,
      bodySmall: textTheme.bodySmall ?? fallback.bodySmall,
      labelLarge: textTheme.labelLarge ?? fallback.labelLarge,
      labelMedium: textTheme.labelMedium ?? fallback.labelMedium,
      caption: textTheme.labelSmall ?? textTheme.bodySmall ?? fallback.caption,
    );
  }

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle caption;

  AdaptiveTypography copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? caption,
  }) {
    return AdaptiveTypography(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      caption: caption ?? this.caption,
    );
  }

  /// Linearly interpolates between two [AdaptiveTypography] scales.
  static AdaptiveTypography lerp(
      AdaptiveTypography a, AdaptiveTypography b, double t) {
    return AdaptiveTypography(
      displayLarge:
          TextStyle.lerp(a.displayLarge, b.displayLarge, t) ?? a.displayLarge,
      displayMedium: TextStyle.lerp(a.displayMedium, b.displayMedium, t) ??
          a.displayMedium,
      headlineLarge: TextStyle.lerp(a.headlineLarge, b.headlineLarge, t) ??
          a.headlineLarge,
      headlineMedium: TextStyle.lerp(a.headlineMedium, b.headlineMedium, t) ??
          a.headlineMedium,
      titleLarge: TextStyle.lerp(a.titleLarge, b.titleLarge, t) ?? a.titleLarge,
      titleMedium:
          TextStyle.lerp(a.titleMedium, b.titleMedium, t) ?? a.titleMedium,
      bodyLarge: TextStyle.lerp(a.bodyLarge, b.bodyLarge, t) ?? a.bodyLarge,
      bodyMedium: TextStyle.lerp(a.bodyMedium, b.bodyMedium, t) ?? a.bodyMedium,
      bodySmall: TextStyle.lerp(a.bodySmall, b.bodySmall, t) ?? a.bodySmall,
      labelLarge: TextStyle.lerp(a.labelLarge, b.labelLarge, t) ?? a.labelLarge,
      labelMedium:
          TextStyle.lerp(a.labelMedium, b.labelMedium, t) ?? a.labelMedium,
      caption: TextStyle.lerp(a.caption, b.caption, t) ?? a.caption,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveTypography &&
          runtimeType == other.runtimeType &&
          displayLarge == other.displayLarge &&
          displayMedium == other.displayMedium &&
          headlineLarge == other.headlineLarge &&
          headlineMedium == other.headlineMedium &&
          titleLarge == other.titleLarge &&
          titleMedium == other.titleMedium &&
          bodyLarge == other.bodyLarge &&
          bodyMedium == other.bodyMedium &&
          bodySmall == other.bodySmall &&
          labelLarge == other.labelLarge &&
          labelMedium == other.labelMedium &&
          caption == other.caption;

  @override
  int get hashCode => Object.hash(
        displayLarge,
        displayMedium,
        headlineLarge,
        headlineMedium,
        titleLarge,
        titleMedium,
        bodyLarge,
        bodyMedium,
        bodySmall,
        labelLarge,
        labelMedium,
        caption,
      );
}
