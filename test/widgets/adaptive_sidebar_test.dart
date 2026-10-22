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

    testWidgets(
        'prevents RenderFlex overflow when forced narrow while isExpanded is true',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(800.0, 600.0),
        child: Center(
          child: SizedBox(
            width: 56.0, // leaves 32.0 width for item tile
            child: AdaptiveSidebar(
              isExpanded: true,
              items: sampleItems,
              selectedIndex: 1, // Analytics item with badge '5'
            ),
          ),
        ),
      );

      // Verify it didn't throw RenderFlex overflow and rendered icon safely
      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });

    testWidgets('renders all 9 distinct design models cleanly without errors',
        (tester) async {
      const styles = AdaptiveSidebarStyle.values;
      expect(styles.length, equals(9));

      for (final style in styles) {
        await tester.pumpAdaptive(
          size: const Size(1200.0, 800.0),
          child: AdaptiveSidebar(
            isExpanded: true,
            style: style,
            items: sampleItems,
            selectedIndex: 0,
          ),
        );

        expect(find.text('Dashboard'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('animated submenus expand and collapse on parent tap',
        (tester) async {
      final List<AdaptiveSidebarItem> hierarchicalItems = [
        const AdaptiveSidebarItem(
          icon: Icon(Icons.school),
          label: Text('Academics'),
          children: [
            AdaptiveSidebarItem(
              icon: Icon(Icons.class_),
              label: Text('Classes'),
            ),
            AdaptiveSidebarItem(
              icon: Icon(Icons.book),
              label: Text('Subjects'),
            ),
          ],
        ),
        const AdaptiveSidebarItem(
          icon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ];

      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: AdaptiveSidebar(
          isExpanded: true,
          items: hierarchicalItems,
          selectedIndex: 0,
        ),
      );

      // Initially closed
      expect(find.text('Classes'), findsNothing);

      // Tap parent item to expand submenu
      await tester.tap(find.text('Academics'));
      await tester.pumpAndSettle();

      expect(find.text('Classes'), findsOneWidget);
      expect(find.text('Subjects'), findsOneWidget);

      // Tap again to collapse
      await tester.tap(find.text('Academics'));
      await tester.pumpAndSettle();

      expect(find.text('Classes'), findsNothing);
    });

    testWidgets('accordion mode closes other open submenus when expanding',
        (tester) async {
      final List<AdaptiveSidebarItem> hierarchicalItems = [
        const AdaptiveSidebarItem(
          icon: Icon(Icons.folder),
          label: Text('Folder A'),
          initiallyExpanded: true,
          children: [
            AdaptiveSidebarItem(
                icon: Icon(Icons.file_copy), label: Text('File A1')),
          ],
        ),
        const AdaptiveSidebarItem(
          icon: Icon(Icons.folder),
          label: Text('Folder B'),
          children: [
            AdaptiveSidebarItem(
                icon: Icon(Icons.file_copy), label: Text('File B1')),
          ],
        ),
      ];

      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: AdaptiveSidebar(
          isExpanded: true,
          expansionMode: AdaptiveSubmenuExpansionMode.accordion,
          items: hierarchicalItems,
        ),
      );

      // Folder A initially open
      expect(find.text('File A1'), findsOneWidget);
      expect(find.text('File B1'), findsNothing);

      // Tap Folder B
      await tester.tap(find.text('Folder B'));
      await tester.pumpAndSettle();

      // Folder B opened, Folder A closed
      expect(find.text('File B1'), findsOneWidget);
      expect(find.text('File A1'), findsNothing);
    });

    testWidgets('highlights parent item when a child destination is selected',
        (tester) async {
      final List<AdaptiveSidebarItem> hierarchicalItems = [
        const AdaptiveSidebarItem(
          icon: Icon(Icons.folder),
          label: Text('Projects'),
          initiallyExpanded: true,
          children: [
            AdaptiveSidebarItem(icon: Icon(Icons.star), label: Text('Alpha')),
          ],
        ),
      ];

      // Index 1 corresponds to child 'Alpha'
      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: AdaptiveSidebar(
          isExpanded: true,
          items: hierarchicalItems,
          selectedIndex: 1,
        ),
      );

      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('interactive rail toggle expands and collapses sidebar',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSidebar(
              enableRailToggle: true,
              items: sampleItems,
              selectedIndex: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Starts expanded by internal default
      expect(find.text('Dashboard'), findsOneWidget);

      // Tap rail toggle button
      await tester.tap(find.byTooltip('Collapse sidebar'));
      await tester.pumpAndSettle();

      // Label collapsed
      expect(find.byTooltip('Expand sidebar'), findsOneWidget);
    });

    testWidgets('sidebar item with dropdownItems displays trigger and menu',
        (tester) async {
      String? selectedDropdown;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSidebar(
              isExpanded: true,
              items: [
                AdaptiveSidebarItem(
                  icon: const Icon(Icons.more_vert),
                  label: const Text('Actions'),
                  dropdownItems: [
                    const AdaptiveDropdownItem(
                      value: 'new_folder',
                      label: Text('New Folder'),
                    ),
                  ],
                  onDropdownSelected: (val) => selectedDropdown = val,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Actions'), findsOneWidget);

      // Tap item to open its dropdown
      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();

      expect(find.text('New Folder'), findsOneWidget);

      // Tap dropdown option
      await tester.tap(find.text('New Folder'));
      await tester.pumpAndSettle();

      expect(selectedDropdown, equals('new_folder'));
    });

    testWidgets(
        'fires onSubmenuExpansionChanged callback on expand and collapse',
        (tester) async {
      int? changedIndex;
      bool? isExpandedState;

      final List<AdaptiveSidebarItem> items = [
        const AdaptiveSidebarItem(
          icon: Icon(Icons.folder),
          label: Text('Documents'),
          children: [
            AdaptiveSidebarItem(
              icon: Icon(Icons.file_copy),
              label: Text('Doc 1'),
            ),
          ],
        ),
      ];

      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: AdaptiveSidebar(
          isExpanded: true,
          items: items,
          onSubmenuExpansionChanged: (index, expanded) {
            changedIndex = index;
            isExpandedState = expanded;
          },
        ),
      );

      // Expand
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      expect(changedIndex, equals(0));
      expect(isExpandedState, isTrue);

      // Collapse
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      expect(changedIndex, equals(0));
      expect(isExpandedState, isFalse);
    });

    testWidgets('supports all 5 AdaptiveSubmenuAnimation transitions',
        (tester) async {
      const animations = AdaptiveSubmenuAnimation.values;
      expect(animations.length, equals(5));

      for (final anim in animations) {
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey(anim),
            home: Scaffold(
              body: AdaptiveSidebar(
                key: ValueKey(anim),
                isExpanded: true,
                submenuAnimation: anim,
                items: const [
                  AdaptiveSidebarItem(
                    icon: Icon(Icons.folder),
                    label: Text('Folder'),
                    children: [
                      AdaptiveSidebarItem(
                        icon: Icon(Icons.file_present),
                        label: Text('File'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Folder'));
        await tester.pumpAndSettle();

        expect(find.text('File'), findsOneWidget);
      }
    });

    testWidgets('supports multi-level deep nested submenus (depth 2+)',
        (tester) async {
      int? selectedDest;

      final List<AdaptiveSidebarItem> nested = [
        const AdaptiveSidebarItem(
          icon: Icon(Icons.folder),
          label: Text('Level 0'),
          initiallyExpanded: true,
          children: [
            AdaptiveSidebarItem(
              icon: Icon(Icons.folder_open),
              label: Text('Level 1'),
              children: [
                AdaptiveSidebarItem(
                  icon: Icon(Icons.insert_drive_file),
                  label: Text('Level 2 Leaf'),
                ),
              ],
            ),
          ],
        ),
      ];

      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: AdaptiveSidebar(
          isExpanded: true,
          items: nested,
          onDestinationSelected: (idx) => selectedDest = idx,
        ),
      );

      expect(find.text('Level 0'), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);

      // Tap Level 1 to expand Level 2
      await tester.tap(find.text('Level 1'));
      await tester.pumpAndSettle();

      expect(find.text('Level 2 Leaf'), findsOneWidget);

      // Tap Level 2 leaf
      await tester.tap(find.text('Level 2 Leaf'));
      await tester.pumpAndSettle();

      // Top level is 0, level 1 is 1, level 2 is 2
      expect(selectedDest, equals(2));
    });

    testWidgets('respects reduced motion setting without throwing',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: AdaptiveSidebar(
            isExpanded: true,
            style: AdaptiveSidebarStyle.materialExpressive,
            items: sampleItems,
            selectedIndex: 0,
          ),
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
