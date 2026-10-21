import 'package:flutter/widgets.dart';

/// Semantic color tokens for adaptive surface and control theming.
@immutable
class AdaptiveColors {
  const AdaptiveColors({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.background,
    required this.onBackground,
    required this.error,
    required this.onError,
    required this.outline,
  });

  /// Default light color scheme.
  static const AdaptiveColors light = AdaptiveColors(
    primary: Color(0xFF1E5BB0),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF4C6078),
    onSecondary: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF191C1E),
    surfaceVariant: Color(0xFFE2E7EE),
    onSurfaceVariant: Color(0xFF43474E),
    background: Color(0xFFF8F9FB),
    onBackground: Color(0xFF191C1E),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFF74777F),
  );

  /// Default dark color scheme.
  static const AdaptiveColors dark = AdaptiveColors(
    primary: Color(0xFFA6C8FF),
    onPrimary: Color(0xFF003062),
    secondary: Color(0xFFB4C8E0),
    onSecondary: Color(0xFF1E3246),
    surface: Color(0xFF121316),
    onSurface: Color(0xFFE2E2E6),
    surfaceVariant: Color(0xFF24272C),
    onSurfaceVariant: Color(0xFFC3C7CF),
    background: Color(0xFF0D0E11),
    onBackground: Color(0xFFE2E2E6),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    outline: Color(0xFF8D9199),
  );

  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color background;
  final Color onBackground;
  final Color error;
  final Color onError;
  final Color outline;

  AdaptiveColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? surface,
    Color? onSurface,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? background,
    Color? onBackground,
    Color? error,
    Color? onError,
    Color? outline,
  }) {
    return AdaptiveColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      outline: outline ?? this.outline,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveColors &&
          runtimeType == other.runtimeType &&
          primary == other.primary &&
          onPrimary == other.onPrimary &&
          secondary == other.secondary &&
          onSecondary == other.onSecondary &&
          surface == other.surface &&
          onSurface == other.onSurface &&
          surfaceVariant == other.surfaceVariant &&
          onSurfaceVariant == other.onSurfaceVariant &&
          background == other.background &&
          onBackground == other.onBackground &&
          error == other.error &&
          onError == other.onError &&
          outline == other.outline;

  @override
  int get hashCode => Object.hash(
        primary,
        onPrimary,
        secondary,
        onSecondary,
        surface,
        onSurface,
        surfaceVariant,
        onSurfaceVariant,
        background,
        onBackground,
        error,
        onError,
        outline,
      );
}
