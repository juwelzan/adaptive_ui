import 'package:flutter/widgets.dart';

import '../core/adaptive_scope.dart';
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

  /// Retrieves the nearest [AdaptiveThemeData] from [context], falling back to [AdaptiveScope.themeOf].
  static AdaptiveThemeData of(BuildContext context) {
    final AdaptiveTheme? inherited =
        context.dependOnInheritedWidgetOfExactType<AdaptiveTheme>();
    return inherited?.data ?? AdaptiveScope.themeOf(context);
  }

  /// Retrieves the nearest [AdaptiveThemeData] from [context], or null if none exists.
  static AdaptiveThemeData? maybeOf(BuildContext context) {
    final AdaptiveTheme? inherited =
        context.dependOnInheritedWidgetOfExactType<AdaptiveTheme>();
    return inherited?.data ?? AdaptiveScope.maybeOf(context)?.theme;
  }

  @override
  bool updateShouldNotify(AdaptiveTheme oldWidget) => data != oldWidget.data;
}
