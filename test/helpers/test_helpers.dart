import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helper to wrap a widget inside [MaterialApp], [AdaptiveApp], and custom viewport parameters.
Widget wrapWithAdaptive({
  required Widget child,
  Size size = const Size(390.0, 844.0),
  TextScaler textScaler = TextScaler.noScaling,
  EdgeInsets viewInsets = EdgeInsets.zero,
  EdgeInsets viewPadding = EdgeInsets.zero,
  AdaptiveConfig config = AdaptiveConfig.fallback,
  AdaptiveThemeData? theme,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: size,
      textScaler: textScaler,
      viewInsets: viewInsets,
      viewPadding: viewPadding,
    ),
    child: AdaptiveApp(
      config: config,
      theme: theme,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: child,
        ),
      ),
    ),
  );
}

/// Helper extension on [WidgetTester] to pump with specific viewport configurations.
extension AdaptiveTesterExtension on WidgetTester {
  Future<void> pumpAdaptive({
    required Widget child,
    Size size = const Size(390.0, 844.0),
    TextScaler textScaler = TextScaler.noScaling,
    EdgeInsets viewInsets = EdgeInsets.zero,
    EdgeInsets viewPadding = EdgeInsets.zero,
    AdaptiveConfig config = AdaptiveConfig.fallback,
    AdaptiveThemeData? theme,
  }) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1.0;

    await pumpWidget(
      wrapWithAdaptive(
        child: child,
        size: size,
        textScaler: textScaler,
        viewInsets: viewInsets,
        viewPadding: viewPadding,
        config: config,
        theme: theme,
      ),
    );
    await pumpAndSettle();
  }
}
