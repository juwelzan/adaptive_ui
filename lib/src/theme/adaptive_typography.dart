import 'package:flutter/widgets.dart';

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
  });

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
  );

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
          labelMedium == other.labelMedium;

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
      );
}
