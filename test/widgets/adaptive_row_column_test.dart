import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveRow & AdaptiveColumn', () {
    testWidgets(
        'AdaptiveRow collapses to Column on compact viewport when autoCollapse is true',
        (tester) async {
      const widget = AdaptiveRow(
        autoCollapse: true,
        collapseBelowBreakpoint: Breakpoint.medium,
        children: [
          Text('First Item'),
          Text('Second Item'),
        ],
      );

      // Compact viewport (< 600 dp)
      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        child: widget,
      );
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsNothing);

      // Wide viewport (1024 dp)
      await tester.pumpAdaptive(
        size: const Size(1024.0, 768.0),
        child: widget,
      );
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsNothing);
    });

    testWidgets('AdaptiveRow and AdaptiveColumn insert spacing correctly',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1024.0, 768.0),
        child: const AdaptiveRow(
          spacing: AdaptiveValue.fixed(16.0),
          children: [
            Text('A'),
            Text('B'),
          ],
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
