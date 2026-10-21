import 'package:flutter/widgets.dart';

import '../core/adaptive_config.dart';
import '../core/adaptive_scope.dart';
import '../diagnostics/adaptive_debug_overlay.dart';
import '../theme/adaptive_theme_data.dart';

/// Root application wrapper establishing global responsive configurations, theme tokens, and diagnostics.
class AdaptiveApp extends StatelessWidget {
  const AdaptiveApp({
    super.key,
    this.config = AdaptiveConfig.fallback,
    this.theme,
    this.debugShowAdaptiveOverlay,
    required this.child,
  });

  /// Global adaptive configuration.
  final AdaptiveConfig config;

  /// Global adaptive theme data. Defaults to [AdaptiveThemeData.light].
  final AdaptiveThemeData? theme;

  /// Whether to display the live responsive telemetry overlay.
  /// If null, defaults to [AdaptiveConfig.enableDiagnostics].
  final bool? debugShowAdaptiveOverlay;

  /// The root child widget (typically [MaterialApp] or [WidgetsApp]).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AdaptiveThemeData resolvedTheme = theme ?? AdaptiveThemeData.light();
    final bool showOverlay =
        debugShowAdaptiveOverlay ?? config.enableDiagnostics;

    final Widget appWithScope = AdaptiveScope(
      config: config,
      theme: resolvedTheme,
      child: child,
    );

    if (showOverlay) {
      return AdaptiveDebugOverlay(
        enabled: true,
        child: appWithScope,
      );
    }

    return appWithScope;
  }
}
