import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

class TestStatelessWidget extends AdaptiveStatelessWidget {
  const TestStatelessWidget({super.key});

  @override
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout) {
    return Text('Rendered on ${layout.containerBreakpoint.name}');
  }
}

void main() {
  group('AdaptiveStatelessWidget', () {
    testWidgets('supplies resolved layout snapshot to buildAdaptive',
        (tester) async {
      // Compact size
      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        child: const TestStatelessWidget(),
      );
      expect(find.text('Rendered on compact'), findsOneWidget);

      // Expanded size
      await tester.pumpAdaptive(
        size: const Size(1024.0, 768.0),
        child: const TestStatelessWidget(),
      );
      expect(find.text('Rendered on expanded'), findsOneWidget);
    });
  });
}
