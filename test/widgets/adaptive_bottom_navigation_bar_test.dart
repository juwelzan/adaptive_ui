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

    testWidgets('renders all destinations and displays active destination state',
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
        viewPadding: const EdgeInsets.only(bottom: 34.0), // iPhone home indicator
        child: AdaptiveBottomNavigationBar(
          destinations: sampleDestinations,
          selectedIndex: 0,
          useSafeArea: true,
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
