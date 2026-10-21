import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveTheme & Design Token Resolution', () {
    testWidgets('Default theme tokens are provided when no theme specified',
        (tester) async {
      late AdaptiveThemeData capturedTheme;

      await tester.pumpAdaptive(
        child: Builder(
          builder: (context) {
            capturedTheme = AdaptiveTheme.of(context);
            return Text('Spacing SM: ${capturedTheme.spacing.sm}');
          },
        ),
      );

      expect(find.text('Spacing SM: 8.0'), findsOneWidget);
      expect(capturedTheme.radii.md, equals(12.0));
      expect(capturedTheme.sizing.touchTargetMin, equals(48.0));
    });

    testWidgets('Custom theme tokens override defaults across the subtree',
        (tester) async {
      const customTheme = AdaptiveThemeData(
        spacing: AdaptiveSpacing(sm: 10.0, md: 20.0, lg: 30.0),
        radii: AdaptiveRadii(sm: 6.0, md: 16.0, lg: 28.0),
      );

      await tester.pumpAdaptive(
        theme: customTheme,
        child: Builder(
          builder: (context) {
            final theme = AdaptiveTheme.of(context);
            return Column(
              children: [
                Text('Custom Spacing MD: ${theme.spacing.md}'),
                Text('Custom Radii MD: ${theme.radii.md}'),
              ],
            );
          },
        ),
      );

      expect(find.text('Custom Spacing MD: 20.0'), findsOneWidget);
      expect(find.text('Custom Radii MD: 16.0'), findsOneWidget);
    });

    testWidgets('AdaptiveTheme widget provides nested local override',
        (tester) async {
      await tester.pumpAdaptive(
        child: Column(
          children: [
            Builder(
              builder: (ctx) =>
                  Text('Root Spacing SM: ${AdaptiveTheme.of(ctx).spacing.sm}'),
            ),
            AdaptiveTheme(
              data: const AdaptiveThemeData(
                spacing: AdaptiveSpacing(sm: 14.0),
              ),
              child: Builder(
                builder: (ctx) => Text(
                    'Local Spacing SM: ${AdaptiveTheme.of(ctx).spacing.sm}'),
              ),
            ),
          ],
        ),
      );

      expect(find.text('Root Spacing SM: 8.0'), findsOneWidget);
      expect(find.text('Local Spacing SM: 14.0'), findsOneWidget);
    });
  });
}
