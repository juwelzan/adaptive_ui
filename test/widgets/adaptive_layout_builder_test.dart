import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveLayoutBuilder', () {
    testWidgets('renders matching breakpoint slot',
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
              compact: (context, layout) => const Text('CompactSlot'),
              medium: (context, layout) => const Text('MediumSlot'),
              expanded: (context, layout) => const Text('ExpandedSlot'),
              large: (context, layout) => const Text('LargeSlot'),
              extraLarge: (context, layout) => const Text('ExtraLargeSlot'),
            ),
          ),
        );
      }

      await pumpForWidth(360);
      expect(find.text('CompactSlot'), findsOneWidget);

      await pumpForWidth(700);
      expect(find.text('MediumSlot'), findsOneWidget);

      await pumpForWidth(1000);
      expect(find.text('ExpandedSlot'), findsOneWidget);

      await pumpForWidth(1400);
      expect(find.text('LargeSlot'), findsOneWidget);

      await pumpForWidth(1800);
      expect(find.text('ExtraLargeSlot'), findsOneWidget);
    });

    testWidgets('falls back gracefully to smaller/adjacent slots',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1500, 800);

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: AdaptiveLayoutBuilder(
            compact: null,
            medium: null,
            expanded: null,
            large: null,
            extraLarge: null,
            fallback: _fallbackSlot,
          ),
        ),
      );

      expect(find.text('FallbackSlot'), findsOneWidget);
    });

    testWidgets('invokes general builder and preserves static child',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(500, 800);

      const childWidget = Text('StaticChild');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: AdaptiveLayoutBuilder(
            child: childWidget,
            builder: (context, layout, child) {
              return Column(
                children: [
                  Text('Width:${layout.availableWidth.toInt()}'),
                  child!,
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('Width:500'), findsOneWidget);
      expect(find.text('StaticChild'), findsOneWidget);
    });

    testWidgets('respects custom breakpoints override',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(500, 800);

      const customBreakpoints = AdaptiveBreakpoints(
        compactMax: 400.0,
        mediumMax: 700.0,
        expandedMax: 1000.0,
        largeMax: 1300.0,
      );

      // Width 500 would normally be compact (< 600), but with custom it is medium (400..700)
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: AdaptiveLayoutBuilder(
            breakpoints: customBreakpoints,
            compact: _compactSlot,
            medium: _mediumSlot,
          ),
        ),
      );

      expect(find.text('MediumSlot'), findsOneWidget);
      expect(find.text('CompactSlot'), findsNothing);
    });

    testWidgets(
        'nested AdaptiveLayoutBuilder uses local constraints instead of full window',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1600, 900); // Large window

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              SizedBox(
                width: 350, // Local compact container
                child: AdaptiveLayoutBuilder(
                  compact: _compactSlot,
                  large: _largeSlot,
                ),
              ),
              Expanded(
                child: AdaptiveLayoutBuilder(
                  compact: _compactSlot,
                  large: _largeSlot,
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.text('CompactSlot'), findsOneWidget);
      expect(find.text('LargeSlot'), findsOneWidget);
    });
  });
}

Widget _compactSlot(BuildContext context, AdaptiveLayoutData layout) =>
    const Text('CompactSlot');
Widget _mediumSlot(BuildContext context, AdaptiveLayoutData layout) =>
    const Text('MediumSlot');
Widget _largeSlot(BuildContext context, AdaptiveLayoutData layout) =>
    const Text('LargeSlot');
Widget _fallbackSlot(BuildContext context, AdaptiveLayoutData layout) =>
    const Text('FallbackSlot');
