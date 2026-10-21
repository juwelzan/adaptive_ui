import 'package:flutter/widgets.dart';

import '../theme/adaptive_theme_data.dart';
import 'adaptive_config.dart';
import 'adaptive_layout_data.dart';

/// An inherited scope propagating [AdaptiveConfig], [AdaptiveThemeData], and ambient [AdaptiveLayoutData].
class AdaptiveScope extends InheritedWidget {
  const AdaptiveScope({
    super.key,
    required this.config,
    required this.theme,
    this.layout,
    required super.child,
  });

  /// Global adaptive configuration parameters.
  final AdaptiveConfig config;

  /// Global adaptive design tokens and theme.
  final AdaptiveThemeData theme;

  /// Ambient layout data snapshot if evaluated higher in the tree.
  final AdaptiveLayoutData? layout;

  /// Obtains the nearest [AdaptiveScope] from [context].
  static AdaptiveScope of(BuildContext context) {
    final AdaptiveScope? scope =
        context.dependOnInheritedWidgetOfExactType<AdaptiveScope>();
    assert(
      scope != null,
      'No AdaptiveScope found in context. Ensure your app is wrapped with AdaptiveApp or AdaptiveScope.',
    );
    return scope!;
  }

  /// Obtains the nearest [AdaptiveScope] or returns null if none exists.
  static AdaptiveScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdaptiveScope>();
  }

  /// Retrieves the nearest [AdaptiveConfig], falling back to [AdaptiveConfig.fallback].
  static AdaptiveConfig configOf(BuildContext context) {
    return maybeOf(context)?.config ?? AdaptiveConfig.fallback;
  }

  /// Retrieves the nearest [AdaptiveThemeData], falling back to [AdaptiveThemeData.light].
  static AdaptiveThemeData themeOf(BuildContext context) {
    return maybeOf(context)?.theme ?? AdaptiveThemeData.light();
  }

  /// Retrieves the nearest ambient [AdaptiveLayoutData] if available.
  static AdaptiveLayoutData? layoutOf(BuildContext context) {
    return maybeOf(context)?.layout;
  }

  @override
  bool updateShouldNotify(AdaptiveScope oldWidget) {
    return config != oldWidget.config ||
        theme != oldWidget.theme ||
        layout != oldWidget.layout;
  }
}
