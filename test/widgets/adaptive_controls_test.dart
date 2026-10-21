import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Adaptive Controls & Touch Targets', () {
    testWidgets('AdaptiveButton provides >= 48dp height on compact screens',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        child: AdaptiveButton(
          onPressed: () {},
          child: const Text('Touch Action'),
        ),
      );

      final Size buttonSize = tester.getSize(find.byType(AdaptiveButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets(
        'AdaptiveButton expands to full width when fullWidthOnCompact is true',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        child: SizedBox(
          width: 320.0,
          child: AdaptiveButton(
            fullWidthOnCompact: true,
            onPressed: () {},
            child: const Text('Full Width'),
          ),
        ),
      );

      final Size buttonSize = tester.getSize(find.byType(AdaptiveButton));
      expect(buttonSize.width, equals(320.0));
    });

    testWidgets(
        'AdaptiveIconButton maintains minimum 48x48 bounds on compact screens',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        child: AdaptiveIconButton(
          icon: const Icon(Icons.favorite),
          onPressed: () {},
        ),
      );

      final Size buttonSize = tester.getSize(find.byType(AdaptiveIconButton));
      expect(buttonSize.width, greaterThanOrEqualTo(48.0));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));
    });
  });
}
