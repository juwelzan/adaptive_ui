import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveAutoSizeText', () {
    testWidgets('scales font size down to fit tight width constraints',
        (tester) async {
      await tester.pumpAdaptive(
        child: SizedBox(
          width: 80.0,
          child: const AdaptiveAutoSizeText(
            '\$1,234,567.89',
            minFontSize: 10.0,
            maxFontSize: 30.0,
          ),
        ),
      );

      final Text textWidget = tester.widget(find.byType(Text));
      expect(textWidget.style?.fontSize, lessThan(30.0));
      expect(textWidget.style?.fontSize, greaterThanOrEqualTo(10.0));
    });

    testWidgets('never drops below minFontSize', (tester) async {
      await tester.pumpAdaptive(
        child: SizedBox(
          width: 20.0,
          child: const AdaptiveAutoSizeText(
            'Very Long Heading Text',
            minFontSize: 12.0,
            maxFontSize: 24.0,
          ),
        ),
      );

      final Text textWidget = tester.widget(find.byType(Text));
      expect(textWidget.style?.fontSize, equals(12.0));
    });
  });
}
