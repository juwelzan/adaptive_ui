import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveBottomNavigationBar', () {
    final List<AdaptiveBottomNavigationDestination> sampleDestinations = [
      const AdaptiveBottomNavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
        tooltip: 'Home View',
      ),
      const AdaptiveBottomNavigationDestination(
        icon: Icon(Icons.search_outlined),
        selectedIcon: Icon(Icons.search),
        label: 'Search',
        badge: Text('3'),
      ),
      const AdaptiveBottomNavigationDestination(
        icon: Icon(Icons.person_outlined),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    testWidgets(
        'renders all destinations and displays active destination state',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(390.0, 844.0),
        child: AdaptiveBottomNavigationBar(
          destinations: sampleDestinations,
          selectedIndex: 0,
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('triggers onDestinationSelected callback on item tap',
        (tester) async {
      int selected = 0;

      await tester.pumpAdaptive(
        size: const Size(390.0, 844.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AdaptiveBottomNavigationBar(
              destinations: sampleDestinations,
              selectedIndex: selected,
              onDestinationSelected: (idx) {
                setState(() => selected = idx);
              },
            );
          },
        ),
      );

      expect(selected, equals(0));

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(selected, equals(1));
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('respects AdaptiveBottomNavLabelBehavior.onlyShowSelected',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(390.0, 844.0),
        child: AdaptiveBottomNavigationBar(
          destinations: sampleDestinations,
          selectedIndex: 1, // 'Search'
          labelBehavior: AdaptiveBottomNavLabelBehavior.onlyShowSelected,
        ),
      );

      // Selected label 'Search' is visible
      expect(find.text('Search'), findsOneWidget);
      // Unselected labels are not rendered visually
      expect(find.text('Home'), findsNothing);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('respects AdaptiveBottomNavLabelBehavior.neverShow',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(390.0, 844.0),
        child: AdaptiveBottomNavigationBar(
          destinations: sampleDestinations,
          selectedIndex: 0,
          labelBehavior: AdaptiveBottomNavLabelBehavior.neverShow,
        ),
      );

      // Visually no labels
      expect(find.text('Home'), findsNothing);
      expect(find.text('Search'), findsNothing);
      expect(find.text('Profile'), findsNothing);

      // But accessible via Semantics!
      expect(find.bySemanticsLabel('Home'), findsOneWidget);
    });

    testWidgets('guarantees accessible touch target dimensions (>= 48dp)',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        child: AdaptiveBottomNavigationBar(
          destinations: sampleDestinations,
          selectedIndex: 0,
        ),
      );

      final Finder inkResponses = find.byType(InkResponse);
      expect(inkResponses, findsNWidgets(3));

      for (final Element element in tester.elementList(inkResponses)) {
        final RenderBox renderBox = element.renderObject! as RenderBox;
        expect(renderBox.size.height, greaterThanOrEqualTo(48.0));
        expect(renderBox.size.width, greaterThanOrEqualTo(48.0));
      }
    });

    testWidgets('honors safe-area padding when useSafeArea is true',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(390.0, 844.0),
        viewPadding:
            const EdgeInsets.only(bottom: 34.0), // iPhone home indicator
        child: AdaptiveBottomNavigationBar(
          destinations: sampleDestinations,
          selectedIndex: 0,
          useSafeArea: true,
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    group('Design Styles Suite', () {
      for (final style in AdaptiveBottomNavigationStyle.values) {
        testWidgets('renders style ${style.name} without errors',
            (tester) async {
          await tester.pumpAdaptive(
            size: const Size(390.0, 844.0),
            child: AdaptiveBottomNavigationBar(
              destinations: sampleDestinations,
              selectedIndex: 1,
              style: style,
            ),
          );

          expect(find.byType(AdaptiveBottomNavigationBar), findsOneWidget);
          expect(find.text('Search'), findsOneWidget);
          expect(find.byIcon(Icons.search), findsOneWidget);
        });
      }

      testWidgets('pill style expands selected destination into capsule',
          (tester) async {
        await tester.pumpAdaptive(
          size: const Size(390.0, 844.0),
          child: AdaptiveBottomNavigationBar(
            destinations: sampleDestinations,
            selectedIndex: 0,
            style: AdaptiveBottomNavigationStyle.pill,
          ),
        );

        // Home is selected: shows label
        expect(find.text('Home'), findsOneWidget);
        // Pill capsule uses horizontal layout
        expect(find.byType(Row), findsWidgets);
      });

      testWidgets('glass style renders BackdropFilter for frosted surface',
          (tester) async {
        await tester.pumpAdaptive(
          size: const Size(390.0, 844.0),
          child: AdaptiveBottomNavigationBar(
            destinations: sampleDestinations,
            selectedIndex: 0,
            style: AdaptiveBottomNavigationStyle.glass,
            config: const AdaptiveBottomNavigationConfig(blurSigma: 16.0),
          ),
        );

        expect(find.byType(BackdropFilter), findsOneWidget);
      });

      testWidgets('floating style applies margin and rounded elevation',
          (tester) async {
        await tester.pumpAdaptive(
          size: const Size(390.0, 844.0),
          child: AdaptiveBottomNavigationBar(
            destinations: sampleDestinations,
            selectedIndex: 0,
            style: AdaptiveBottomNavigationStyle.floating,
            margin: const EdgeInsets.all(16.0),
          ),
        );

        expect(find.byType(Padding), findsWidgets);
        expect(find.byType(Material), findsWidgets);
      });

      testWidgets('minimal style displays flat design without elevation',
          (tester) async {
        await tester.pumpAdaptive(
          size: const Size(390.0, 844.0),
          child: AdaptiveBottomNavigationBar(
            destinations: sampleDestinations,
            selectedIndex: 0,
            style: AdaptiveBottomNavigationStyle.minimal,
          ),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(find.byIcon(Icons.home), findsOneWidget);
      });

      testWidgets(
          'classic style renders traditional icon and label presentation',
          (tester) async {
        await tester.pumpAdaptive(
          size: const Size(390.0, 844.0),
          child: AdaptiveBottomNavigationBar(
            destinations: sampleDestinations,
            selectedIndex: 2,
            style: AdaptiveBottomNavigationStyle.classic,
          ),
        );

        expect(find.text('Profile'), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('materialExpressive style renders stadium pill container',
          (tester) async {
        await tester.pumpAdaptive(
          size: const Size(390.0, 844.0),
          child: AdaptiveBottomNavigationBar(
            destinations: sampleDestinations,
            selectedIndex: 0,
            style: AdaptiveBottomNavigationStyle.materialExpressive,
          ),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(find.byIcon(Icons.home), findsOneWidget);
      });
    });

    group('Config & Customization', () {
      testWidgets('applies custom colors, indicator size, and typography',
          (tester) async {
        await tester.pumpAdaptive(
          size: const Size(390.0, 844.0),
          child: AdaptiveBottomNavigationBar(
            destinations: sampleDestinations,
            selectedIndex: 0,
            backgroundColor: Colors.black,
            selectedColor: Colors.amber,
            unselectedColor: Colors.grey,
            indicatorColor: Colors.amberAccent,
            config: const AdaptiveBottomNavigationConfig(
              height: 76.0,
              iconSize: 28.0,
              indicatorSize: Size(50.0, 28.0),
              selectedLabelStyle: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
        );

        final Text homeText = tester.widget(find.text('Home'));
        expect(homeText.style?.color, equals(Colors.amber));
      });
    });

    group('Item Counts and Stress Conditions', () {
      testWidgets('handles exactly 1 destination cleanly', (tester) async {
        await tester.pumpAdaptive(
          size: const Size(390.0, 844.0),
          child: AdaptiveBottomNavigationBar(
            destinations: [sampleDestinations.first],
            selectedIndex: 0,
          ),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('handles 2 destinations evenly', (tester) async {
        await tester.pumpAdaptive(
          size: const Size(390.0, 844.0),
          child: AdaptiveBottomNavigationBar(
            destinations: sampleDestinations.sublist(0, 2),
            selectedIndex: 0,
          ),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('handles 10 destinations with scroll policy', (tester) async {
        final List<AdaptiveBottomNavigationDestination> tenDestinations =
            List.generate(
          10,
          (i) => AdaptiveBottomNavigationDestination(
            icon: const Icon(Icons.star_outline),
            selectedIcon: const Icon(Icons.star),
            label: 'Item $i',
          ),
        );

        await tester.pumpAdaptive(
          size: const Size(390.0, 844.0),
          child: AdaptiveBottomNavigationBar(
            destinations: tenDestinations,
            selectedIndex: 0,
            overflowPolicy: AdaptiveBottomNavOverflowPolicy.scroll,
          ),
        );

        expect(find.byType(SingleChildScrollView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
          'handles 10 destinations with menu policy and opens More sheet',
          (tester) async {
        int selected = 0;
        final List<AdaptiveBottomNavigationDestination> tenDestinations =
            List.generate(
          10,
          (i) => AdaptiveBottomNavigationDestination(
            icon: const Icon(Icons.star_outline),
            selectedIcon: const Icon(Icons.star),
            label: 'Item $i',
          ),
        );

        await tester.pumpAdaptive(
          size: const Size(390.0, 844.0),
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (ctx, setState) {
                  return AdaptiveBottomNavigationBar(
                    destinations: tenDestinations,
                    selectedIndex: selected,
                    maxVisibleItems: 5,
                    overflowPolicy: AdaptiveBottomNavOverflowPolicy.menu,
                    onDestinationSelected: (idx) {
                      setState(() => selected = idx);
                    },
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('More'), findsOneWidget);

        // Tap 'More' to open sheet
        await tester.tap(find.text('More'));
        await tester.pumpAndSettle();

        // Check overflow items in sheet
        expect(find.text('Item 4'), findsOneWidget);
        expect(find.text('Item 9'), findsOneWidget);

        // Select an overflow item
        await tester.tap(find.text('Item 7'));
        await tester.pumpAndSettle();

        expect(selected, equals(7));
      });

      testWidgets(
          'handles narrow constraint (300dp) and 2.0x text scaling safely',
          (tester) async {
        await tester.pumpAdaptive(
          size: const Size(300.0, 600.0),
          textScaler: const TextScaler.linear(2.0),
          child: AdaptiveBottomNavigationBar(
            destinations: sampleDestinations,
            selectedIndex: 0,
            style: AdaptiveBottomNavigationStyle.minimal,
          ),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
