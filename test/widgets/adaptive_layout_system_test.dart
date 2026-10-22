import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

class _StatefulCounter extends StatefulWidget {
  const _StatefulCounter({super.key, required this.label});
  final String label;

  @override
  State<_StatefulCounter> createState() => _StatefulCounterState();
}

class _StatefulCounterState extends State<_StatefulCounter> {
  int count = 0;

  void increment() {
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('counter_tap'),
      onTap: increment,
      child: Text('${widget.label}: $count', textDirection: TextDirection.ltr),
    );
  }
}

void main() {
  group('Phase 9: AdaptiveLayoutBuilder', () {
    testWidgets('selects matching slots for compact, medium, and expanded',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Future<void> pumpForWidth(double width) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = Size(width, 800);
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: AdaptiveLayoutBuilder(
              compact: (ctx, layout) => Text(
                  'Compact layout (${layout.constraints.maxWidth.toInt()})'),
              medium: (ctx, layout) => Text(
                  'Medium layout (${layout.constraints.maxWidth.toInt()})'),
              expanded: (ctx, layout) => Text(
                  'Expanded layout (${layout.constraints.maxWidth.toInt()})'),
              large: (ctx, layout) =>
                  Text('Large layout (${layout.constraints.maxWidth.toInt()})'),
            ),
          ),
        );
      }

      await pumpForWidth(380);
      expect(find.text('Compact layout (380)'), findsOneWidget);

      await pumpForWidth(720);
      expect(find.text('Medium layout (720)'), findsOneWidget);

      await pumpForWidth(1024);
      expect(find.text('Expanded layout (1024)'), findsOneWidget);

      await pumpForWidth(1300);
      expect(find.text('Large layout (1300)'), findsOneWidget);
    });

    testWidgets(
        'provides access to actual constraints and respects custom breakpoints',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(500, 800);

      const customBreakpoints = AdaptiveBreakpoints(
        compactMax: 450.0,
        mediumMax: 800.0,
        expandedMax: 1100.0,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: AdaptiveLayoutBuilder(
            breakpoints: customBreakpoints,
            compact: (ctx, layout) => const Text('CustomCompact'),
            medium: (ctx, layout) =>
                Text('CustomMedium:${layout.constraints.maxWidth.toInt()}'),
          ),
        ),
      );

      // Width 500 is medium under customBreakpoints (450..800)
      expect(find.text('CustomMedium:500'), findsOneWidget);
    });

    testWidgets(
        'preserves state when preserveState is true across breakpoint transitions',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final GlobalKey counterKey = GlobalKey();

      Future<void> pumpForWidth(double width) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = Size(width, 800);
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: AdaptiveLayoutBuilder(
              preserveState: true,
              compact: (ctx, layout) => Column(
                children: [
                  const Text('Slot:Compact'),
                  _StatefulCounter(key: counterKey, label: 'Counter'),
                ],
              ),
              expanded: (ctx, layout) => Row(
                children: [
                  const Text('Slot:Expanded'),
                  _StatefulCounter(key: counterKey, label: 'Counter'),
                ],
              ),
            ),
          ),
        );
      }

      // 1. Pump in compact mode
      await pumpForWidth(360);
      expect(find.text('Slot:Compact'), findsOneWidget);
      expect(find.text('Counter: 0'), findsOneWidget);

      // 2. Increment counter
      await tester.tap(find.byKey(const Key('counter_tap')));
      await tester.pump();
      expect(find.text('Counter: 1'), findsOneWidget);

      // 3. Resize to expanded mode
      await pumpForWidth(900);
      expect(find.text('Slot:Expanded'), findsOneWidget);
      // State is preserved!
      expect(find.text('Counter: 1'), findsOneWidget);

      // 4. Increment again in expanded mode
      await tester.tap(find.byKey(const Key('counter_tap')));
      await tester.pump();
      expect(find.text('Counter: 2'), findsOneWidget);

      // 5. Transition back to compact mode
      await pumpForWidth(360);
      expect(find.text('Slot:Compact'), findsOneWidget);
      expect(find.text('Counter: 2'), findsOneWidget);
    });

    testWidgets('preserves child state using builder and static child',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Future<void> pumpForWidth(double width) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = Size(width, 800);
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: AdaptiveLayoutBuilder(
              preserveState: true,
              child: const _StatefulCounter(label: 'BuilderChild'),
              builder: (ctx, layout, child) {
                if (layout.containerBreakpoint == Breakpoint.compact) {
                  return Column(children: [const Text('CompactMode'), child!]);
                }
                return Row(children: [const Text('ExpandedMode'), child!]);
              },
            ),
          ),
        );
      }

      await pumpForWidth(360);
      expect(find.text('CompactMode'), findsOneWidget);
      expect(find.text('BuilderChild: 0'), findsOneWidget);

      await tester.tap(find.byKey(const Key('counter_tap')));
      await tester.pump();
      expect(find.text('BuilderChild: 1'), findsOneWidget);

      await pumpForWidth(1000);
      expect(find.text('ExpandedMode'), findsOneWidget);
      expect(find.text('BuilderChild: 1'), findsOneWidget);
    });

    testWidgets(
        'nested AdaptiveLayoutBuilder uses local constraints instead of screen size',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1400, 900); // Expanded screen

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              SizedBox(
                width: 320, // Local compact container
                child: AdaptiveLayoutBuilder(
                  compact: (ctx, layout) => Text(
                      'LocalCompact:${layout.constraints.maxWidth.toInt()}'),
                  expanded: (ctx, layout) => const Text('LocalExpanded'),
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.text('LocalCompact:320'), findsOneWidget);
      expect(find.text('LocalExpanded'), findsNothing);
    });
  });

  group('Phase 9: AdaptiveGrid & SliverAdaptiveGrid', () {
    testWidgets('AdaptiveGrid respects maxColumns and minColumns',
        (WidgetTester tester) async {
      // 1. On wide screen (1200dp) with minItemWidth 100, default columns would be 10+,
      // but maxColumns: 3 restricts it to 3 columns.
      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: AdaptiveGrid(
          minItemWidth: 100.0,
          maxColumns: 3,
          children: List.generate(6, (i) => Text('Item $i')),
        ),
      );

      GridView grid = tester.widget(find.byType(GridView));
      SliverGridDelegateWithFixedCrossAxisCount delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(3));

      // 2. On narrow screen (320dp) with minItemWidth 240, default would be 1 column,
      // but minColumns: 2 forces 2 columns.
      await tester.pumpAdaptive(
        size: const Size(320.0, 600.0),
        child: AdaptiveGrid(
          minItemWidth: 240.0,
          minColumns: 2,
          children: List.generate(4, (i) => Text('Item $i')),
        ),
      );

      grid = tester.widget(find.byType(GridView));
      delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(2));
    });

    testWidgets(
        'AdaptiveGrid handles small collection (1 item) and large collection lazily',
        (WidgetTester tester) async {
      // 1 item
      await tester.pumpAdaptive(
        size: const Size(600.0, 800.0),
        child: AdaptiveGrid(
          minItemWidth: 200.0,
          children: const [Text('Single Item')],
        ),
      );
      expect(find.text('Single Item'), findsOneWidget);

      // Large collection (500 items) with AdaptiveGrid.builder
      await tester.pumpAdaptive(
        size: const Size(800.0, 600.0),
        child: AdaptiveGrid.builder(
          minItemWidth: 200.0,
          itemCount: 500,
          itemBuilder: (ctx, index) => Text('Cell #$index'),
        ),
      );

      expect(find.text('Cell #0'), findsOneWidget);
      // Item 499 should NOT be built eagerly (lazy rendering verification)
      expect(find.text('Cell #499'), findsNothing);
    });

    testWidgets('SliverAdaptiveGrid works within CustomScrollView',
        (WidgetTester tester) async {
      await tester.pumpAdaptive(
        size: const Size(900.0, 700.0),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: Text('Header')),
            SliverAdaptiveGrid(
              minItemWidth: 200.0,
              maxColumns: 4,
              children: List.generate(4, (i) => Text('SliverItem $i')),
            ),
          ],
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('SliverItem 0'), findsOneWidget);
      expect(find.text('SliverItem 3'), findsOneWidget);
    });

    testWidgets(
        'SliverAdaptiveGrid.builder lazily builds items in CustomScrollView',
        (WidgetTester tester) async {
      await tester.pumpAdaptive(
        size: const Size(900.0, 700.0),
        child: CustomScrollView(
          slivers: [
            SliverAdaptiveGrid.builder(
              minItemWidth: 220.0,
              itemCount: 200,
              itemBuilder: (ctx, index) => Text('LazySliver #$index'),
            ),
          ],
        ),
      );

      expect(find.text('LazySliver #0'), findsOneWidget);
      expect(find.text('LazySliver #199'), findsNothing);
    });
  });

  group('Phase 9: AdaptiveRow and AdaptiveColumn Enhancements', () {
    testWidgets(
        'AdaptiveRow auto-collapses when minItemWidth cannot fit available width',
        (WidgetTester tester) async {
      const widget = AdaptiveRow(
        autoCollapse: true,
        minItemWidth: 150.0,
        children: [
          Text('First'),
          Text('Second'),
          Text('Third'),
        ],
      );

      // Available width 400 < 3 * 150 = 450 -> triggers collapse to Column
      await tester.pumpAdaptive(
        size: const Size(400.0, 700.0),
        child: widget,
      );
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsNothing);

      // Available width 600 >= 450 -> stays as Row
      await tester.pumpAdaptive(
        size: const Size(600.0, 700.0),
        child: widget,
      );
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsNothing);
    });

    testWidgets('AdaptiveRow wraps children when wrap is true',
        (WidgetTester tester) async {
      await tester.pumpAdaptive(
        size: const Size(500.0, 700.0),
        child: const AdaptiveRow(
          wrap: true,
          spacing: AdaptiveValue.fixed(12.0),
          runSpacing: 8.0,
          children: [
            Text('Tag 1'),
            Text('Tag 2'),
            Text('Tag 3'),
          ],
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(Row), findsNothing);
      expect(find.text('Tag 1'), findsOneWidget);
      expect(find.text('Tag 3'), findsOneWidget);
    });

    testWidgets('AdaptiveRow respects developer-controlled direction override',
        (WidgetTester tester) async {
      // Force vertical direction on a wide screen
      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: const AdaptiveRow(
          direction: Axis.vertical,
          children: [
            Text('Child 1'),
            Text('Child 2'),
          ],
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsNothing);

      // Force horizontal direction on a narrow screen
      await tester.pumpAdaptive(
        size: const Size(320.0, 600.0),
        child: const AdaptiveRow(
          direction: Axis.horizontal,
          autoCollapse: true,
          children: [
            Text('Child 1'),
            Text('Child 2'),
          ],
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsNothing);
    });

    testWidgets(
        'AdaptiveColumn constrains content to maxContentWidth on wide displays',
        (WidgetTester tester) async {
      await tester.pumpAdaptive(
        size: const Size(1400.0, 900.0),
        child: const AdaptiveColumn(
          maxContentWidth: 720.0,
          children: [
            Text('Article Header'),
            Text('Article Body'),
          ],
        ),
      );

      expect(find.byType(ConstrainedBox), findsWidgets);
      final ConstrainedBox box =
          tester.widget(find.byType(ConstrainedBox).last);
      expect(box.constraints.maxWidth, equals(720.0));
      expect(find.text('Article Header'), findsOneWidget);
    });

    testWidgets(
        'AdaptiveRow and AdaptiveGrid render correctly in RTL directionality',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: AdaptiveRow(
            spacing: const AdaptiveValue.fixed(8.0),
            children: const [
              Text('שלום 1'),
              Text('שלום 2'),
            ],
          ),
        ),
      );

      expect(find.text('שלום 1'), findsOneWidget);
      expect(find.text('שלום 2'), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets(
        'AdaptiveGrid handles narrow width (200dp) and large text scale safely',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpAdaptive(
        size: const Size(200.0, 400.0),
        textScaler: const TextScaler.linear(2.0),
        child: AdaptiveGrid(
          minItemWidth: 180.0,
          children: const [
            Text('Large text in narrow grid'),
          ],
        ),
      );

      expect(find.text('Large text in narrow grid'), findsOneWidget);
      final GridView grid = tester.widget(find.byType(GridView));
      final SliverGridDelegateWithFixedCrossAxisCount delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(1));
    });
  });
}
