import 'package:flutter/material.dart';

/// Semantic color tokens for adaptive surface, typography, status, and control theming.
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
    Color? surfaceElevated,
    Color? onSurfaceElevated,
    Color? outlineVariant,
    Color? border,
    Color? divider,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? disabled,
    Color? onDisabled,
    Color? hover,
    Color? focus,
    Color? highlight,
  })  : surfaceElevated = surfaceElevated ?? surfaceVariant,
        onSurfaceElevated = onSurfaceElevated ?? onSurface,
        outlineVariant = outlineVariant ?? outline,
        border = border ?? outline,
        divider = divider ?? outline,
        success = success ?? const Color(0xFF1E7E34),
        onSuccess = onSuccess ?? const Color(0xFFFFFFFF),
        warning = warning ?? const Color(0xFFB57400),
        onWarning = onWarning ?? const Color(0xFFFFFFFF),
        info = info ?? const Color(0xFF0D6EFD),
        onInfo = onInfo ?? const Color(0xFFFFFFFF),
        disabled = disabled ?? surfaceVariant,
        onDisabled = onDisabled ?? onSurfaceVariant,
        hover = hover ?? const Color(0x0A000000),
        focus = focus ?? const Color(0x1F1E5BB0),
        highlight = highlight ?? const Color(0x141E5BB0);

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
    surfaceElevated: Color(0xFFF3F5F9),
    onSurfaceElevated: Color(0xFF191C1E),
    background: Color(0xFFF8F9FB),
    onBackground: Color(0xFF191C1E),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFF74777F),
    outlineVariant: Color(0xFFC4C7CF),
    border: Color(0xFFE2E7EE),
    divider: Color(0xFFE0E2EC),
    success: Color(0xFF1E7E34),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFFB57400),
    onWarning: Color(0xFFFFFFFF),
    info: Color(0xFF0D6EFD),
    onInfo: Color(0xFFFFFFFF),
    disabled: Color(0xFFE0E2EC),
    onDisabled: Color(0xFF8E9199),
    hover: Color(0x0A000000),
    focus: Color(0x1F1E5BB0),
    highlight: Color(0x141E5BB0),
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
    surfaceElevated: Color(0xFF1E2025),
    onSurfaceElevated: Color(0xFFE2E2E6),
    background: Color(0xFF0D0E11),
    onBackground: Color(0xFFE2E2E6),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    outline: Color(0xFF8D9199),
    outlineVariant: Color(0xFF43474E),
    border: Color(0xFF2C2F36),
    divider: Color(0xFF2E3238),
    success: Color(0xFF75DC7A),
    onSuccess: Color(0xFF003911),
    warning: Color(0xFFFFBA38),
    onWarning: Color(0xFF432C00),
    info: Color(0xFF6EA8FE),
    onInfo: Color(0xFF002F6C),
    disabled: Color(0xFF2E3238),
    onDisabled: Color(0xFF6B707B),
    hover: Color(0x0FFFFFFF),
    focus: Color(0x33A6C8FF),
    highlight: Color(0x26A6C8FF),
  );

  /// Creates an [AdaptiveColors] instance mapped from a Flutter Material [ColorScheme].
  factory AdaptiveColors.fromColorScheme(ColorScheme scheme) {
    final bool isDark = scheme.brightness == Brightness.dark;
    return AdaptiveColors(
      primary: scheme.primary,
      onPrimary: scheme.onPrimary,
      secondary: scheme.secondary,
      onSecondary: scheme.onSecondary,
      surface: scheme.surface,
      onSurface: scheme.onSurface,
      surfaceVariant: scheme.surfaceContainerHighest,
      onSurfaceVariant: scheme.onSurfaceVariant,
      surfaceElevated: scheme.surfaceContainerHigh,
      onSurfaceElevated: scheme.onSurface,
      background: scheme.surface,
      onBackground: scheme.onSurface,
      error: scheme.error,
      onError: scheme.onError,
      outline: scheme.outline,
      outlineVariant: scheme.outlineVariant,
      border: scheme.outlineVariant,
      divider: scheme.outlineVariant.withValues(alpha: 0.5),
      success: isDark ? const Color(0xFF75DC7A) : const Color(0xFF1E7E34),
      onSuccess: isDark ? const Color(0xFF003911) : const Color(0xFFFFFFFF),
      warning: isDark ? const Color(0xFFFFBA38) : const Color(0xFFB57400),
      onWarning: isDark ? const Color(0xFF432C00) : const Color(0xFFFFFFFF),
      info: isDark ? const Color(0xFF6EA8FE) : const Color(0xFF0D6EFD),
      onInfo: isDark ? const Color(0xFF002F6C) : const Color(0xFFFFFFFF),
      disabled: isDark ? const Color(0xFF2E3238) : const Color(0xFFE0E2EC),
      onDisabled: isDark ? const Color(0xFF6B707B) : const Color(0xFF8E9199),
      hover: isDark ? const Color(0x0FFFFFFF) : const Color(0x0A000000),
      focus: scheme.primary.withValues(alpha: isDark ? 0.25 : 0.15),
      highlight: scheme.primary.withValues(alpha: isDark ? 0.18 : 0.1),
    );
  }

  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color surfaceElevated;
  final Color onSurfaceElevated;
  final Color background;
  final Color onBackground;
  final Color error;
  final Color onError;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color outline;
  final Color outlineVariant;
  final Color border;
  final Color divider;
  final Color disabled;
  final Color onDisabled;
  final Color hover;
  final Color focus;
  final Color highlight;

  /// Semantic main text color (maps to [onSurface]).
  Color get textPrimary => onSurface;

  /// Semantic secondary/muted text color (maps to [onSurfaceVariant]).
  Color get textSecondary => onSurfaceVariant;

  AdaptiveColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? surface,
    Color? onSurface,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? surfaceElevated,
    Color? onSurfaceElevated,
    Color? background,
    Color? onBackground,
    Color? error,
    Color? onError,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? outline,
    Color? outlineVariant,
    Color? border,
    Color? divider,
    Color? disabled,
    Color? onDisabled,
    Color? hover,
    Color? focus,
    Color? highlight,
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
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      onSurfaceElevated: onSurfaceElevated ?? this.onSurfaceElevated,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      disabled: disabled ?? this.disabled,
      onDisabled: onDisabled ?? this.onDisabled,
      hover: hover ?? this.hover,
      focus: focus ?? this.focus,
      highlight: highlight ?? this.highlight,
    );
  }

  /// Linearly interpolates between two [AdaptiveColors] instances.
  static AdaptiveColors lerp(AdaptiveColors a, AdaptiveColors b, double t) {
    return AdaptiveColors(
      primary: Color.lerp(a.primary, b.primary, t) ?? a.primary,
      onPrimary: Color.lerp(a.onPrimary, b.onPrimary, t) ?? a.onPrimary,
      secondary: Color.lerp(a.secondary, b.secondary, t) ?? a.secondary,
      onSecondary: Color.lerp(a.onSecondary, b.onSecondary, t) ?? a.onSecondary,
      surface: Color.lerp(a.surface, b.surface, t) ?? a.surface,
      onSurface: Color.lerp(a.onSurface, b.onSurface, t) ?? a.onSurface,
      surfaceVariant:
          Color.lerp(a.surfaceVariant, b.surfaceVariant, t) ?? a.surfaceVariant,
      onSurfaceVariant: Color.lerp(a.onSurfaceVariant, b.onSurfaceVariant, t) ??
          a.onSurfaceVariant,
      surfaceElevated: Color.lerp(a.surfaceElevated, b.surfaceElevated, t) ??
          a.surfaceElevated,
      onSurfaceElevated:
          Color.lerp(a.onSurfaceElevated, b.onSurfaceElevated, t) ??
              a.onSurfaceElevated,
      background: Color.lerp(a.background, b.background, t) ?? a.background,
      onBackground:
          Color.lerp(a.onBackground, b.onBackground, t) ?? a.onBackground,
      error: Color.lerp(a.error, b.error, t) ?? a.error,
      onError: Color.lerp(a.onError, b.onError, t) ?? a.onError,
      success: Color.lerp(a.success, b.success, t) ?? a.success,
      onSuccess: Color.lerp(a.onSuccess, b.onSuccess, t) ?? a.onSuccess,
      warning: Color.lerp(a.warning, b.warning, t) ?? a.warning,
      onWarning: Color.lerp(a.onWarning, b.onWarning, t) ?? a.onWarning,
      info: Color.lerp(a.info, b.info, t) ?? a.info,
      onInfo: Color.lerp(a.onInfo, b.onInfo, t) ?? a.onInfo,
      outline: Color.lerp(a.outline, b.outline, t) ?? a.outline,
      outlineVariant:
          Color.lerp(a.outlineVariant, b.outlineVariant, t) ?? a.outlineVariant,
      border: Color.lerp(a.border, b.border, t) ?? a.border,
      divider: Color.lerp(a.divider, b.divider, t) ?? a.divider,
      disabled: Color.lerp(a.disabled, b.disabled, t) ?? a.disabled,
      onDisabled: Color.lerp(a.onDisabled, b.onDisabled, t) ?? a.onDisabled,
      hover: Color.lerp(a.hover, b.hover, t) ?? a.hover,
      focus: Color.lerp(a.focus, b.focus, t) ?? a.focus,
      highlight: Color.lerp(a.highlight, b.highlight, t) ?? a.highlight,
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
          surfaceElevated == other.surfaceElevated &&
          onSurfaceElevated == other.onSurfaceElevated &&
          background == other.background &&
          onBackground == other.onBackground &&
          error == other.error &&
          onError == other.onError &&
          success == other.success &&
          onSuccess == other.onSuccess &&
          warning == other.warning &&
          onWarning == other.onWarning &&
          info == other.info &&
          onInfo == other.onInfo &&
          outline == other.outline &&
          outlineVariant == other.outlineVariant &&
          border == other.border &&
          divider == other.divider &&
          disabled == other.disabled &&
          onDisabled == other.onDisabled &&
          hover == other.hover &&
          focus == other.focus &&
          highlight == other.highlight;

  @override
  int get hashCode => Object.hashAll([
        primary,
        onPrimary,
        secondary,
        onSecondary,
        surface,
        onSurface,
        surfaceVariant,
        onSurfaceVariant,
        surfaceElevated,
        onSurfaceElevated,
        background,
        onBackground,
        error,
        onError,
        success,
        onSuccess,
        warning,
        onWarning,
        info,
        onInfo,
        outline,
        outlineVariant,
        border,
        divider,
        disabled,
        onDisabled,
        hover,
        focus,
        highlight,
      ]);
}
