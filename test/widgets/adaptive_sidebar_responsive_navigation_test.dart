import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveSidebar — Unified Responsive Navigation Suite', () {
    final List<AdaptiveSidebarItem> sampleItems = [
      const AdaptiveSidebarItem(
        id: 'home',
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: Text('Home'),
        tooltip: 'Home Screen',
      ),
      const AdaptiveSidebarItem(
        id: 'search',
        icon: Icon(Icons.search_outlined),
        selectedIcon: Icon(Icons.search),
        label: Text('Search'),
        badge: Text('3'),
      ),
      const AdaptiveSidebarItem(
        id: 'analytics',
        icon: Icon(Icons.analytics_outlined),
        selectedIcon: Icon(Icons.analytics),
        label: Text('Analytics'),
      ),
      const AdaptiveSidebarItem(
        id: 'profile',
        icon: Icon(Icons.person_outlined),
        selectedIcon: Icon(Icons.person),
        label: Text('Profile'),
      ),
    ];

    // 1. Compact width displays bottom navigation
    testWidgets('compact viewport (<600dp) displays mobile bottom navigation',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(400.0, 800.0),
        child: AdaptiveSidebar(
          items: sampleItems,
          selectedIndex: 0,
          child: const Center(child: Text('Main Page Content')),
        ),
      );

      expect(find.byType(AdaptiveBottomNavigationBar), findsOneWidget);
      expect(find.byKey(const Key('adaptive_sidebar_container')), findsNothing);
      expect(find.text('Main Page Content'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    // 2. Wide width displays configured sidebar
    testWidgets('wide viewport (>=600dp) displays configured sidebar',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1280.0, 800.0),
        child: AdaptiveSidebar(
          items: sampleItems,
          selectedIndex: 0,
          child: const Center(child: Text('Main Page Content')),
        ),
      );

      expect(
          find.byKey(const Key('adaptive_sidebar_container')), findsOneWidget);
      expect(find.byType(AdaptiveBottomNavigationBar), findsNothing);
      expect(find.text('Main Page Content'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    // 3. Crossing breakpoints preserves selection
    testWidgets('crossing breakpoints preserves selected index bidirectionally',
        (tester) async {
      int activeIndex = 2; // Analytics

      await tester.pumpAdaptive(
        size: const Size(1000.0, 800.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AdaptiveSidebar(
              items: sampleItems,
              selectedIndex: activeIndex,
              onItemSelected: (idx) => setState(() => activeIndex = idx),
              child: Text('Active: $activeIndex'),
            );
          },
        ),
      );

      // Desktop: item 2 (Analytics) selected
      expect(find.byIcon(Icons.analytics), findsOneWidget);

      // Transition to mobile viewport
      await tester.pumpAdaptive(
        size: const Size(390.0, 844.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AdaptiveSidebar(
              items: sampleItems,
              selectedIndex: activeIndex,
              onItemSelected: (idx) => setState(() => activeIndex = idx),
              child: Text('Active: $activeIndex'),
            );
          },
        ),
      );

      // Bottom nav is rendered, item 2 remains selected
      expect(find.byType(AdaptiveBottomNavigationBar), findsOneWidget);
      expect(find.text('Active: 2'), findsOneWidget);

      // Transition back to desktop viewport
      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AdaptiveSidebar(
              items: sampleItems,
              selectedIndex: activeIndex,
              onItemSelected: (idx) => setState(() => activeIndex = idx),
              child: Text('Active: $activeIndex'),
            );
          },
        ),
      );

      expect(
          find.byKey(const Key('adaptive_sidebar_container')), findsOneWidget);
      expect(find.text('Active: 2'), findsOneWidget);
    });

    // 4. Resizing does not reconstruct unrelated page state unnecessarily
    testWidgets('resizing does not reconstruct unrelated page state',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1000.0, 800.0),
        child: AdaptiveSidebar(
          items: sampleItems,
          selectedIndex: 0,
          child: const _CounterPageStateful(),
        ),
      );

      expect(find.text('Counter: 0'), findsOneWidget);

      // Tap to increment counter inside page body
      await tester.tap(find.text('Increment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Increment'));
      await tester.pumpAndSettle();

      expect(find.text('Counter: 2'), findsOneWidget);

      // Resize to compact viewport (< 600dp)
      await tester.pumpAdaptive(
        size: const Size(400.0, 800.0),
        child: AdaptiveSidebar(
          items: sampleItems,
          selectedIndex: 0,
          child: const _CounterPageStateful(),
        ),
      );

      // Page state is preserved!
      expect(find.text('Counter: 2'), findsOneWidget);
    });

    // 5. Exactly one destination
    testWidgets('handles exactly one navigation item safely', (tester) async {
      final singleItem = [
        const AdaptiveSidebarItem(
          icon: Icon(Icons.home),
          label: Text('Solo Home'),
        ),
      ];

      await tester.pumpAdaptive(
        size: const Size(390.0, 844.0),
        child: AdaptiveSidebar(
          items: singleItem,
          selectedIndex: 0,
        ),
      );

      expect(find.text('Solo Home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // 6. Two destinations
    testWidgets('handles two navigation destinations cleanly', (tester) async {
      final twoItems = [
        const AdaptiveSidebarItem(icon: Icon(Icons.home), label: Text('Home')),
        const AdaptiveSidebarItem(
            icon: Icon(Icons.settings), label: Text('Settings')),
      ];

      await tester.pumpAdaptive(
        size: const Size(390.0, 844.0),
        child: AdaptiveSidebar(
          items: twoItems,
          selectedIndex: 1,
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    // 7. Three to five destinations
    testWidgets('renders four destinations evenly distributed', (tester) async {
      await tester.pumpAdaptive(
        size: const Size(400.0, 800.0),
        child: AdaptiveSidebar(
          items: sampleItems,
          selectedIndex: 0,
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    // 8. Ten or more destinations under scroll policy
    testWidgets('ten destinations render safely with scroll policy',
        (tester) async {
      final tenItems = List.generate(
        10,
        (i) => AdaptiveSidebarItem(
          id: 'item_$i',
          icon: const Icon(Icons.star),
          label: Text('Tab $i'),
        ),
      );

      await tester.pumpAdaptive(
        size: const Size(390.0, 844.0),
        child: AdaptiveSidebar(
          items: tenItems,
          selectedIndex: 0,
          bottomNavigation: const AdaptiveBottomNavigationConfig(
            overflowPolicy: AdaptiveBottomNavOverflowPolicy.scroll,
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // 9. Very narrow parent constraints
    testWidgets(
        'resilient under very narrow parent constraints without overflow',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(320.0, 568.0),
        child: Center(
          child: SizedBox(
            width: 50.0,
            child: AdaptiveSidebar(
              items: sampleItems,
              selectedIndex: 0,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    // 10. Long labels and large text scaling
    testWidgets('handles long localized labels and 2.0x text scaling safely',
        (tester) async {
      final longItem = [
        const AdaptiveSidebarItem(
          icon: Icon(Icons.language),
          label: Text('Extremely Long Localized Navigation Item Title Here'),
        ),
        const AdaptiveSidebarItem(
          icon: Icon(Icons.info),
          label: Text('Another Comprehensive Navigation Destination'),
        ),
      ];

      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        textScaler: const TextScaler.linear(2.0),
        child: AdaptiveSidebar(
          items: longItem,
          selectedIndex: 0,
        ),
      );

      expect(tester.takeException(), isNull);
    });

    // 11. RTL layout
    testWidgets('supports RTL layout without geometry inversion bugs',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(400.0, 800.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: AdaptiveSidebar(
            items: sampleItems,
            selectedIndex: 0,
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // 12. Badges and custom destination widgets
    testWidgets('renders badges and custom builder widgets', (tester) async {
      final customItems = [
        const AdaptiveSidebarItem(
          icon: Icon(Icons.notifications),
          label: Text('Alerts'),
          badge: Text('99+'),
        ),
        AdaptiveSidebarItem(
          icon: const Icon(Icons.star),
          label: const Text('Custom'),
          customBuilder: (context, isSelected) {
            return const Center(child: Text('Custom Dest Tile'));
          },
        ),
      ];

      await tester.pumpAdaptive(
        size: const Size(400.0, 800.0),
        child: AdaptiveSidebar(
          items: customItems,
          selectedIndex: 0,
        ),
      );

      expect(find.text('99+'), findsOneWidget);
      expect(find.text('Custom Dest Tile'), findsOneWidget);
    });

    // 13. Auto overflow policy adapts based on destination count
    testWidgets(
        'auto overflow policy automatically displays More item when destinations exceed maxVisibleItems',
        (tester) async {
      final sevenItems = List.generate(
        7,
        (i) => AdaptiveSidebarItem(
          id: 'item_$i',
          icon: const Icon(Icons.circle),
          label: Text('Tab $i'),
        ),
      );

      await tester.pumpAdaptive(
        size: const Size(400.0, 800.0),
        child: AdaptiveSidebar(
          items: sevenItems,
          selectedIndex: 0,
          bottomNavigation: const AdaptiveBottomNavigationConfig(
            overflowPolicy: AdaptiveBottomNavOverflowPolicy.auto,
            maxVisibleItems: 5,
          ),
        ),
      );

      expect(find.text('Tab 0'), findsOneWidget);
      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('Tab 3'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
      expect(find.text('Tab 4'), findsNothing);
    });

    // 14. Menu overflow policy & More menu reachability
    testWidgets(
        'overflow menu policy gathers remaining destinations into accessible More sheet and every destination remains reachable',
        (tester) async {
      int selectedIdx = 0;
      final sixItems = List.generate(
        6,
        (i) => AdaptiveSidebarItem(
          id: 'item_$i',
          icon: const Icon(Icons.circle),
          label: Text('Page $i'),
        ),
      );

      await tester.pumpAdaptive(
        size: const Size(390.0, 844.0),
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AdaptiveSidebar(
                  items: sixItems,
                  selectedIndex: selectedIdx,
                  onItemSelected: (idx) => setState(() => selectedIdx = idx),
                  bottomNavigation: const AdaptiveBottomNavigationConfig(
                    overflowPolicy: AdaptiveBottomNavOverflowPolicy.menu,
                    maxVisibleItems: 4,
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Primary visible items (0, 1, 2) + "More"
      expect(find.text('Page 0'), findsOneWidget);
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 2'), findsOneWidget);
      expect(find.text('Page 3'), findsNothing); // Inside More
      expect(find.text('More'), findsOneWidget);

      // Tap "More" to open modal bottom sheet
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      // Overflow items 3, 4, 5 are now visible in sheet
      expect(find.text('Page 3'), findsOneWidget);
      expect(find.text('Page 4'), findsOneWidget);
      expect(find.text('Page 5'), findsOneWidget);

      // Tap Page 4
      await tester.tap(find.text('Page 4'));
      await tester.pumpAndSettle();

      expect(selectedIdx, equals(4));
    });

    // 15. Selected-item callbacks (onItemSelected and onDestinationSelected)
    testWidgets(
        'triggers both onItemSelected and onDestinationSelected callbacks',
        (tester) async {
      int itemSelectedVal = -1;
      int destSelectedVal = -1;

      await tester.pumpAdaptive(
        size: const Size(400.0, 800.0),
        child: AdaptiveSidebar(
          items: sampleItems,
          selectedIndex: 0,
          onItemSelected: (i) => itemSelectedVal = i,
          onDestinationSelected: (i) => destSelectedVal = i,
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(itemSelectedVal, equals(1));
      expect(destSelectedVal, equals(1));
    });

    // 16. PageView index synchronization
    testWidgets('synchronizes PageView pages with item selection',
        (tester) async {
      int activeIndex = 0;

      await tester.pumpAdaptive(
        size: const Size(400.0, 800.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AdaptiveSidebar(
              items: sampleItems,
              selectedIndex: activeIndex,
              onItemSelected: (i) => setState(() => activeIndex = i),
              pages: const [
                Center(child: Text('Page 0 Content')),
                Center(child: Text('Page 1 Content')),
                Center(child: Text('Page 2 Content')),
                Center(child: Text('Page 3 Content')),
              ],
            );
          },
        ),
      );

      expect(find.text('Page 0 Content'), findsOneWidget);

      // Tap Search (item 1)
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(activeIndex, equals(1));
      expect(find.text('Page 1 Content'), findsOneWidget);
    });

    // 17. User-driven PageView page changes
    testWidgets(
        'user-driven PageView page swipe updates selected navigation index',
        (tester) async {
      int activeIndex = 0;

      await tester.pumpAdaptive(
        size: const Size(400.0, 800.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AdaptiveSidebar(
              items: sampleItems,
              selectedIndex: activeIndex,
              onItemSelected: (i) => setState(() => activeIndex = i),
              pages: const [
                Center(child: Text('Page 0 Content')),
                Center(child: Text('Page 1 Content')),
                Center(child: Text('Page 2 Content')),
                Center(child: Text('Page 3 Content')),
              ],
            );
          },
        ),
      );

      expect(find.text('Page 0 Content'), findsOneWidget);

      // Drag PageView horizontally left to swipe to page 1
      await tester.drag(find.byType(PageView), const Offset(-400.0, 0.0));
      await tester.pumpAndSettle();

      expect(activeIndex, equals(1));
      expect(find.text('Page 1 Content'), findsOneWidget);
    });

    // 18. Dynamic item-list updates
    testWidgets('adapts smoothly when items list updates dynamically',
        (tester) async {
      List<AdaptiveSidebarItem> currentList = [sampleItems[0], sampleItems[1]];

      await tester.pumpAdaptive(
        size: const Size(400.0, 800.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentList = sampleItems;
                    });
                  },
                  child: const Text('Add Items'),
                ),
                Expanded(
                  child: AdaptiveSidebar(
                    items: currentList,
                    selectedIndex: 0,
                  ),
                ),
              ],
            );
          },
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Analytics'), findsNothing);

      await tester.tap(find.text('Add Items'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
    });

    // 19. Removed or disabled selected items
    testWidgets(
        'safely handles disabled item taps without triggering callbacks',
        (tester) async {
      int tapCount = 0;
      final disabledItems = [
        const AdaptiveSidebarItem(
          icon: Icon(Icons.lock),
          label: Text('Locked Item'),
          enabled: false,
        ),
        const AdaptiveSidebarItem(
          icon: Icon(Icons.public),
          label: Text('Active Item'),
          enabled: true,
        ),
      ];

      await tester.pumpAdaptive(
        size: const Size(400.0, 800.0),
        child: AdaptiveSidebar(
          items: disabledItems,
          selectedIndex: 1,
          onItemSelected: (_) => tapCount++,
        ),
      );

      await tester.tap(find.text('Locked Item'));
      await tester.pumpAndSettle();

      expect(tapCount, equals(0));
    });

    // 20. Controller ownership and disposal
    testWidgets('does not dispose externally owned PageController on unmount',
        (tester) async {
      final PageController externalController = PageController();

      await tester.pumpAdaptive(
        size: const Size(400.0, 800.0),
        child: AdaptiveSidebar(
          items: sampleItems,
          selectedIndex: 0,
          pageController: externalController,
          pages: const [
            Text('P1'),
            Text('P2'),
            Text('P3'),
            Text('P4'),
          ],
        ),
      );

      // Unmount by pumping a replacement widget
      await tester.pumpAdaptive(
        size: const Size(400.0, 800.0),
        child: const SizedBox.shrink(),
      );

      // External controller must still be valid and NOT disposed!
      expect(() => externalController.hasClients, returnsNormally);
      externalController.dispose();
    });

    // 21. Classic presentation
    testWidgets('renders Classic sidebar presentation on wide layout',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1200.0, 900.0),
        child: AdaptiveSidebar(
          model: AdaptiveSidebarModel.classic,
          items: sampleItems,
          selectedIndex: 0,
          child: const Text('Body'),
        ),
      );

      final AnimatedContainer container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.zero));
    });

    // 22. Floating elevated presentation
    testWidgets('renders Floating Elevated presentation on wide layout',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1200.0, 900.0),
        child: AdaptiveSidebar(
          model: AdaptiveSidebarModel.floating,
          floatingMode: AdaptiveFloatingSidebarMode.elevated,
          items: sampleItems,
          selectedIndex: 0,
          child: const Text('Body'),
        ),
      );

      final AnimatedContainer container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(16.0)));
      expect(decoration.boxShadow, isNotNull);
    });

    // 23. Floating inset presentation
    testWidgets('renders Floating Inset presentation on wide layout',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1200.0, 900.0),
        child: AdaptiveSidebar(
          model: AdaptiveSidebarModel.floating,
          floatingMode: AdaptiveFloatingSidebarMode.inset,
          items: sampleItems,
          selectedIndex: 0,
          child: const Text('Body'),
        ),
      );

      final AnimatedContainer container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(12.0)));
      expect(decoration.boxShadow, isNull);
    });

    // 24. Floating minimal presentation
    testWidgets('renders Floating Minimal presentation on wide layout',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1200.0, 900.0),
        child: AdaptiveSidebar(
          model: AdaptiveSidebarModel.floating,
          floatingMode: AdaptiveFloatingSidebarMode.minimal,
          items: sampleItems,
          selectedIndex: 0,
          child: const Text('Body'),
        ),
      );

      final AnimatedContainer container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(8.0)));
    });

    // 25. Expand/collapse and submenu behavior
    testWidgets(
        'preserves submenu expansion and rail toggle in unified sidebar',
        (tester) async {
      final hierarchicalItems = [
        const AdaptiveSidebarItem(
          icon: Icon(Icons.school),
          label: Text('Academics'),
          children: [
            AdaptiveSidebarItem(
              icon: Icon(Icons.class_),
              label: Text('Classes'),
            ),
          ],
        ),
        const AdaptiveSidebarItem(
          icon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ];

      await tester.pumpAdaptive(
        size: const Size(1200.0, 900.0),
        child: AdaptiveSidebar(
          isExpanded: true,
          items: hierarchicalItems,
          selectedIndex: 0,
          enableRailToggle: true,
          child: const Text('Body'),
        ),
      );

      expect(find.text('Classes'), findsNothing);

      await tester.tap(find.text('Academics'));
      await tester.pumpAndSettle();

      expect(find.text('Classes'), findsOneWidget);

      // Rail toggle button exists and is clickable
      expect(find.byKey(const Key('adaptive_sidebar_rail_toggle')),
          findsOneWidget);
      await tester.tap(find.byKey(const Key('adaptive_sidebar_rail_toggle')));
      await tester.pumpAndSettle();
    });
  });
}

class _CounterPageStateful extends StatefulWidget {
  const _CounterPageStateful();

  @override
  State<_CounterPageStateful> createState() => _CounterPageStatefulState();
}

class _CounterPageStatefulState extends State<_CounterPageStateful> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Counter: $_counter'),
        ElevatedButton(
          onPressed: () => setState(() => _counter++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
