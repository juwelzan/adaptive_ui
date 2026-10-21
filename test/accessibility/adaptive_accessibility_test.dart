import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Adaptive Accessibility & Ergonomics', () {
    testWidgets(
        'AdaptiveText scales gracefully under 2.0x accessibility TextScaler without throwing',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        textScaler: const TextScaler.linear(2.0),
        child: const AdaptiveText(
          'Accessible Heading',
          minFontSize: 14.0,
          maxFontSize: 28.0,
          maxLines: 2,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets(
        'AdaptiveTextContainer clamps wide reading lines to readableTextMaxWidth',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1920.0, 1080.0),
        child: const AdaptiveTextContainer(
          maxWidth: 720.0,
          child: Text('Long form article text on desktop monitor'),
        ),
      );

      final ConstrainedBox box =
          tester.widget(find.byType(ConstrainedBox).first);
      expect(box.constraints.maxWidth, equals(720.0));
    });
  });
}
