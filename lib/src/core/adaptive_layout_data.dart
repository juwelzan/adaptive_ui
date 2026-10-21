import 'package:flutter/widgets.dart';

import 'adaptive_breakpoints.dart';

/// An immutable snapshot of parent constraints, viewport environment, and responsive state.
@immutable
class AdaptiveLayoutData {
  /// Creates an immutable adaptive layout data snapshot.
  const AdaptiveLayoutData({
    required this.constraints,
    required this.screenSize,
    required this.containerBreakpoint,
    required this.windowBreakpoint,
    required this.orientation,
    required this.textScaler,
    this.viewInsets = EdgeInsets.zero,
    this.viewPadding = EdgeInsets.zero,
    this.devicePixelRatio = 1.0,
  });

  /// Creates a fallback layout snapshot for unit testing or non-contextual measurements.
  factory AdaptiveLayoutData.fallback({
    BoxConstraints constraints =
        const BoxConstraints(maxWidth: 390.0, maxHeight: 844.0),
    Size screenSize = const Size(390.0, 844.0),
    AdaptiveBreakpoints breakpoints = AdaptiveBreakpoints.standard,
  }) {
    final double width =
        constraints.hasBoundedWidth ? constraints.maxWidth : screenSize.width;
    final Breakpoint containerBp = breakpoints.resolve(width);
    final Breakpoint windowBp = breakpoints.resolve(screenSize.width);
    return AdaptiveLayoutData(
      constraints: constraints,
      screenSize: screenSize,
      containerBreakpoint: containerBp,
      windowBreakpoint: windowBp,
      orientation: screenSize.width >= screenSize.height
          ? Orientation.landscape
          : Orientation.portrait,
      textScaler: TextScaler.noScaling,
      viewInsets: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      devicePixelRatio: 1.0,
    );
  }

  /// Parent constraints passed by [LayoutBuilder].
  /// This is the primary driver for component-level layout decisions.
  final BoxConstraints constraints;

  /// Full screen physical/window dimensions reported by [MediaQuery].
  final Size screenSize;

  /// Responsive breakpoint evaluated against the parent component's available width.
  final Breakpoint containerBreakpoint;

  /// Responsive breakpoint evaluated against the full window/screen width.
  final Breakpoint windowBreakpoint;

  /// Screen or container orientation.
  final Orientation orientation;

  /// Accessibility text scaling system settings.
  final TextScaler textScaler;

  /// System view insets, such as the on-screen software keyboard.
  final EdgeInsets viewInsets;

  /// System view padding, such as status bars, notches, and home indicator safe areas.
  final EdgeInsets viewPadding;

  /// Screen pixel density ratio.
  final double devicePixelRatio;

  /// Width available within parent constraints.
  /// Falls back to [screenSize.width] if parent width is unbounded.
  double get availableWidth =>
      constraints.hasBoundedWidth ? constraints.maxWidth : screenSize.width;

  /// Height available within parent constraints.
  /// Falls back to [screenSize.height] if parent height is unbounded.
  double get availableHeight =>
      constraints.hasBoundedHeight ? constraints.maxHeight : screenSize.height;

  /// True if parent container width falls in [Breakpoint.compact].
  bool get isCompact => containerBreakpoint == Breakpoint.compact;

  /// True if parent container width falls in [Breakpoint.medium].
  bool get isMedium => containerBreakpoint == Breakpoint.medium;

  /// True if parent container width falls in [Breakpoint.expanded].
  bool get isExpanded => containerBreakpoint == Breakpoint.expanded;

  /// True if parent container width falls in [Breakpoint.large].
  /// True if parent container width falls in [Breakpoint.large].
  bool get isLarge => containerBreakpoint == Breakpoint.large;

  /// True if parent container width falls in [Breakpoint.extraLarge].
  bool get isExtraLarge => containerBreakpoint == Breakpoint.extraLarge;

  /// Semantic alias indicating a mobile/compact container environment ([Breakpoint.compact]).
  bool get isMobile => isCompact;

  /// Semantic alias indicating a tablet environment ([Breakpoint.medium] or [Breakpoint.expanded]).
  bool get isTablet => isMedium || isExpanded;

  /// Semantic alias indicating a desktop/large-screen environment ([Breakpoint.large] or [Breakpoint.extraLarge]).
  bool get isDesktop => isLarge || isExtraLarge;

  /// Resolves a value by invoking the callback matching [containerBreakpoint].
  ///
  /// Falls back to smaller breakpoint handlers if an exact match is omitted:
  /// - [extraLarge] falls back to [large] -> [expanded] -> [medium] -> [compact]
  /// - [large] falls back to [expanded] -> [medium] -> [compact]
  /// - [expanded] falls back to [medium] -> [compact]
  /// - [medium] falls back to [compact]
  T when<T>({
    required T Function() compact,
    T Function()? medium,
    T Function()? expanded,
    T Function()? large,
    T Function()? extraLarge,
  }) {
    return containerBreakpoint.when<T>(
      compact: compact,
      medium: medium,
      expanded: expanded,
      large: large,
      extraLarge: extraLarge,
    );
  }

  /// Resolves a constant or evaluated value matching [containerBreakpoint].
  ///
  /// Falls back to smaller breakpoint values if an exact match is omitted.
  T value<T>({
    required T compact,
    T? medium,
    T? expanded,
    T? large,
    T? extraLarge,
  }) {
    return containerBreakpoint.value<T>(
      compact: compact,
      medium: medium,
      expanded: expanded,
      large: large,
      extraLarge: extraLarge,
    );
  }

  /// True if container width is at least [breakpoint].
  bool isAtLeast(Breakpoint breakpoint) =>
      containerBreakpoint.isAtLeast(breakpoint);

  /// True if container width is at most [breakpoint].
  bool isAtMost(Breakpoint breakpoint) =>
      containerBreakpoint.isAtMost(breakpoint);

  /// True if the on-screen software keyboard is currently visible.
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// True if orientation is landscape.
  bool get isLandscape => orientation == Orientation.landscape;

  /// True if orientation is portrait.
  bool get isPortrait => orientation == Orientation.portrait;

  /// Copies this snapshot with optional overrides.
  AdaptiveLayoutData copyWith({
    BoxConstraints? constraints,
    Size? screenSize,
    Breakpoint? containerBreakpoint,
    Breakpoint? windowBreakpoint,
    Orientation? orientation,
    TextScaler? textScaler,
    EdgeInsets? viewInsets,
    EdgeInsets? viewPadding,
    double? devicePixelRatio,
  }) {
    return AdaptiveLayoutData(
      constraints: constraints ?? this.constraints,
      screenSize: screenSize ?? this.screenSize,
      containerBreakpoint: containerBreakpoint ?? this.containerBreakpoint,
      windowBreakpoint: windowBreakpoint ?? this.windowBreakpoint,
      orientation: orientation ?? this.orientation,
      textScaler: textScaler ?? this.textScaler,
      viewInsets: viewInsets ?? this.viewInsets,
      viewPadding: viewPadding ?? this.viewPadding,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveLayoutData &&
          runtimeType == other.runtimeType &&
          constraints == other.constraints &&
          screenSize == other.screenSize &&
          containerBreakpoint == other.containerBreakpoint &&
          windowBreakpoint == other.windowBreakpoint &&
          orientation == other.orientation &&
          textScaler == other.textScaler &&
          viewInsets == other.viewInsets &&
          viewPadding == other.viewPadding &&
          devicePixelRatio == other.devicePixelRatio;

  @override
  int get hashCode => Object.hash(
        constraints,
        screenSize,
        containerBreakpoint,
        windowBreakpoint,
        orientation,
        textScaler,
        viewInsets,
        viewPadding,
        devicePixelRatio,
      );

  @override
  String toString() =>
      'AdaptiveLayoutData(container: $containerBreakpoint, window: $windowBreakpoint, width: $availableWidth, height: $availableHeight)';
}
