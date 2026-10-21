import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdaptiveText Animations & Marquee', () {
    testWidgets(
        'short text remains static by default (AdaptiveTextAnimation.none)',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(400.0, 600.0),
        child: const AdaptiveText('Short Title'),
      );

      expect(find.text('Short Title'), findsOneWidget);
      // No ClipRect or AnimatedBuilder used for static text
      expect(find.byType(ClipRect), findsNothing);
    });

    testWidgets('short text does NOT marquee when it fits within constraints',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(800.0, 600.0),
        child: const SizedBox(
          width: 500.0,
          child: AdaptiveText(
            'Fits easily',
            autoScroll: true,
          ),
        ),
      );

      expect(find.text('Fits easily'), findsOneWidget);
      // Because it fits, no marquee translation ClipRect is rendered
      expect(find.byType(ClipRect), findsNothing);
    });

    testWidgets('overflowing text activates marquee when enabled',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(400.0, 600.0),
        child: const SizedBox(
          width: 100.0,
          child: AdaptiveText(
            'A very long university research institution name that overflows',
            animation: AdaptiveTextAnimation.marquee,
            startDelay: Duration.zero,
            pauseDuration: Duration.zero,
          ),
        ),
      );

      // ClipRect is inserted for marquee
      expect(find.byType(ClipRect), findsOneWidget);

      // Verify that marquee renders the text
      expect(find.textContaining('A very long university'), findsWidgets);

      // Pump a frame to advance marquee animation
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ClipRect), findsOneWidget);
    });

    testWidgets('fadeIn animation renders and completes without errors',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(400.0, 600.0),
        child: const AdaptiveText(
          'Fading in',
          animation: AdaptiveTextAnimation.fadeIn,
          animationDuration: Duration(milliseconds: 300),
        ),
      );

      expect(find.byType(FadeTransition), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Fading in'), findsOneWidget);
    });

    testWidgets('slideIn animation renders SlideTransition and FadeTransition',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(400.0, 600.0),
        child: const AdaptiveText(
          'Sliding in',
          animation: AdaptiveTextAnimation.slideIn,
          animationDuration: Duration(milliseconds: 300),
        ),
      );

      expect(find.byType(SlideTransition), findsOneWidget);
      expect(find.byType(FadeTransition), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Sliding in'), findsOneWidget);
    });

    testWidgets('typewriter animation reveals characters incrementally',
        (tester) async {
      await tester.pumpWidget(
        wrapWithAdaptive(
          size: const Size(400.0, 600.0),
          child: const AdaptiveText(
            'Hello World',
            animation: AdaptiveTextAnimation.typewriter,
            animationDuration: Duration(milliseconds: 500),
          ),
        ),
      );
      // First frame
      await tester.pump();

      // At start, 0 chars revealed
      expect(find.text(''), findsOneWidget);

      // Advance halfway (250ms of 500ms -> ~5-6 chars: 'Hello')
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.textContaining('Hello'), findsOneWidget);

      // Complete remainder
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('disables animations when MediaQuery.disableAnimations is true',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(400.0, 600.0),
        child: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: AdaptiveText(
            'Reduced Motion Text',
            animation: AdaptiveTextAnimation.fadeIn,
          ),
        ),
      );

      // Renders text directly without FadeTransition wrapper
      expect(find.text('Reduced Motion Text'), findsOneWidget);
      expect(find.byType(FadeTransition), findsNothing);
    });

    testWidgets('cleans up animation controllers and timers cleanly on unmount',
        (tester) async {
      await tester.pumpWidget(
        wrapWithAdaptive(
          size: const Size(400.0, 600.0),
          child: const SizedBox(
            width: 80.0,
            child: AdaptiveText(
              'Long unmounting marquee text',
              animation: AdaptiveTextAnimation.marquee,
              startDelay: Duration.zero,
            ),
          ),
        ),
      );
      await tester.pump();

      // Advance a bit
      await tester.pump(const Duration(milliseconds: 100));

      // Unmount
      await tester.pumpWidget(
        wrapWithAdaptive(child: const SizedBox.shrink()),
      );
      await tester.pump(const Duration(seconds: 1));

      // Verified no dangling timers or unhandled exceptions
      expect(find.byType(AdaptiveText), findsNothing);
    });
  });
}
