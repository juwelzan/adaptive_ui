import 'package:flutter/widgets.dart';

import 'adaptive_breakpoints.dart';
import 'adaptive_config.dart';
import 'adaptive_layout_data.dart';
import 'adaptive_scope.dart';

/// Contextual resolution utilities for generating and querying [AdaptiveLayoutData].
class AdaptiveContext {
  const AdaptiveContext._();

  /// Resolves an [AdaptiveLayoutData] snapshot combining parent [constraints] with environment [MediaQueryData].
  static AdaptiveLayoutData resolve(
      BuildContext context, BoxConstraints constraints) {
    final MediaQueryData media = MediaQuery.maybeOf(context) ??
        MediaQueryData.fromView(View.of(context));
    final AdaptiveConfig config = AdaptiveScope.configOf(context);
    final AdaptiveBreakpoints breakpoints = config.breakpoints;

    final double effectiveWidth =
        constraints.hasBoundedWidth ? constraints.maxWidth : media.size.width;

    final Breakpoint containerBp = breakpoints.resolve(effectiveWidth);
    final Breakpoint windowBp = breakpoints.resolve(media.size.width);

    return AdaptiveLayoutData(
      constraints: constraints,
      screenSize: media.size,
      containerBreakpoint: containerBp,
      windowBreakpoint: windowBp,
      orientation: media.orientation,
      textScaler: media.textScaler,
      viewInsets: media.viewInsets,
      viewPadding: media.viewPadding,
      devicePixelRatio: media.devicePixelRatio,
    );
  }

  /// Safely queries ambient [AdaptiveLayoutData] if available in [context].
  static AdaptiveLayoutData? maybeOf(BuildContext context) {
    return AdaptiveScope.layoutOf(context);
  }

  /// Extracts ambient layout data or resolves fallback data from [context].
  static AdaptiveLayoutData of(BuildContext context) {
    final AdaptiveLayoutData? ambient = AdaptiveScope.layoutOf(context);
    if (ambient != null) return ambient;

    final MediaQueryData? media = MediaQuery.maybeOf(context);
    if (media != null) {
      final AdaptiveConfig config = AdaptiveScope.configOf(context);
      final Breakpoint bp = config.breakpoints.resolve(media.size.width);
      return AdaptiveLayoutData(
        constraints: BoxConstraints.loose(media.size),
        screenSize: media.size,
        containerBreakpoint: bp,
        windowBreakpoint: bp,
        orientation: media.orientation,
        textScaler: media.textScaler,
        viewInsets: media.viewInsets,
        viewPadding: media.viewPadding,
        devicePixelRatio: media.devicePixelRatio,
      );
    }

    return AdaptiveLayoutData.fallback();
  }
}
