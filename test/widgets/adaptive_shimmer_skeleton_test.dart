import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveShimmer & Skeleton Loading Suite', () {
    testWidgets('AdaptiveShimmer renders ShaderMask and animates',
        (tester) async {
      await tester.pumpWidget(
        wrapWithAdaptive(
          child: const AdaptiveShimmer(
            child: Text('Shimmering text'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(ShaderMask), findsOneWidget);
      expect(find.text('Shimmering text'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('AdaptiveShimmer respects disableAnimations preference',
        (tester) async {
      await tester.pumpWidget(
        wrapWithAdaptive(
          child: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: AdaptiveShimmer(
              child: Text('Static fallback'),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Bypasses ShaderMask when animations disabled
      expect(find.byType(ShaderMask), findsNothing);
      expect(find.text('Static fallback'), findsOneWidget);
    });

    testWidgets(
        'AdaptiveSkeleton switcher toggles between placeholder and child content',
        (tester) async {
      bool isLoading = true;

      await tester.pumpWidget(
        wrapWithAdaptive(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  AdaptiveSkeleton(
                    loading: isLoading,
                    placeholder: const Text('Loading Placeholder...'),
                    child: const Text('Real Profile Content'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => isLoading = false),
                    child: const Text('Loaded'),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // While loading is true
      expect(find.text('Loading Placeholder...'), findsOneWidget);

      // Switch to loaded
      await tester.tap(find.text('Loaded'));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Real Profile Content'), findsOneWidget);
    });

    testWidgets(
        'AdaptiveSkeletonText renders requested lines with shortened last line',
        (tester) async {
      await tester.pumpWidget(
        wrapWithAdaptive(
          size: const Size(400.0, 600.0),
          child: const AdaptiveSkeletonText(
            lines: 3,
            lineHeight: 16.0,
            spacing: 8.0,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      final Finder skeletons = find.byType(AdaptiveSkeleton);
      expect(skeletons, findsNWidgets(3));
    });

    testWidgets(
        'AdaptiveSkeletonContainer renders container with padding and radius',
        (tester) async {
      await tester.pumpWidget(
        wrapWithAdaptive(
          child: const AdaptiveSkeletonContainer(
            width: 250.0,
            height: 120.0,
            child: Text('Inside Skeleton Card'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Inside Skeleton Card'), findsOneWidget);
      final Container container = tester.widget(find.byType(Container).first);
      expect(container.constraints?.maxWidth, equals(250.0));
    });

    testWidgets(
        'AdaptiveSkeletonList renders requested number of placeholder items',
        (tester) async {
      await tester.pumpWidget(
        wrapWithAdaptive(
          size: const Size(400.0, 800.0),
          child: const AdaptiveSkeletonList(
            itemCount: 4,
            spacing: 10.0,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(AdaptiveSkeletonContainer), findsNWidgets(4));
    });
  });
}
