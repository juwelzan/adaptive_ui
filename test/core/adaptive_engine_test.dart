import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveEngine', () {
    test('calculateColumns dynamically adapts column count to available width',
        () {
      // 320 dp (Phone)
      expect(
        AdaptiveEngine.calculateColumns(320.0,
            minItemWidth: 240.0, spacing: 16.0),
        equals(1),
      );

      // 600 dp: 2 * 240 + 16 = 496 <= 600 -> 2 columns
      expect(
        AdaptiveEngine.calculateColumns(600.0,
            minItemWidth: 240.0, spacing: 16.0),
        equals(2),
      );

      // 1024 dp: 4 * 240 + 3 * 16 = 960 + 48 = 1008 <= 1024 -> 4 columns
      expect(
        AdaptiveEngine.calculateColumns(1024.0,
            minItemWidth: 240.0, spacing: 16.0),
        equals(4),
      );
    });

    test('calculateFontSize respects min/max clamping and TextScaler', () {
      final layout = AdaptiveLayoutData.fallback(
        constraints: const BoxConstraints(maxWidth: 390.0),
      );
      const config = AdaptiveConfig(autoFontScaling: false);

      final size = AdaptiveEngine.calculateFontSize(
        baseFontSize: 16.0,
        layout: layout,
        config: config,
        minFontSize: 12.0,
        maxFontSize: 24.0,
      );
      expect(size, equals(16.0));

      // With 2.0x TextScaler
      final scaledLayout =
          layout.copyWith(textScaler: const TextScaler.linear(2.0));
      final scaledSize = AdaptiveEngine.calculateFontSize(
        baseFontSize: 16.0,
        layout: scaledLayout,
        config: config,
        minFontSize: 12.0,
        maxFontSize: 24.0,
      );
      // 16 * 2.0 = 32, clamped to maxFontSize 24.0
      expect(scaledSize, equals(24.0));
    });

    test('shouldCollapseRow identifies when rows should stack into columns',
        () {
      final compactLayout = AdaptiveLayoutData.fallback(
        constraints: const BoxConstraints(maxWidth: 390.0),
      );
      final expandedLayout = AdaptiveLayoutData.fallback(
        constraints: const BoxConstraints(maxWidth: 900.0),
      );

      expect(
        AdaptiveEngine.shouldCollapseRow(
          compactLayout,
          collapseBelowBreakpoint: Breakpoint.medium,
        ),
        isTrue,
      );

      expect(
        AdaptiveEngine.shouldCollapseRow(
          expandedLayout,
          collapseBelowBreakpoint: Breakpoint.medium,
        ),
        isFalse,
      );

      // With explicit minRowWidth
      expect(
        AdaptiveEngine.shouldCollapseRow(
          expandedLayout,
          minRowWidth: 1000.0,
        ),
        isTrue,
      );
    });
  });
}
