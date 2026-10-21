import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveFlex', () {
    testWidgets(
        'rowOrColumn renders as Row on wider viewports and Column on compact viewports',
        (WidgetTester tester) async {
      final flexWidget = AdaptiveFlex(
        arrangement: AdaptiveFlexArrangement.rowOrColumn,
        collapseBreakpoint: Breakpoint.medium,
        children: const [
          Text('First'),
          Text('Second'),
        ],
      );

      // On wide screen (800dp), renders as Row
      await tester.pumpAdaptive(
        size: const Size(800, 600),
        child: flexWidget,
      );
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsNothing);

      // On compact screen (400dp), collapses into Column
      await tester.pumpAdaptive(
        size: const Size(400, 600),
        child: flexWidget,
      );
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('respects explicit minRowWidth threshold',
        (WidgetTester tester) async {
      final flexWidget = AdaptiveFlex(
        arrangement: AdaptiveFlexArrangement.rowOrColumn,
        minRowWidth: 500.0,
        children: const [
          Text('First'),
          Text('Second'),
        ],
      );

      // 550dp > 500dp minRowWidth -> Row
      await tester.pumpAdaptive(
        size: const Size(550, 600),
        child: flexWidget,
      );
      expect(find.byType(Row), findsOneWidget);

      // 450dp < 500dp minRowWidth -> Column
      await tester.pumpAdaptive(
        size: const Size(450, 600),
        child: flexWidget,
      );
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('arrangement wrap renders a Wrap widget',
        (WidgetTester tester) async {
      await tester.pumpAdaptive(
        size: const Size(600, 600),
        child: const AdaptiveFlex(
          arrangement: AdaptiveFlexArrangement.wrap,
          spacing: 12.0,
          children: [
            Text('Tag 1'),
            Text('Tag 2'),
          ],
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('constrains to maxContentWidth and centers horizontally',
        (WidgetTester tester) async {
      await tester.pumpAdaptive(
        size: const Size(1600, 800),
        child: const AdaptiveFlex(
          maxContentWidth: 900.0,
          children: [
            Text('Content'),
          ],
        ),
      );

      final ConstrainedBox box =
          tester.widget(find.byType(ConstrainedBox).last);
      expect(box.constraints.maxWidth, equals(900.0));
      expect(find.byType(Align), findsOneWidget);
    });

    testWidgets('scrollableFallback wraps in SingleChildScrollView',
        (WidgetTester tester) async {
      await tester.pumpAdaptive(
        size: const Size(400, 300),
        child: const AdaptiveFlex(
          scrollableFallback: true,
          children: [
            Text('Scrollable 1'),
            Text('Scrollable 2'),
          ],
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets(
        'safely unwraps Expanded children in unbounded Column to prevent assertion errors',
        (WidgetTester tester) async {
      // In an unconstrained height environment like a vertical ListView or Column,
      // placing an Expanded in a collapsed Column would throw an assertion without safe unwrapping.
      await tester.pumpAdaptive(
        size: const Size(350, 600),
        child: ListView(
          children: const [
            AdaptiveFlex(
              arrangement: AdaptiveFlexArrangement.column,
              children: [
                Expanded(child: Text('Safe Child')),
              ],
            ),
          ],
        ),
      );

      expect(find.text('Safe Child'), findsOneWidget);
    });
  });
}
