import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

class TestCounterWidget extends AdaptiveStatefulWidget {
  const TestCounterWidget({super.key});

  @override
  AdaptiveState<TestCounterWidget> createAdaptiveState() =>
      _TestCounterWidgetState();
}

class _TestCounterWidgetState extends AdaptiveState<TestCounterWidget> {
  int count = 0;

  @override
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout) {
    return Column(
      children: [
        Text('Count: $count on ${layout.containerBreakpoint.name}'),
        ElevatedButton(
          onPressed: () {
            setState(() {
              count++;
            });
          },
          child: const Text('Increment'),
        ),
      ],
    );
  }
}

void main() {
  group('AdaptiveStatefulWidget', () {
    testWidgets('preserves state and rebuilds on setState with layout snapshot',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        child: const TestCounterWidget(),
      );

      expect(find.text('Count: 0 on compact'), findsOneWidget);

      await tester.tap(find.text('Increment'));
      await tester.pump();

      expect(find.text('Count: 1 on compact'), findsOneWidget);
    });
  });
}
