import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveSidebar', () {
    final List<AdaptiveSidebarItem> sampleItems = [
      const AdaptiveSidebarItem(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: Text('Dashboard'),
        tooltip: 'Dashboard View',
      ),
      const AdaptiveSidebarItem(
        icon: Icon(Icons.analytics_outlined),
        selectedIcon: Icon(Icons.analytics),
        label: Text('Analytics'),
        badge: Text('5'),
      ),
      const AdaptiveSidebarItem(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: Text('Settings'),
      ),
    ];

    testWidgets(
        'renders in collapsed mode by default on medium viewport (768dp)',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(768.0, 1024.0), // medium < large (1200)
        child: AdaptiveSidebar(
          items: sampleItems,
          selectedIndex: 0,
        ),
      );

      // In collapsed mode (72dp), label is not visible in Row layout
      final AnimatedContainer container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      expect(container.constraints?.maxWidth ?? 72.0, equals(72.0));
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
    });

    testWidgets('renders in expanded mode on large desktop viewport (1200dp)',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1280.0, 900.0), // large >= 1200
        child: AdaptiveSidebar(
          items: sampleItems,
          selectedIndex: 1,
        ),
      );

      final AnimatedContainer container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      expect(container.constraints?.maxWidth ?? 240.0, equals(240.0));
      // In expanded mode, labels and selectedIcon are visible
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });

    testWidgets('honors explicit isExpanded override', (tester) async {
      await tester.pumpAdaptive(
        size: const Size(600.0, 900.0), // compact/medium
        child: AdaptiveSidebar(
          isExpanded: true,
          items: sampleItems,
          selectedIndex: 0,
        ),
      );

      // Explicitly expanded
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('triggers onDestinationSelected callback on item tap',
        (tester) async {
      int selected = 0;

      await tester.pumpAdaptive(
        size: const Size(1280.0, 900.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AdaptiveSidebar(
              isExpanded: true,
              items: sampleItems,
              selectedIndex: selected,
              onDestinationSelected: (idx) {
                setState(() => selected = idx);
              },
            );
          },
        ),
      );

      expect(selected, equals(0));

      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();

      expect(selected, equals(1));
    });

    testWidgets(
        'scrolls smoothly without overflow when items exceed available height',
        (tester) async {
      final List<AdaptiveSidebarItem> manyItems = List.generate(
        25,
        (i) => AdaptiveSidebarItem(
          icon: const Icon(Icons.circle),
          label: Text('Navigation Item #$i'),
        ),
      );

      await tester.pumpAdaptive(
        size: const Size(1000.0, 400.0), // short height
        child: AdaptiveSidebar(
          isExpanded: true,
          items: manyItems,
          selectedIndex: 0,
        ),
      );

      // Verifies scroll view is present and first item rendered without overflow
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Navigation Item #0'), findsOneWidget);
    });

    testWidgets('clamps width safely under extremely narrow parent constraints',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(800.0, 600.0),
        child: Center(
          child: SizedBox(
            width: 50.0, // narrower than default 72dp collapsed
            child: AdaptiveSidebar(
              items: sampleItems,
              selectedIndex: 0,
            ),
          ),
        ),
      );

      final AnimatedContainer container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      // Clamped to 50.0 without throwing overflow assertion
      expect(container.constraints?.maxWidth, equals(50.0));
    });

    testWidgets('renders header, footer, leading, and trailing widgets',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1280.0, 900.0),
        child: AdaptiveSidebar(
          isExpanded: true,
          header: const Text('Header Widget'),
          footer: const Text('Footer Widget'),
          leading: const Text('Leading Widget'),
          trailing: const Text('Trailing Widget'),
          items: sampleItems,
        ),
      );

      expect(find.text('Header Widget'), findsOneWidget);
      expect(find.text('Footer Widget'), findsOneWidget);
      expect(find.text('Leading Widget'), findsOneWidget);
      expect(find.text('Trailing Widget'), findsOneWidget);
    });
  });
}
