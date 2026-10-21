import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveBuilder', () {
    testWidgets(
        'yields accurate parent constraints inside constrained container',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(1200.0, 800.0),
        child: SizedBox(
          width: 400.0,
          child: AdaptiveBuilder(
            builder: (context, layout) {
              return Text(
                  'Width: ${layout.availableWidth.toInt()} BP: ${layout.containerBreakpoint.name}');
            },
          ),
        ),
      );

      // Parent container width 400 dp means compact container, despite 1200 dp screen
      expect(find.text('Width: 400 BP: compact'), findsOneWidget);
    });
  });
}
