import 'package:flutter/material.dart';

import '../core/adaptive_scope.dart';
import 'adaptive_motion.dart';
import 'adaptive_theme_data.dart';

/// An inherited widget that provides [AdaptiveThemeData] down the widget tree.
class AdaptiveTheme extends InheritedWidget {
  const AdaptiveTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The theme data provided to descendants.
  final AdaptiveThemeData data;

  /// Retrieves the nearest [AdaptiveThemeData] from [context].
  ///
  /// Searches the widget hierarchy in the following precedence order:
  /// 1. An explicit [AdaptiveTheme] ancestor.
  /// 2. An ambient [AdaptiveScope.theme].
  /// 3. Automatically resolves from ambient Flutter [Theme.of(context)].
  /// 4. Fallback default: [AdaptiveThemeData.light()].
  static AdaptiveThemeData of(BuildContext context) {
    final AdaptiveTheme? inherited =
        context.dependOnInheritedWidgetOfExactType<AdaptiveTheme>();
    if (inherited != null) return inherited.data;

    final AdaptiveScope? scope = AdaptiveScope.maybeOf(context);
    if (scope != null) return scope.theme;

    final bool hasFlutterTheme =
        context.findAncestorWidgetOfExactType<Theme>() != null;
    if (hasFlutterTheme) {
      return AdaptiveThemeData.fromTheme(Theme.of(context));
    }

    return AdaptiveThemeData.light();
  }

  /// Retrieves the nearest [AdaptiveThemeData] from [context], or null if neither
  /// [AdaptiveTheme], [AdaptiveScope], nor Flutter [Theme] exists.
  static AdaptiveThemeData? maybeOf(BuildContext context) {
    final AdaptiveTheme? inherited =
        context.dependOnInheritedWidgetOfExactType<AdaptiveTheme>();
    if (inherited != null) return inherited.data;

    final AdaptiveScope? scope = AdaptiveScope.maybeOf(context);
    if (scope != null) return scope.theme;

    final bool hasFlutterTheme =
        context.findAncestorWidgetOfExactType<Theme>() != null;
    if (hasFlutterTheme) {
      return AdaptiveThemeData.fromTheme(Theme.of(context));
    }

    return null;
  }

  @override
  bool updateShouldNotify(AdaptiveTheme oldWidget) => data != oldWidget.data;
}

/// An implicitly animated widget that smoothly transitions [AdaptiveThemeData] when it changes.
///
/// Respects accessibility reduced-motion settings via [AdaptiveMotion.isReducedMotion].
class AnimatedAdaptiveTheme extends ImplicitlyAnimatedWidget {
  const AnimatedAdaptiveTheme({
    super.key,
    required this.data,
    super.duration = const Duration(milliseconds: 250),
    super.curve = Curves.easeInOut,
    super.onEnd,
    required this.child,
  });

  /// The target [AdaptiveThemeData] to animate towards.
  final AdaptiveThemeData data;

  /// The child widget tree receiving the animated theme.
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedAdaptiveTheme> createState() =>
      _AnimatedAdaptiveThemeState();
}

class _AnimatedAdaptiveThemeState
    extends AnimatedWidgetBaseState<AnimatedAdaptiveTheme> {
  _AdaptiveThemeDataTween? _dataTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _dataTween = visitor(
      _dataTween,
      widget.data,
      (dynamic value) =>
          _AdaptiveThemeDataTween(begin: value as AdaptiveThemeData),
    ) as _AdaptiveThemeDataTween?;
  }

  @override
  Widget build(BuildContext context) {
    final bool reducedMotion = AdaptiveMotion.isReducedMotion(context);
    final AdaptiveThemeData effectiveData = reducedMotion
        ? widget.data
        : (_dataTween?.evaluate(animation) ?? widget.data);

    return AdaptiveTheme(
      data: effectiveData,
      child: widget.child,
    );
  }
}

class _AdaptiveThemeDataTween extends Tween<AdaptiveThemeData> {
  _AdaptiveThemeDataTween({super.begin});

  @override
  AdaptiveThemeData lerp(double t) {
    if (begin == null && end == null) return const AdaptiveThemeData();
    if (begin == null) return end!;
    if (end == null) return begin!;
    return AdaptiveThemeData.lerp(begin!, end!, t);
  }
}
