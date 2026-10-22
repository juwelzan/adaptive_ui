import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:adaptive_ui_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Adaptive UI Showcase Example App', () {
    testWidgets('pumps showcase app and renders default Dashboard tab',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AdaptiveShowcaseApp());
      await tester.pumpAndSettle();

      expect(find.textContaining('Adaptive UI Studio'), findsOneWidget);
      expect(find.text('Active Students'), findsOneWidget);
      expect(find.text('Department'), findsOneWidget);
      expect(find.text('142 Students'), findsOneWidget);
    });

    testWidgets('navigates between tabs and tests Rebuild Lab isolation',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AdaptiveShowcaseApp());
      await tester.pumpAndSettle();

      // Navigate to Rebuild Lab (Tab 1) via Icon
      await tester.tap(find.byIcon(Icons.bolt_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Granular Rebuild Verification Lab'), findsOneWidget);
      expect(find.text('Student Leaf: 142 students'), findsOneWidget);

      // Tap 'Update Students Only'
      await tester.tap(find.text('Update Students Only'));
      await tester.pumpAndSettle();

      // Student count should increment to 143
      expect(find.text('Student Leaf: 143 students'), findsOneWidget);
    });

    testWidgets('navigates to States tab and exercises state switcher',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AdaptiveShowcaseApp());
      await tester.pumpAndSettle();

      // Navigate to States (Tab 2) via Icon
      await tester.tap(find.byIcon(Icons.swap_horiz_outlined));
      await tester.pumpAndSettle();

      // Switch to EMPTY state
      await tester.tap(find.text('EMPTY'));
      await tester.pumpAndSettle();
      expect(find.text('No Active Enrollments'), findsOneWidget);

      // Switch to ERROR state
      await tester.tap(find.text('ERROR'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Connection timed out'), findsOneWidget);

      // Switch to LOADING state (contains animated skeletons)
      await tester.tap(find.text('LOADING'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AdaptiveSkeleton), findsWidgets);
    });

    testWidgets('navigates to Tokens tab and renders constrained layouts',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AdaptiveShowcaseApp());
      await tester.pumpAndSettle();

      // Navigate to Tokens (Tab 3) via Icon
      await tester.tap(find.byIcon(Icons.tune_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Tokens & Constrained Layouts'), findsOneWidget);
      expect(find.text('Nested AdaptiveTheme Scope'), findsOneWidget);
    });

    testWidgets('adapts navigation chrome on wide desktop viewport (>=840dp)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AdaptiveShowcaseApp());
      await tester.pumpAndSettle();

      // On wide display, AdaptiveScaffold uses NavigationRail
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets(
        'resilient against extreme window shrink/resize without overflow',
        (WidgetTester tester) async {
      // Squeeze viewport down to 320x568 (extreme narrow window)
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AdaptiveShowcaseApp());
      await tester.pumpAndSettle();

      // On narrow viewport, AdaptiveScaffold must safely use bottom NavigationBar
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      // Verify Add Student button renders without overflow
      expect(find.text('Add Student'), findsOneWidget);

      // Navigate to States tab and verify populated state with list tiles
      await tester.tap(find.byIcon(Icons.swap_horiz_outlined));
      await tester.pumpAndSettle();
      expect(find.text('POPULATED'), findsOneWidget);
    });

    testWidgets(
        'reproduce resize from desktop to narrow window while on States tab',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AdaptiveShowcaseApp());
      await tester.pumpAndSettle();

      // Navigate to States (Tab 2)
      await tester.tap(find.byIcon(Icons.swap_horiz_outlined));
      await tester.pumpAndSettle();

      // Now simulate a window resize down to narrow width
      tester.view.physicalSize = const Size(289.6, 600);
      await tester.pump();
    });

    testWidgets(
        'AdaptiveCubitListener.adaptive triggers responsive snackbar on state change',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AdaptiveShowcaseApp());
      await tester.pumpAndSettle();

      // Tap refresh action icon in AppBar to emit notification
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Verify snackbar emitted by AdaptiveCubitListener.adaptive
      expect(find.textContaining('Notification #6 received on compact view'),
          findsOneWidget);
    });

    testWidgets('navigates to Motion tab and exercises Phase 4 widgets',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AdaptiveShowcaseApp());
      await tester.pumpAndSettle();

      // Navigate to Motion tab via Icon
      await tester.tap(find.byIcon(Icons.auto_awesome_outlined));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1. AdaptiveText Motion & Marquee'), findsOneWidget);
      expect(find.text('2. AdaptiveContainer Implicit Animations'),
          findsOneWidget);

      // Verify container expansion toggle works
      expect(find.text('Expand'), findsOneWidget);
      await tester.tap(find.text('Expand'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Contract'), findsOneWidget);

      // Scroll down to reveal Section 3: Shimmer & Skeleton System
      await tester.drag(find.byType(AdaptiveScrollView), const Offset(0, -500));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('3. Shimmer & Skeleton System'), findsOneWidget);

      // Verify toggle button for loading state works
      expect(find.text('Loading: ON'), findsOneWidget);
      await tester.tap(find.text('Loading: ON'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Loading: OFF'), findsOneWidget);
      expect(find.text('Dr. Evelyn Vance'), findsOneWidget);

      // Scroll down to verify Sections 4 and 5
      await tester.drag(find.byType(AdaptiveScrollView), const Offset(0, -350));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('4. AdaptiveSidebar Navigation'), findsOneWidget);

      await tester.drag(find.byType(AdaptiveScrollView), const Offset(0, -350));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('5. AdaptiveBottomNavigationBar'), findsOneWidget);
    });

    testWidgets('navigates to Sidebar 2.0 tab and exercises studio features',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AdaptiveShowcaseApp());
      await tester.pumpAndSettle();

      // Navigate to Sidebar 2.0 tab
      await tester.tap(find.text('Sidebar 2.0'));
      await tester.pumpAndSettle();

      expect(find.text('AdaptiveSidebar 2.0 Studio'), findsOneWidget);

      // Verify style choice chip
      expect(find.text('Floating'), findsOneWidget);
      await tester.tap(find.text('Floating'));
      await tester.pumpAndSettle();

      // Scroll to reveal preview area
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // Verify nested submenus work inside showcase
      expect(find.text('Enrolled Courses'), findsNothing);
      await tester.tap(find.text('Academics'));
      await tester.pumpAndSettle();
      expect(find.text('Enrolled Courses'), findsOneWidget);

      // Select child destination
      await tester.tap(find.text('Enrolled Courses'));
      await tester.pumpAndSettle();

      // Scroll inside sidebar to reveal Action Tools
      await tester.drag(find.byType(AdaptiveSidebar), const Offset(0, -250));
      await tester.pumpAndSettle();

      // Verify dropdown action trigger
      expect(find.text('Action Tools'), findsOneWidget);
      await tester.tap(find.text('Action Tools'));
      await tester.pumpAndSettle();

      expect(find.text('New Workspace'), findsOneWidget);
      expect(find.text('Export Telemetry (CSV)'), findsOneWidget);
    });

    testWidgets(
        'navigates to Theme Studio tab and exercises theme engine controls',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AdaptiveShowcaseApp());
      await tester.pumpAndSettle();

      // Navigate to Theme Studio tab
      await tester.tap(find.text('Theme Studio'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Unified Theme Engine & Studio'), findsOneWidget);
      expect(find.text('Semantic Color Roles'), findsOneWidget);

      // Toggle Dark Theme
      await tester.tap(find.text('Light Theme'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Dark Theme'), findsOneWidget);

      // Toggle Component Overrides
      await tester.tap(find.text('Component Overrides'));
      await tester.pump(const Duration(milliseconds: 200));

      // Select Emerald Palette
      await tester.tap(find.text('Emerald'));
      await tester.pump(const Duration(milliseconds: 200));

      // Verify typography scale and tokens visible
      expect(find.text('Adaptive Typography Scale'), findsOneWidget);
      expect(find.text('Spacing, Radii & Elevation Tokens'), findsOneWidget);
    });

    testWidgets(
        'navigates to Forms tab and exercises Phase 6 form inputs & validation',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AdaptiveShowcaseApp());
      await tester.pumpAndSettle();

      // Navigate to Forms tab
      await tester.tap(find.text('Forms'));
      await tester.pumpAndSettle();

      expect(
          find.text('Phase 6: Adaptive Forms & Input System'), findsOneWidget);
      expect(find.text('Account & Professional Profile'), findsOneWidget);
      expect(find.text('Preferences & Project Constraints'), findsOneWidget);

      // Verify form submission validation error triggers
      await tester.tap(find.text('Validate & Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Full name is required'), findsOneWidget);

      // Fill in required text field
      await tester.enterText(
          find.widgetWithText(AdaptiveTextField, 'Full Name *'),
          'Ada Lovelace');
      await tester.pumpAndSettle();

      // Clear search field using clear button
      await tester.enterText(
          find.byType(AdaptiveSearchField).first, 'Quantum Computing');
      await tester.pump(const Duration(milliseconds: 400));
      expect(
          find.text('Active Search: "Quantum Computing" (Events debounced: 1)'),
          findsOneWidget);

      final clearFinder = find.byIcon(Icons.clear);
      if (clearFinder.evaluate().isNotEmpty) {
        await tester.tap(clearFinder);
        await tester.pump(const Duration(milliseconds: 400));
      }

      // Reset form
      await tester.ensureVisible(find.text('Reset Form'));
      await tester.tap(find.text('Reset Form'));
      await tester.pumpAndSettle();
      expect(find.text('Full name is required'), findsNothing);
    });

    testWidgets(
        'navigates to Layout tab and exercises Phase 9 layout system features',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AdaptiveShowcaseApp());
      await tester.pumpAndSettle();

      // Navigate to Layout tab
      await tester.tap(find.text('Layout'));
      await tester.pumpAndSettle();

      expect(find.text('Adaptive Layout Builder (Live Constraint Simulator)'),
          findsOneWidget);
      expect(find.byType(AdaptiveLayoutBuilder), findsWidgets);

      // Scroll ListView to reveal grid and row/column sections
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Responsive Grid System & Lazy Collections'),
          findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('AdaptiveRow & AdaptiveColumn with Wrapping'),
          findsOneWidget);
    });
  });
}
