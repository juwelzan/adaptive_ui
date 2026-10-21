import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveScaffold Multi-Viewport Navigation', () {
    const List<AdaptiveNavigationDestination> destinations =
        <AdaptiveNavigationDestination>[
      AdaptiveNavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      AdaptiveNavigationDestination(
        icon: Icon(Icons.analytics_outlined),
        selectedIcon: Icon(Icons.analytics),
        label: 'Analytics',
      ),
      AdaptiveNavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    testWidgets('renders bottom NavigationBar on compact viewport (<600dp)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      int selected = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveScaffold(
            selectedIndex: selected,
            onDestinationSelected: (int idx) => selected = idx,
            destinations: destinations,
            body: const Center(child: Text('Main Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // NavigationBar should exist
      expect(find.byType(NavigationBar), findsOneWidget);
      // NavigationRail should NOT exist
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('Main Content'), findsOneWidget);

      // Tap second destination
      await tester.tap(find.text('Analytics'));
      await tester.pump();
      expect(selected, equals(1));
    });

    testWidgets(
        'renders collapsed NavigationRail on medium viewport (600-839dp)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(700, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveScaffold(
            selectedIndex: 0,
            destinations: destinations,
            body: const Center(child: Text('Medium Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // NavigationRail should exist and not be extended
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      final NavigationRail rail = tester.widget(find.byType(NavigationRail));
      expect(rail.extended, isFalse);
      expect(find.text('Medium Content'), findsOneWidget);
    });

    testWidgets(
        'renders extended NavigationRail on expanded/large viewport (>=840dp)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveScaffold(
            selectedIndex: 1,
            destinations: destinations,
            body: const Center(child: Text('Desktop Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // NavigationRail should exist and be extended
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      final NavigationRail rail = tester.widget(find.byType(NavigationRail));
      expect(rail.extended, isTrue);
      expect(rail.selectedIndex, equals(1));
      expect(find.text('Desktop Content'), findsOneWidget);
    });

    testWidgets('respects explicit navigationType overrides',
        (WidgetTester tester) async {
      // Even on a large 1200dp screen, force bottom NavigationBar
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveScaffold(
            navigationType: AdaptiveNavigationType.bottom,
            selectedIndex: 0,
            destinations: destinations,
            body: const Center(child: Text('Overridden Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('renders Drawer when navigationType is drawer',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveScaffold(
            navigationType: AdaptiveNavigationType.drawer,
            appBar: AppBar(title: const Text('Title')),
            destinations: destinations,
            body: const Center(child: Text('Drawer Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open drawer via Scaffold
      final ScaffoldState state = tester.state(find.byType(Scaffold));
      state.openDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('renders plain Scaffold when destinations is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveScaffold(
            destinations: <AdaptiveNavigationDestination>[],
            body: Center(child: Text('No Destinations')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('No Destinations'), findsOneWidget);
    });

    testWidgets(
        'reproduces ListTile constraint failure under extremely narrow rail container',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Material(
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 0.6,
                child: ListTile(
                  leading: CircleAvatar(child: Text('1')),
                  title: Text('Title'),
                ),
              ),
            ),
          ),
        ),
      );
    });
  });
}
