import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

class ResponsiveTestDashboard extends AdaptiveStatelessWidget {
  const ResponsiveTestDashboard({super.key});

  @override
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout) {
    final int dynamicColumns = AdaptiveEngine.calculateColumns(
      layout.availableWidth,
      minItemWidth: 100.0,
      spacing: 16.0,
    );

    return AdaptiveScrollView(
      child: AdaptiveColumn(
        children: [
          Text(
            'Breakpoint: ${layout.containerBreakpoint.name}',
            key: const ValueKey('bp_text'),
          ),
          Text(
            'Orientation: ${layout.isLandscape ? "landscape" : "portrait"}',
            key: const ValueKey('orient_text'),
          ),
          Text(
            'Columns: $dynamicColumns',
            key: const ValueKey('cols_text'),
          ),
          Text(
            'Keyboard: ${layout.isKeyboardVisible ? "open" : "closed"}',
            key: const ValueKey('keyboard_text'),
          ),
          AdaptiveContainer(
            width: AdaptiveValue<double>.breakpoint(
              fallback: 280.0,
              compact: 280.0,
              medium: 600.0,
              expanded: 900.0,
            ),
            child: const Text('Constrained Content'),
          ),
          AdaptiveRow(
            children: const [
              AdaptiveExpanded(child: Text('Col A')),
              AdaptiveExpanded(child: Text('Col B')),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  group('Adaptive Layout Multi-Viewport & Environmental Adaptations', () {
    testWidgets('Resolves correctly on Narrow Viewport (320x568)',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(320.0, 568.0),
        child: const ResponsiveTestDashboard(),
      );

      expect(find.text('Breakpoint: compact'), findsOneWidget);
      expect(find.text('Orientation: portrait'), findsOneWidget);
      expect(find.text('Columns: 2'), findsOneWidget);
      expect(find.text('Keyboard: closed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Resolves correctly on Standard Mobile Viewport (390x844)',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(390.0, 844.0),
        child: const ResponsiveTestDashboard(),
      );

      expect(find.text('Breakpoint: compact'), findsOneWidget);
      expect(find.text('Orientation: portrait'), findsOneWidget);
      expect(find.text('Columns: 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Resolves correctly on Tablet Viewport (768x1024)',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(768.0, 1024.0),
        child: const ResponsiveTestDashboard(),
      );

      expect(find.text('Breakpoint: medium'), findsOneWidget);
      expect(find.text('Orientation: portrait'), findsOneWidget);
      expect(find.text('Columns: 6'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Resolves correctly on Desktop Viewport (1440x900)',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1440.0, 900.0),
        child: const ResponsiveTestDashboard(),
      );

      expect(find.text('Breakpoint: large'), findsOneWidget);
      expect(find.text('Orientation: landscape'), findsOneWidget);
      expect(find.text('Columns: 12'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Resolves correctly on Landscape Mobile Viewport (844x390)',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(844.0, 390.0),
        child: const ResponsiveTestDashboard(),
      );

      expect(find.text('Orientation: landscape'), findsOneWidget);
      expect(find.text('Breakpoint: expanded'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Handles Large Accessibility Text Scale (2.0x) without overflow',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        textScaler: const TextScaler.linear(2.0),
        child: const ResponsiveTestDashboard(),
      );

      expect(find.text('Breakpoint: compact'), findsOneWidget);
      expect(find.text('Constrained Content'), findsOneWidget);
      // No RenderFlex overflow exception
      expect(tester.takeException(), isNull);
    });

    testWidgets('Detects Keyboard insets properly', (tester) async {
      await tester.pumpAdaptive(
        size: const Size(390.0, 844.0),
        viewInsets: const EdgeInsets.only(bottom: 300.0),
        child: const ResponsiveTestDashboard(),
      );

      expect(find.text('Keyboard: open'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
