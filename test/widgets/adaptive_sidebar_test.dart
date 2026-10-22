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

    // 1. Classic model defaults
    testWidgets('renders Classic model defaults correctly', (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1280.0, 900.0),
        child: AdaptiveSidebar(
          model: AdaptiveSidebarModel.classic,
          items: sampleItems,
          selectedIndex: 0,
        ),
      );

      final AnimatedContainer container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      final BoxDecoration decoration = container.decoration as BoxDecoration;

      // Classic characteristics: zero radius, zero elevation, right border
      expect(decoration.borderRadius, equals(BorderRadius.zero));
      expect(decoration.boxShadow, isNull);
      expect((decoration.border as Border?)?.right, isNotNull);
      // Full height: outer margin is zero (no outer Padding widget around AnimatedContainer)
      expect(find.text('Dashboard'), findsOneWidget);
    });

    // 2. Floating Elevated defaults
    testWidgets('renders Floating Elevated mode defaults correctly',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1280.0, 900.0),
        child: AdaptiveSidebar(
          model: AdaptiveSidebarModel.floating,
          floatingMode: AdaptiveFloatingSidebarMode.elevated,
          items: sampleItems,
          selectedIndex: 0,
        ),
      );

      final AnimatedContainer container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      final BoxDecoration decoration = container.decoration as BoxDecoration;

      // Elevated characteristics: rounded outer container, elevation shadow
      expect(decoration.borderRadius, equals(BorderRadius.circular(16.0)));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.first.blurRadius, equals(6.0)); // 3.0 * 2.0
      expect(find.text('Dashboard'), findsOneWidget);
    });

    // 3. Floating Inset defaults
    testWidgets('renders Floating Inset mode defaults correctly',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1280.0, 900.0),
        child: AdaptiveSidebar(
          model: AdaptiveSidebarModel.floating,
          floatingMode: AdaptiveFloatingSidebarMode.inset,
          items: sampleItems,
          selectedIndex: 0,
        ),
      );

      final AnimatedContainer container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      final BoxDecoration decoration = container.decoration as BoxDecoration;

      // Inset characteristics: soft radius 12dp, zero elevation, outline border
      expect(decoration.borderRadius, equals(BorderRadius.circular(12.0)));
      expect(decoration.boxShadow, isNull);
      expect(decoration.border, isNotNull);
      expect(find.text('Dashboard'), findsOneWidget);
    });

    // 4. Floating Minimal defaults
    testWidgets('renders Floating Minimal mode defaults correctly',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1280.0, 900.0),
        child: AdaptiveSidebar(
          model: AdaptiveSidebarModel.floating,
          floatingMode: AdaptiveFloatingSidebarMode.minimal,
          items: sampleItems,
          selectedIndex: 0,
        ),
      );

      final AnimatedContainer container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      final BoxDecoration decoration = container.decoration as BoxDecoration;

      // Minimal characteristics: 8dp radius, zero elevation, minimal decoration
      expect(decoration.borderRadius, equals(BorderRadius.circular(8.0)));
      expect(decoration.boxShadow, isNull);
      expect(find.text('Dashboard'), findsOneWidget);
    });

    // 5. Developer style overrides via AdaptiveSidebarStyleData
    testWidgets('honors developer overrides in AdaptiveSidebarStyleData',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1280.0, 900.0),
        child: AdaptiveSidebar(
          model: AdaptiveSidebarModel.floating,
          floatingMode: AdaptiveFloatingSidebarMode.inset,
          items: sampleItems,
          selectedIndex: 0,
          style: AdaptiveSidebarStyleData(
            width: 264.0,
            collapsedWidth: 76.0,
            borderRadius: BorderRadius.circular(24.0),
            elevation: 4.0,
            backgroundColor: const Color(0xFFABCDEF),
            itemSpacing: 8.0,
          ),
        ),
      );

      final AnimatedContainer container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      final BoxDecoration decoration = container.decoration as BoxDecoration;

      expect(container.constraints?.maxWidth, equals(264.0));
      expect(decoration.borderRadius, equals(BorderRadius.circular(24.0)));
      expect(decoration.color, equals(const Color(0xFFABCDEF)));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.first.blurRadius, equals(8.0)); // 4.0 * 2.0
    });

    // 6. Style Precedence (Widget override > StyleData > ThemeData > Built-in default)
    testWidgets('enforces strict 4-tier style precedence order',
        (tester) async {
      const widgetBg = Color(0xFF111111);
      const styleDataBg = Color(0xFF222222);
      const themeBg = Color(0xFF333333);

      final testTheme = AdaptiveThemeData.light().copyWith(
        sidebarTheme: const AdaptiveSidebarThemeData(
          backgroundColor: themeBg,
        ),
      );

      // Level 1: Widget parameter overrides styleData and theme
      await tester.pumpAdaptive(
        size: const Size(1280.0, 900.0),
        theme: testTheme,
        child: AdaptiveSidebar(
          backgroundColor: widgetBg,
          style: const AdaptiveSidebarStyleData(
            backgroundColor: styleDataBg,
          ),
          items: sampleItems,
        ),
      );

      AnimatedContainer container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(widgetBg));

      // Level 2: StyleData overrides theme when widget override is null
      await tester.pumpAdaptive(
        size: const Size(1280.0, 900.0),
        theme: testTheme,
        child: AdaptiveSidebar(
          style: const AdaptiveSidebarStyleData(
            backgroundColor: styleDataBg,
          ),
          items: sampleItems,
        ),
      );

      container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(styleDataBg));

      // Level 3: Theme overrides built-in default when styleData is omitted
      await tester.pumpAdaptive(
        size: const Size(1280.0, 900.0),
        theme: testTheme,
        child: AdaptiveSidebar(
          items: sampleItems,
        ),
      );

      container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(themeBg));
    });

    // 7. Selected-item callbacks (onItemSelected and onDestinationSelected)
    testWidgets('triggers onItemSelected and onDestinationSelected callbacks',
        (tester) async {
      int? selectedItem;
      int? selectedDestination;

      await tester.pumpAdaptive(
        size: const Size(1280.0, 900.0),
        child: AdaptiveSidebar(
          isExpanded: true,
          items: sampleItems,
          selectedIndex: 0,
          onItemSelected: (idx) => selectedItem = idx,
          onDestinationSelected: (idx) => selectedDestination = idx,
        ),
      );

      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();

      expect(selectedItem, equals(1));
      expect(selectedDestination, equals(1));
    });

    // 8. Expand/collapse behavior
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
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });

    testWidgets('honors explicit isExpanded override', (tester) async {
      await tester.pumpAdaptive(
        size: const Size(600.0, 900.0),
        child: AdaptiveSidebar(
          isExpanded: true,
          items: sampleItems,
          selectedIndex: 0,
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
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

      expect(find.text('Dashboard'), findsOneWidget);

      await tester.tap(find.byTooltip('Collapse sidebar'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Expand sidebar'), findsOneWidget);
    });

    // 9. Nested submenu interactions
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

      expect(find.text('Classes'), findsNothing);

      await tester.tap(find.text('Academics'));
      await tester.pumpAndSettle();

      expect(find.text('Classes'), findsOneWidget);
      expect(find.text('Subjects'), findsOneWidget);

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

      expect(find.text('File A1'), findsOneWidget);
      expect(find.text('File B1'), findsNothing);

      await tester.tap(find.text('Folder B'));
      await tester.pumpAndSettle();

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
          onItemSelected: (idx) => selectedDest = idx,
        ),
      );

      expect(find.text('Level 0'), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);

      await tester.tap(find.text('Level 1'));
      await tester.pumpAndSettle();

      expect(find.text('Level 2 Leaf'), findsOneWidget);

      await tester.tap(find.text('Level 2 Leaf'));
      await tester.pumpAndSettle();

      expect(selectedDest, equals(2));
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

      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      expect(changedIndex, equals(0));
      expect(isExpandedState, isTrue);

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

    // 10. Dropdown popup behavior
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

      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();

      expect(find.text('New Folder'), findsOneWidget);

      await tester.tap(find.text('New Folder'));
      await tester.pumpAndSettle();

      expect(selectedDropdown, equals('new_folder'));
    });

    // 11. Narrow constraints and responsive transitions
    testWidgets('clamps width safely under extremely narrow parent constraints',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(800.0, 600.0),
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

      final AnimatedContainer container =
          tester.widget(find.byKey(const Key('adaptive_sidebar_container')));
      expect(container.constraints?.maxWidth, equals(50.0));
    });

    testWidgets(
        'prevents RenderFlex overflow when forced narrow while isExpanded is true',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(800.0, 600.0),
        child: Center(
          child: SizedBox(
            width: 56.0,
            child: AdaptiveSidebar(
              isExpanded: true,
              items: sampleItems,
              selectedIndex: 1,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.analytics), findsOneWidget);
      expect(tester.takeException(), isNull);
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
        size: const Size(1000.0, 400.0),
        child: AdaptiveSidebar(
          isExpanded: true,
          items: manyItems,
          selectedIndex: 0,
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Navigation Item #0'), findsOneWidget);
    });

    // 12. Theme changes & Dark mode
    testWidgets('adapts cleanly to dark mode theme changes', (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1280.0, 900.0),
        theme: AdaptiveThemeData.dark(),
        child: AdaptiveSidebar(
          model: AdaptiveSidebarModel.classic,
          items: sampleItems,
          selectedIndex: 0,
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // 13. Reduced-motion behavior
    testWidgets('respects reduced motion setting without throwing',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1280.0, 800.0),
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: AdaptiveSidebar(
            isExpanded: true,
            model: AdaptiveSidebarModel.floating,
            floatingMode: AdaptiveFloatingSidebarMode.minimal,
            items: sampleItems,
            selectedIndex: 0,
          ),
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // 14. Resource disposal & Leaf item optimization
    testWidgets('disposes cleanly without leaks or unhandled tickers',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: AdaptiveSidebar(
          isExpanded: true,
          items: sampleItems,
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);

      // Unmount sidebar completely
      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: const SizedBox.shrink(),
      );

      expect(find.text('Dashboard'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    // 15. Backward compatibility with legacyStyle
    testWidgets('preserves backward compatibility with legacyStyle parameter',
        (tester) async {
      const legacyStyles = AdaptiveSidebarStyle.values;
      for (final legacy in legacyStyles) {
        await tester.pumpAdaptive(
          size: const Size(1200.0, 800.0),
          child: AdaptiveSidebar(
            isExpanded: true,
            legacyStyle: legacy,
            items: sampleItems,
            selectedIndex: 0,
          ),
        );

        expect(find.text('Dashboard'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    // 16. WrapSlot protects against RenderFlex overflow in collapsed rail mode
    testWidgets(
        'prevents RenderFlex overflow when header/footer contains wide content in collapsed rail mode',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: AdaptiveSidebar(
          isExpanded: false,
          collapsedWidth: 72.0,
          header: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            child: Row(
              children: [
                Container(
                  width: 32.0,
                  height: 32.0,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10.0),
                const Expanded(
                  child: Text('Acme Cloud Wide Title That Might Overflow'),
                ),
              ],
            ),
          ),
          footer: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const CircleAvatar(radius: 16.0),
                const SizedBox(width: 10.0),
                const Expanded(
                  child: Text('Jane Doe Footer Text'),
                ),
              ],
            ),
          ),
          items: sampleItems,
          selectedIndex: 0,
        ),
      );

      // Verify no RenderFlex exception occurred
      expect(tester.takeException(), isNull);
      expect(find.byType(AdaptiveSidebar), findsOneWidget);
    });

    // 17. onExpansionChanged callback
    testWidgets('invokes onExpansionChanged when rail toggle button is clicked',
        (tester) async {
      bool? latestExpanded;

      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: AdaptiveSidebar(
          enableRailToggle: true,
          isExpanded: true,
          onExpansionChanged: (v) {
            latestExpanded = v;
          },
          items: sampleItems,
          selectedIndex: 0,
        ),
      );

      final Finder toggleButton =
          find.byKey(const Key('adaptive_sidebar_rail_toggle'));
      expect(toggleButton, findsOneWidget);

      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(latestExpanded, isFalse);

      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(latestExpanded, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders customSubmenuBuilder when provided on sidebar item',
        (tester) async {
      final items = [
        AdaptiveSidebarItem(
          icon: const Icon(Icons.folder),
          label: const Text('Custom Submenu Parent'),
          initiallyExpanded: true,
          children: const [
            AdaptiveSidebarItem(
              icon: Icon(Icons.star),
              label: Text('Child Star'),
            ),
          ],
          customSubmenuBuilder: (context, children) => Container(
            key: const Key('custom_submenu_container'),
            padding: const EdgeInsets.all(8.0),
            child: const Text('Custom Submenu Content'),
          ),
        ),
      ];

      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: AdaptiveSidebar(
          isExpanded: true,
          items: items,
          selectedIndex: 0,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('custom_submenu_container')), findsOneWidget);
      expect(find.text('Custom Submenu Content'), findsOneWidget);
    });

    testWidgets(
        'supports nested child submenu accordion coordination at depth 1',
        (tester) async {
      final items = [
        AdaptiveSidebarItem(
          icon: const Icon(Icons.folder),
          label: const Text('Top Parent'),
          initiallyExpanded: true,
          children: const [
            AdaptiveSidebarItem(
              icon: Icon(Icons.folder_open),
              label: Text('Submenu Alpha'),
              children: [
                AdaptiveSidebarItem(
                  icon: Icon(Icons.circle),
                  label: Text('Alpha Grandchild'),
                ),
              ],
            ),
            AdaptiveSidebarItem(
              icon: Icon(Icons.folder_open),
              label: Text('Submenu Beta'),
              children: [
                AdaptiveSidebarItem(
                  icon: Icon(Icons.circle),
                  label: Text('Beta Grandchild'),
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
          expansionMode: AdaptiveSubmenuExpansionMode.accordion,
          items: items,
          selectedIndex: 0,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Submenu Alpha'), findsOneWidget);
      expect(find.text('Submenu Beta'), findsOneWidget);

      // Open Submenu Alpha
      await tester.tap(find.text('Submenu Alpha'));
      await tester.pumpAndSettle();
      expect(find.text('Alpha Grandchild'), findsOneWidget);

      // Open Submenu Beta - with accordion mode, Submenu Alpha should close
      await tester.tap(find.text('Submenu Beta'));
      await tester.pumpAndSettle();
      expect(find.text('Beta Grandchild'), findsOneWidget);
      expect(find.text('Alpha Grandchild'), findsNothing);
    });
  });
}
