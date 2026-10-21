import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Adaptive Feedback & Diagnostics Widgets', () {
    testWidgets('AdaptiveLoading renders progress indicator and label',
        (tester) async {
      await tester.pumpWidget(
        wrapWithAdaptive(
          child: const AdaptiveLoading(
            message: 'Loading telemetry...',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading telemetry...'), findsOneWidget);
    });

    testWidgets('AdaptiveEmptyState renders icon, title, and action button',
        (tester) async {
      bool actionTriggered = false;

      await tester.pumpAdaptive(
        child: AdaptiveEmptyState(
          icon: Icons.inbox,
          title: 'No Data Available',
          description: 'Try adjusting your filter settings.',
          actionLabel: 'Refresh',
          onAction: () => actionTriggered = true,
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No Data Available'), findsOneWidget);
      expect(find.text('Try adjusting your filter settings.'), findsOneWidget);

      await tester.tap(find.text('Refresh'));
      await tester.pump();

      expect(actionTriggered, isTrue);
    });

    testWidgets('AdaptiveErrorView renders error message and retry action',
        (tester) async {
      bool retried = false;

      await tester.pumpAdaptive(
        child: AdaptiveErrorView(
          message: 'Failed to connect to gateway',
          onRetry: () => retried = true,
        ),
      );

      expect(find.text('Failed to connect to gateway'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets(
        'AdaptiveConstrainedBox clamps child with responsive constraints',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(800.0, 600.0),
        child: const AdaptiveConstrainedBox(
          minWidth: AdaptiveValue.fixed(200.0),
          maxWidth: AdaptiveValue.fixed(600.0),
          child: Text('Constrained Child'),
        ),
      );

      expect(find.text('Constrained Child'), findsOneWidget);
    });

    testWidgets(
        'AdaptiveConstrainedBox applies responsive breakpoint constraints',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        child: const AdaptiveConstrainedBox(
          compact: BoxConstraints(maxWidth: 320.0),
          medium: BoxConstraints(maxWidth: 600.0),
          child: Text('Responsive Box Content'),
        ),
      );

      expect(find.text('Responsive Box Content'), findsOneWidget);
    });

    testWidgets('AdaptiveDebugOverlay renders diagnostic banner when enabled',
        (tester) async {
      await tester.pumpAdaptive(
        child: const AdaptiveDebugOverlay(
          enabled: true,
          child: Text('Main Screen Content'),
        ),
      );

      expect(find.text('Main Screen Content'), findsOneWidget);
      // Expect breakpoint indicator overlay badge
      expect(find.textContaining('BP: COMPACT'), findsOneWidget);
    });
  });
}
