import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveGrid', () {
    testWidgets('adapts crossAxisCount to available container width',
        (tester) async {
      final widget = AdaptiveGrid(
        minItemWidth: 240.0,
        spacing: 16.0,
        children: List.generate(4, (index) => Text('Item $index')),
      );

      // On 320dp width, only 1 column fits
      await tester.pumpAdaptive(
        size: const Size(320.0, 568.0),
        child: widget,
      );
      GridView grid = tester.widget(find.byType(GridView));
      SliverGridDelegateWithFixedCrossAxisCount delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(1));

      // On 600dp width, 2 columns fit
      await tester.pumpAdaptive(
        size: const Size(600.0, 800.0),
        child: widget,
      );
      grid = tester.widget(find.byType(GridView));
      delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(2));
    });

    testWidgets('AdaptiveGrid.builder lazily builds items', (tester) async {
      await tester.pumpAdaptive(
        size: const Size(800.0, 600.0),
        child: AdaptiveGrid.builder(
          minItemWidth: 200.0,
          itemCount: 10,
          itemBuilder: (context, index) => Text('Cell $index'),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Cell 0'), findsOneWidget);
    });
  });
}
