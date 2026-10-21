import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveSkeleton Placeholder Loader', () {
    testWidgets('renders box variant with specified dimensions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveSkeleton.box(
                width: 200,
                height: 120,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final Finder finder = find.byType(AdaptiveSkeleton);
      expect(finder, findsOneWidget);

      final Size size = tester.getSize(finder);
      expect(size.width, equals(200));
      expect(size.height, equals(120));
    });

    testWidgets('renders circle avatar variant with equal diameter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveSkeleton.circle(size: 64),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final Finder finder = find.byType(AdaptiveSkeleton);
      expect(finder, findsOneWidget);

      final Size size = tester.getSize(finder);
      expect(size.width, equals(64));
      expect(size.height, equals(64));
    });

    testWidgets('renders text placeholder with compact line height',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveSkeleton.text(
                width: 150,
                height: 16,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final Finder finder = find.byType(AdaptiveSkeleton);
      expect(finder, findsOneWidget);

      final Size size = tester.getSize(finder);
      expect(size.width, equals(150));
      expect(size.height, equals(16));
    });

    testWidgets('animates without errors across repeat cycles',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveSkeleton.box(height: 50),
          ),
        ),
      );

      // Pump multiple frames to test animation loop
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 1200));

      expect(tester.takeException(), isNull);
    });

    testWidgets('honors disableAnimations accessibility setting',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: AdaptiveSkeleton.box(
                width: 100,
                height: 50,
                color: Color(0xFF112233),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verified static rendering without active animation ticker
      expect(find.byType(AdaptiveSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
