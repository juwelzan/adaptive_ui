import 'package:flutter/widgets.dart';

import '../core/adaptive_breakpoints.dart';
import '../core/adaptive_config.dart';
import '../core/adaptive_context.dart';
import '../core/adaptive_layout_data.dart';
import '../core/adaptive_scope.dart';
import '../theme/adaptive_theme_data.dart';

/// Extension methods on [BuildContext] providing streamlined access to adaptive layout data and tokens.
extension AdaptiveContextExtensions on BuildContext {
  /// Obtains current ambient [AdaptiveLayoutData] snapshot.
  AdaptiveLayoutData get adaptiveLayout => AdaptiveContext.of(this);

  /// Current container breakpoint tier.
  Breakpoint get breakpoint => adaptiveLayout.containerBreakpoint;

  /// True if current container is [Breakpoint.compact].
  bool get isCompact => adaptiveLayout.isCompact;

  /// True if current container is [Breakpoint.medium].
  bool get isMedium => adaptiveLayout.isMedium;

  /// True if current container is [Breakpoint.expanded].
  bool get isExpanded => adaptiveLayout.isExpanded;

  /// True if current container is [Breakpoint.large].
  bool get isLarge => adaptiveLayout.isLarge;

  /// True if current container is [Breakpoint.extraLarge].
  bool get isExtraLarge => adaptiveLayout.isExtraLarge;

  /// Width available within parent constraints.
  double get availableWidth => adaptiveLayout.availableWidth;

  /// Height available within parent constraints.
  double get availableHeight => adaptiveLayout.availableHeight;

  /// Current [AdaptiveThemeData] design tokens.
  AdaptiveThemeData get adaptiveTheme => AdaptiveScope.themeOf(this);

  /// Current [AdaptiveConfig] global settings.
  AdaptiveConfig get adaptiveConfig => AdaptiveScope.configOf(this);

  /// Current system view insets (e.g. keyboard).
  EdgeInsets get viewInsets => adaptiveLayout.viewInsets;

  /// Whether the on-screen software keyboard is currently visible.
  bool get isKeyboardVisible => adaptiveLayout.isKeyboardVisible;
}
