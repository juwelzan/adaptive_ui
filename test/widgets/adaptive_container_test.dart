import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveContainer', () {
    testWidgets('resolves automatic padding according to container breakpoint',
        (tester) async {
      const widget = AdaptiveContainer(
        padding: AdaptiveInsets.auto(),
        child: Text('Content'),
      );

      // Compact width (360 dp) -> 16 dp padding
      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        child: widget,
      );
      Padding padding = tester.widget(find.byType(Padding).first);
      expect(padding.padding, equals(const EdgeInsets.all(16.0)));

      // Medium width (700 dp) -> 24 dp padding
      await tester.pumpAdaptive(
        size: const Size(700.0, 800.0),
        child: widget,
      );
      padding = tester.widget(find.byType(Padding).first);
      expect(padding.padding, equals(const EdgeInsets.all(24.0)));
    });

    testWidgets('clamps to maxWidth when specified', (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: const AdaptiveContainer(
          maxWidth: 600.0,
          child: Text('Bounded'),
        ),
      );

      final ConstrainedBox box =
          tester.widget(find.byType(ConstrainedBox).first);
      expect(box.constraints.maxWidth, equals(600.0));
    });
  });
}
