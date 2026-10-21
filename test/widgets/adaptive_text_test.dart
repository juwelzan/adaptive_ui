import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveText', () {
    testWidgets(
        'renders text with proportional scaling within min and max bounds',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(390.0, 844.0),
        child: const AdaptiveText(
          'Adaptive Heading',
          baseFontSize: 18.0,
          minFontSize: 14.0,
          maxFontSize: 24.0,
        ),
      );

      final Text textWidget = tester.widget(find.byType(Text));
      expect(textWidget.data, equals('Adaptive Heading'));
      expect(textWidget.style?.fontSize, greaterThanOrEqualTo(14.0));
      expect(textWidget.style?.fontSize, lessThanOrEqualTo(24.0));
    });

    testWidgets('honors system TextScaler while clamping to maxFontSize',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(390.0, 844.0),
        textScaler: const TextScaler.linear(2.0),
        child: const AdaptiveText(
          'Accessible Heading',
          baseFontSize: 16.0,
          minFontSize: 12.0,
          maxFontSize: 24.0,
        ),
      );

      final Text textWidget = tester.widget(find.byType(Text));
      // 16 * 2.0 = 32, but clamped to maxFontSize 24.0
      expect(textWidget.style?.fontSize, equals(24.0));
    });

    testWidgets(
        'Animated marquee renders and handles rebuilds without ticker errors',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(200.0, 400.0),
        child: const SizedBox(
          width: 80.0,
          child: AdaptiveText(
            'Very long marquee text that definitely overflows eighty pixels container',
            animation: AdaptiveTextAnimation.marquee,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Rebuild with different text to exercise didUpdateWidget and Ticker reuse
      await tester.pumpAdaptive(
        size: const Size(200.0, 400.0),
        child: const SizedBox(
          width: 80.0,
          child: AdaptiveText(
            'Updated long marquee text that also overflows eighty pixels container',
            animation: AdaptiveTextAnimation.marquee,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Animated text handles type transitions without ticker provider assertion',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(400.0, 400.0),
        child: const AdaptiveText(
          'Fading in',
          animation: AdaptiveTextAnimation.fadeIn,
        ),
      );
      await tester.pump(const Duration(milliseconds: 150));

      // Update to typewriter animation
      await tester.pumpAdaptive(
        size: const Size(400.0, 400.0),
        child: const AdaptiveText(
          'Typing out',
          animation: AdaptiveTextAnimation.typewriter,
        ),
      );
      await tester.pump(const Duration(milliseconds: 150));

      expect(tester.takeException(), isNull);
    });
  });
}
