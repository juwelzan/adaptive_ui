import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpDropdownApp(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('AdaptiveDropdown Component', () {
    testWidgets('renders trigger widget in idle state', (tester) async {
      await pumpDropdownApp(
        tester,
        AdaptiveDropdown<String>(
          trigger: const Text('Dropdown Trigger'),
          items: const [
            AdaptiveDropdownItem(value: 'opt1', label: Text('Option 1')),
          ],
        ),
      );

      expect(find.text('Dropdown Trigger'), findsOneWidget);
      expect(find.text('Option 1'), findsNothing);
    });

    testWidgets('tapping trigger opens dropdown menu with items',
        (tester) async {
      await pumpDropdownApp(
        tester,
        AdaptiveDropdown<String>(
          trigger: const Text('Open Menu'),
          items: const [
            AdaptiveDropdownItem(
              value: 'profile',
              label: Text('Profile Settings'),
              icon: Icon(Icons.person),
            ),
            AdaptiveDropdownItem(
              value: 'logout',
              label: Text('Sign Out'),
              icon: Icon(Icons.logout),
            ),
          ],
        ),
      );

      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();

      expect(find.text('Profile Settings'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('selecting item invokes onSelected and dismisses menu',
        (tester) async {
      String? selectedValue;

      await pumpDropdownApp(
        tester,
        AdaptiveDropdown<String>(
          trigger: const Text('Open Menu'),
          onSelected: (val) => selectedValue = val,
          items: const [
            AdaptiveDropdownItem(value: 'edit', label: Text('Edit Record')),
            AdaptiveDropdownItem(value: 'delete', label: Text('Delete Record')),
          ],
        ),
      );

      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit Record'));
      await tester.pumpAndSettle();

      expect(selectedValue, equals('edit'));
      // Menu dismissed
      expect(find.text('Delete Record'), findsNothing);
    });

    testWidgets('tapping outside barrier dismisses dropdown menu',
        (tester) async {
      await pumpDropdownApp(
        tester,
        AdaptiveDropdown<String>(
          trigger: const Text('Open Menu'),
          items: const [
            AdaptiveDropdownItem(value: 'a', label: Text('Alpha Option')),
          ],
        ),
      );

      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();
      expect(find.text('Alpha Option'), findsOneWidget);

      // Tap outside dropdown menu (top right of screen)
      await tester.tapAt(const Offset(700.0, 50.0));
      await tester.pumpAndSettle();

      expect(find.text('Alpha Option'), findsNothing);
    });

    testWidgets('pressing Escape key dismisses dropdown menu', (tester) async {
      await pumpDropdownApp(
        tester,
        AdaptiveDropdown<String>(
          trigger: const Text('Open Menu'),
          items: const [
            AdaptiveDropdownItem(value: 'a', label: Text('Beta Option')),
          ],
        ),
      );

      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();
      expect(find.text('Beta Option'), findsOneWidget);

      // Press Escape key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Beta Option'), findsNothing);
    });

    testWidgets('renders divider and respects disabled items', (tester) async {
      String? selected;

      await pumpDropdownApp(
        tester,
        AdaptiveDropdown<String>(
          trigger: const Text('Open Menu'),
          onSelected: (val) => selected = val,
          items: [
            const AdaptiveDropdownItem(value: 'active', label: Text('Active')),
            AdaptiveDropdownItem.divider(),
            const AdaptiveDropdownItem(
              value: 'disabled',
              label: Text('Disabled Action'),
              enabled: false,
            ),
          ],
        ),
      );

      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();

      expect(find.byType(Divider), findsOneWidget);
      expect(find.text('Disabled Action'), findsOneWidget);

      // Tap disabled item - should NOT select or dismiss
      await tester.tap(find.text('Disabled Action'));
      await tester.pumpAndSettle();

      expect(selected, isNull);
      expect(find.text('Active'), findsOneWidget); // Still open
    });

    testWidgets('disposing widget removes overlay entry safely',
        (tester) async {
      await pumpDropdownApp(
        tester,
        AdaptiveDropdown<String>(
          trigger: const Text('Open Menu'),
          items: const [
            AdaptiveDropdownItem(value: 'x', label: Text('Item X')),
          ],
        ),
      );

      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();
      expect(find.text('Item X'), findsOneWidget);

      // Pump empty widget tree to dispose AdaptiveDropdown while open
      await tester
          .pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      await tester.pumpAndSettle();

      expect(find.text('Item X'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
