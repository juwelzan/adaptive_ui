import 'package:flutter/widgets.dart';

import 'adaptive_breakpoints.dart';
import 'adaptive_layout_data.dart';

/// A polymorphic value container supporting automatic, fixed, breakpoint-specific, or procedural values.
@immutable
abstract class AdaptiveValue<T> {
  const AdaptiveValue();

  /// Resolves the concrete value for a given [layout] snapshot.
  /// If the value is automatic ([isAuto] is true), [autoResolver] is invoked if provided.
  T resolve(AdaptiveLayoutData layout, [T Function()? autoResolver]);

  /// Creates an automatic value that resolves based on layout context and defaults.
  const factory AdaptiveValue.auto() = _AutoAdaptiveValue<T>;

  /// Creates a constant fixed value regardless of screen size.
  const factory AdaptiveValue.fixed(T value) = _FixedAdaptiveValue<T>;

  /// Creates a value that changes at specific breakpoint tiers.
  const factory AdaptiveValue.breakpoint({
    required T compact,
    T? medium,
    T? expanded,
    T? large,
    T? extraLarge,
    required T fallback,
  }) = _BreakpointAdaptiveValue<T>;

  /// Creates a procedurally calculated value evaluated per layout snapshot.
  const factory AdaptiveValue.builder(
      T Function(AdaptiveLayoutData layout) builder) = _BuilderAdaptiveValue<T>;

  /// True if this value should be resolved automatically.
  bool get isAuto => false;

  /// True if this value is fixed and invariant.
  bool get isFixed => false;
}

class _AutoAdaptiveValue<T> extends AdaptiveValue<T> {
  const _AutoAdaptiveValue();

  @override
  bool get isAuto => true;

  @override
  T resolve(AdaptiveLayoutData layout, [T Function()? autoResolver]) {
    if (autoResolver != null) {
      return autoResolver();
    }
    throw StateError(
        'Cannot resolve AdaptiveValue.auto() without an autoResolver');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _AutoAdaptiveValue<T>;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AdaptiveValue<$T>.auto()';
}

class _FixedAdaptiveValue<T> extends AdaptiveValue<T> {
  const _FixedAdaptiveValue(this.value);

  final T value;

  @override
  bool get isFixed => true;

  @override
  T resolve(AdaptiveLayoutData layout, [T Function()? autoResolver]) => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FixedAdaptiveValue<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'AdaptiveValue<$T>.fixed($value)';
}

class _BreakpointAdaptiveValue<T> extends AdaptiveValue<T> {
  const _BreakpointAdaptiveValue({
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
    required this.fallback,
  });

  final T compact;
  final T? medium;
  final T? expanded;
  final T? large;
  final T? extraLarge;
  final T fallback;

  @override
  T resolve(AdaptiveLayoutData layout, [T Function()? autoResolver]) {
    switch (layout.containerBreakpoint) {
      case Breakpoint.compact:
        return compact;
      case Breakpoint.medium:
        return medium ?? compact;
      case Breakpoint.expanded:
        return expanded ?? medium ?? compact;
      case Breakpoint.large:
        return large ?? expanded ?? medium ?? compact;
      case Breakpoint.extraLarge:
        return extraLarge ?? large ?? expanded ?? medium ?? compact;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BreakpointAdaptiveValue<T> &&
          runtimeType == other.runtimeType &&
          compact == other.compact &&
          medium == other.medium &&
          expanded == other.expanded &&
          large == other.large &&
          extraLarge == other.extraLarge &&
          fallback == other.fallback;

  @override
  int get hashCode =>
      Object.hash(compact, medium, expanded, large, extraLarge, fallback);

  @override
  String toString() =>
      'AdaptiveValue<$T>.breakpoint(compact: $compact, medium: $medium, expanded: $expanded, large: $large)';
}

class _BuilderAdaptiveValue<T> extends AdaptiveValue<T> {
  const _BuilderAdaptiveValue(this.builder);

  final T Function(AdaptiveLayoutData layout) builder;

  @override
  T resolve(AdaptiveLayoutData layout, [T Function()? autoResolver]) =>
      builder(layout);
}

/// Responsive padding and margin representation supporting automatic, fixed, and breakpoint-specific insets.
@immutable
class AdaptiveInsets {
  const AdaptiveInsets._({
    this.value,
    this.isAuto = false,
    this.breakpointInsets,
    this.builder,
  });

  /// Insets calculated automatically based on breakpoint tier:
  /// - compact: 16.0 dp
  /// - medium: 24.0 dp
  /// - expanded: 32.0 dp
  /// - large: 40.0 dp
  /// - extraLarge: 48.0 dp
  const AdaptiveInsets.auto()
      : this._(
          isAuto: true,
        );

  /// Insets from an explicit [EdgeInsets] instance.
  const AdaptiveInsets.fromEdgeInsets(EdgeInsets insets)
      : this._(
          value: insets,
        );

  /// Fixed uniform insets applied to all four sides.
  AdaptiveInsets.all(double value)
      : this._(
          value: EdgeInsets.all(value),
        );

  /// Fixed symmetric horizontal and vertical insets.
  AdaptiveInsets.symmetric({double horizontal = 0.0, double vertical = 0.0})
      : this._(
          value:
              EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        );

  /// Fixed insets for specific edges.
  AdaptiveInsets.only({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) : this._(
          value: EdgeInsets.only(
              left: left, top: top, right: right, bottom: bottom),
        );

  /// Fixed insets from left, top, right, and bottom.
  AdaptiveInsets.fromLTRB(double left, double top, double right, double bottom)
      : this._(
          value: EdgeInsets.fromLTRB(left, top, right, bottom),
        );

  /// Insets that vary by responsive breakpoint.
  AdaptiveInsets.breakpoint({
    required EdgeInsets compact,
    EdgeInsets? medium,
    EdgeInsets? expanded,
    EdgeInsets? large,
    EdgeInsets? extraLarge,
    required EdgeInsets fallback,
  }) : this._(
          breakpointInsets: _BreakpointAdaptiveValue<EdgeInsets>(
            compact: compact,
            medium: medium,
            expanded: expanded,
            large: large,
            extraLarge: extraLarge,
            fallback: fallback,
          ),
        );

  /// Procedural insets resolved from an [AdaptiveLayoutData] builder.
  const AdaptiveInsets.builder(
      EdgeInsets Function(AdaptiveLayoutData layout) builder)
      : this._(
          builder: builder,
        );

  /// Zero insets.
  static const AdaptiveInsets zero =
      AdaptiveInsets.fromEdgeInsets(EdgeInsets.zero);

  final EdgeInsets? value;
  final bool isAuto;
  final AdaptiveValue<EdgeInsets>? breakpointInsets;
  final EdgeInsets Function(AdaptiveLayoutData layout)? builder;

  /// Resolves the concrete [EdgeInsets] for a given [layout].
  EdgeInsets resolve(AdaptiveLayoutData layout) {
    if (isAuto) {
      switch (layout.containerBreakpoint) {
        case Breakpoint.compact:
          return const EdgeInsets.all(16.0);
        case Breakpoint.medium:
          return const EdgeInsets.all(24.0);
        case Breakpoint.expanded:
          return const EdgeInsets.all(32.0);
        case Breakpoint.large:
          return const EdgeInsets.all(40.0);
        case Breakpoint.extraLarge:
          return const EdgeInsets.all(48.0);
      }
    }
    if (value != null) {
      return value!;
    }
    if (breakpointInsets != null) {
      return breakpointInsets!.resolve(layout);
    }
    if (builder != null) {
      return builder!(layout);
    }
    return EdgeInsets.zero;
  }
}
