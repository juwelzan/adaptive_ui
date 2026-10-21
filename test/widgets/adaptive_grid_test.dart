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

    testWidgets('enforces maxItemWidth by increasing columns on wide screens',
        (tester) async {
      // With width 1000 and minItemWidth 200, default columns would be 4:
      // (1000 - 3*16) / 4 = 952 / 4 = 238
      // If maxItemWidth is 220, 238 > 220 so it forces 5 columns:
      // (1000 - 4*16) / 5 = 936 / 5 = 187.2 <= 220
      await tester.pumpAdaptive(
        size: const Size(1000.0, 800.0),
        child: AdaptiveGrid(
          minItemWidth: 250.0,
          maxItemWidth: 220.0,
          spacing: 16.0,
          children: List.generate(6, (index) => Text('Item $index')),
        ),
      );

      final GridView grid = tester.widget(find.byType(GridView));
      final SliverGridDelegateWithFixedCrossAxisCount delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(5));
    });

    testWidgets('constrains to maxContentWidth and centers on wide screens',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1600.0, 900.0),
        child: AdaptiveGrid(
          minItemWidth: 200.0,
          maxContentWidth: 1000.0,
          children: List.generate(4, (index) => Text('Item $index')),
        ),
      );

      expect(find.byType(ConstrainedBox), findsWidgets);
      final ConstrainedBox constrainedBox =
          tester.widget(find.byType(ConstrainedBox).last);
      expect(constrainedBox.constraints.maxWidth, equals(1000.0));
    });

    testWidgets('applies mainAxisExtent when specified', (tester) async {
      await tester.pumpAdaptive(
        size: const Size(800.0, 600.0),
        child: AdaptiveGrid(
          minItemWidth: 200.0,
          mainAxisExtent: 140.0,
          children: List.generate(4, (index) => Text('Item $index')),
        ),
      );

      final GridView grid = tester.widget(find.byType(GridView));
      final SliverGridDelegateWithFixedCrossAxisCount delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.mainAxisExtent, equals(140.0));
    });

    testWidgets(
        'dynamically adjusts effective childAspectRatio when itemWidth < minItemWidth',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(120.0, 400.0),
        child: AdaptiveGrid(
          minItemWidth: 240.0,
          childAspectRatio: 1.4,
          children: const [
            AdaptiveCard(
              child: Text('Card Content'),
            ),
          ],
        ),
      );

      final GridView grid = tester.widget(find.byType(GridView));
      final SliverGridDelegateWithFixedCrossAxisCount delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      // Because 120 < 240, childAspectRatio must be scaled down below 1.4 to provide more vertical space
      expect(delegate.childAspectRatio, lessThan(1.4));
      expect(find.text('Card Content'), findsOneWidget);
    });
  });
}
