import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveCard Constraint Resilience', () {
    testWidgets(
        'renders normally with custom padding, radius, and elevation under standard width',
        (WidgetTester tester) async {
      await tester.pumpAdaptive(
        size: const Size(400.0, 600.0),
        child: const AdaptiveCard(
          elevation: 2.0,
          child: Text('Standard Card Content'),
        ),
      );

      expect(find.text('Standard Card Content'), findsOneWidget);
      expect(find.byType(AdaptiveCard), findsOneWidget);
    });

    testWidgets(
        'preserves ListTile without constraint failure under extremely narrow constraints (w=0.6)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 0.6,
                child: AdaptiveCard(
                  child: ListTile(
                    leading: const CircleAvatar(child: Text('1')),
                    title: const Text('Student Record #1000'),
                    subtitle:
                        const Text('Enrolled in Advanced Flutter Engineering'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify no assertion error or exception occurred during layout
      expect(find.byType(AdaptiveCard), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets(
        'preserves ListTile without constraint failure under 39.0dp width',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 39.0,
                child: AdaptiveCard(
                  child: ListTile(
                    leading: const CircleAvatar(child: Text('1')),
                    title: const Text('Title'),
                    subtitle: const Text('Subtitle'),
                    trailing: const Icon(Icons.arrow_forward),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AdaptiveCard), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}
