import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveContainer Animations', () {
    testWidgets('animates decoration changes smoothly when animateChanges is true',
        (tester) async {
      Color currentColor = Colors.blue;

      await tester.pumpAdaptive(
        size: const Size(600.0, 400.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                AdaptiveContainer(
                  animateChanges: true,
                  animationDuration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: currentColor,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: const Text('Animated Box'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => currentColor = Colors.red),
                  child: const Text('Change Color'),
                ),
              ],
            );
          },
        ),
      );

      expect(find.byType(AnimatedContainer), findsOneWidget);
      expect(find.text('Animated Box'), findsOneWidget);

      // Tap button to change color
      await tester.tap(find.text('Change Color'));
      await tester.pump();

      // Mid-transition
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(AnimatedContainer), findsOneWidget);

      // Finish transition
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Animated Box'), findsOneWidget);
    });

    testWidgets('preserves child state when container visual properties change',
        (tester) async {
      double containerWidth = 200.0;

      await tester.pumpAdaptive(
        size: const Size(600.0, 400.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                AdaptiveContainer(
                  animateChanges: true,
                  width: AdaptiveValue.fixed(containerWidth),
                  child: const _StatefulCounterChild(),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => containerWidth = 350.0),
                  child: const Text('Resize Container'),
                ),
              ],
            );
          },
        ),
      );

      expect(find.text('Child Counter: 0'), findsOneWidget);

      // Increment child internal state
      await tester.tap(find.text('Increment Child'));
      await tester.pumpAndSettle();
      expect(find.text('Child Counter: 1'), findsOneWidget);

      // Trigger container resize
      await tester.tap(find.text('Resize Container'));
      await tester.pumpAndSettle();

      // Child state must be preserved at 1!
      expect(find.text('Child Counter: 1'), findsOneWidget);
    });

    testWidgets('respects reduced motion by skipping animations',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(600.0, 400.0),
        child: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: AdaptiveContainer(
            animateChanges: true,
            decoration: BoxDecoration(color: Colors.green),
            child: Text('Reduced Motion Box'),
          ),
        ),
      );

      // When reduced motion is active, AnimatedContainer is bypassed
      expect(find.byType(AnimatedContainer), findsNothing);
      expect(find.text('Reduced Motion Box'), findsOneWidget);
    });

    testWidgets('handles tap and hover interactions cleanly',
        (tester) async {
      bool tapped = false;
      bool hovered = false;

      await tester.pumpAdaptive(
        size: const Size(600.0, 400.0),
        child: AdaptiveContainer(
          onTap: () => tapped = true,
          onHover: (val) => hovered = val,
          hoverDecoration: const BoxDecoration(color: Colors.amber),
          child: const Text('Interactive Card'),
        ),
      );

      expect(find.text('Interactive Card'), findsOneWidget);
      expect(tapped, isFalse);

      await tester.tap(find.text('Interactive Card'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}

class _StatefulCounterChild extends StatefulWidget {
  const _StatefulCounterChild();

  @override
  State<_StatefulCounterChild> createState() => _StatefulCounterChildState();
}

class _StatefulCounterChildState extends State<_StatefulCounterChild> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Child Counter: $count'),
        ElevatedButton(
          onPressed: () => setState(() => count++),
          child: const Text('Increment Child'),
        ),
      ],
    );
  }
}
