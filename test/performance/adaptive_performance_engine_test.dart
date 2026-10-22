import 'dart:ui';

import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _StatefulCounter extends StatefulWidget {
  const _StatefulCounter();

  @override
  State<_StatefulCounter> createState() => _StatefulCounterState();
}

class _StatefulCounterState extends State<_StatefulCounter> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: $count'),
        ElevatedButton(
          onPressed: () => setState(() => count++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}

void main() {
  group('Phase 8 — Performance Engine & Intelligent Rendering Tests', () {
    group('AdaptiveShimmer Animation Lifecycle & Reduced Motion', () {
      testWidgets('shimmer ticker halts when reduced motion is preferred',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: true),
              child: AdaptiveShimmer(
                child: SizedBox(width: 100, height: 20),
              ),
            ),
          ),
        );
        await tester.pump();

        // Shimmer widget is rendered as static child without scheduling continuous ticks
        expect(tester.binding.hasScheduledFrame, isFalse);
        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets(
          'shimmer dynamically halts animation ticker when reduced motion changes',
          (WidgetTester tester) async {
        bool reducedMotion = false;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return MaterialApp(
                home: MediaQuery(
                  data: MediaQueryData(disableAnimations: reducedMotion),
                  child: Scaffold(
                    body: Column(
                      children: [
                        const AdaptiveShimmer(
                          child: SizedBox(width: 120, height: 24),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              setState(() => reducedMotion = !reducedMotion),
                          child: const Text('Toggle Motion'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
        await tester.pump();

        // Initially reduced motion is false, shader mask is present
        expect(find.byType(ShaderMask), findsOneWidget);

        // Toggle reduced motion to true
        await tester.tap(find.text('Toggle Motion'));
        await tester.pumpAndSettle();

        // ShaderMask should be bypassed and no frames scheduled
        expect(find.byType(ShaderMask), findsNothing);
        expect(tester.binding.hasScheduledFrame, isFalse);
      });
    });

    group('AdaptiveSkeleton Resource Lifecycle', () {
      testWidgets('skeleton stops ticker when animations are disabled',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: true),
              child: AdaptiveSkeleton.box(width: 150, height: 30),
            ),
          ),
        );
        await tester.pump();

        expect(tester.binding.hasScheduledFrame, isFalse);
        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('skeleton cleans up controller when switching to child mode',
          (WidgetTester tester) async {
        bool isLoading = true;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return MaterialApp(
                home: Scaffold(
                  body: Column(
                    children: [
                      AdaptiveSkeleton(
                        loading: isLoading,
                        placeholder: const AdaptiveSkeleton.box(
                          width: 100,
                          height: 20,
                        ),
                        child: const Text('Loaded Data'),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() => isLoading = !isLoading),
                        child: const Text('Toggle Loading'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
        await tester.pump();

        expect(find.byType(AnimatedCrossFade), findsOneWidget);

        await tester.tap(find.text('Toggle Loading'));
        await tester.pumpAndSettle();

        expect(find.text('Loaded Data'), findsOneWidget);
      });
    });

    group('AdaptiveText Rebuilds & Resource Cleanup', () {
      testWidgets('marquee stops timers and tickers under reduced motion',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: true),
              child: Center(
                child: SizedBox(
                  width: 60,
                  child: AdaptiveText(
                    'Extremely long text that overflows container width',
                    animation: AdaptiveTextAnimation.marquee,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Under reduced motion, no AnimatedBuilder or timers are started inside AdaptiveText
        expect(
          find.descendant(
            of: find.byType(AdaptiveText),
            matching: find.byType(AnimatedBuilder),
          ),
          findsNothing,
        );
        expect(find.byType(ClipRect), findsNothing);
        expect(tester.binding.hasScheduledFrame, isFalse);
      });

      testWidgets('marquee caches child and animates smoothly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Center(
              child: SizedBox(
                width: 80,
                child: AdaptiveText(
                  'A very long university research institution name that overflows',
                  animation: AdaptiveTextAnimation.marquee,
                  startDelay: Duration.zero,
                  pauseDuration: Duration.zero,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(ClipRect), findsOneWidget);
        expect(find.byType(OverflowBox), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(ClipRect), findsOneWidget);
      });
    });

    group('AdaptiveScaffold Body State Preservation', () {
      testWidgets(
          'preserves body state across compact-to-expanded viewport resize',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        const destinations = [
          AdaptiveNavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          AdaptiveNavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ];

        await tester.pumpWidget(
          const MaterialApp(
            home: AdaptiveScaffold(
              destinations: destinations,
              body: _StatefulCounter(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Counter: 0'), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);

        // Increment state in body
        await tester.tap(find.text('Increment'));
        await tester.pump();
        expect(find.text('Counter: 1'), findsOneWidget);

        await tester.tap(find.text('Increment'));
        await tester.pump();
        expect(find.text('Counter: 2'), findsOneWidget);

        // Dynamically resize screen to desktop/tablet size (>=840dp)
        tester.view.physicalSize = const Size(900, 800);
        await tester.pumpAndSettle();

        // Should now be extended NavigationRail
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);

        // CRITICAL CHECK: Body counter state MUST BE PRESERVED!
        expect(find.text('Counter: 2'), findsOneWidget);

        // Resize back to compact mobile size (<600dp)
        tester.view.physicalSize = const Size(380, 800);
        await tester.pumpAndSettle();

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);

        // Still preserved!
        expect(find.text('Counter: 2'), findsOneWidget);
      });
    });

    group('AdaptiveBottomNavPainter Animation Dynamics & shouldRepaint', () {
      test('evaluates dynamic animation.value when progress is omitted', () {
        final controller = AnimationController(
          vsync: const TestVSync(),
          duration: const Duration(milliseconds: 300),
        );
        addTearDown(controller.dispose);

        final curved =
            CurvedAnimation(parent: controller, curve: Curves.linear);
        addTearDown(curved.dispose);

        final painter = AdaptiveBottomNavPainter(
          repaint: curved,
          animation: curved,
          style: AdaptiveBottomNavigationStyle.pillMotion,
          previousIndex: 0,
          currentIndex: 2,
          itemCount: 4,
          indicatorColor: Colors.blue,
          selectedColor: Colors.white,
          unselectedColor: Colors.grey,
          backgroundColor: Colors.black,
          textDirection: TextDirection.ltr,
        );

        controller.value = 0.0;
        expect(painter.progress, equals(0.0));

        controller.value = 0.65;
        expect(painter.progress, equals(0.65));

        controller.value = 1.0;
        expect(painter.progress, equals(1.0));
      });

      test('shouldRepaint returns true when animation/progress changes', () {
        final anim1 = AlwaysStoppedAnimation(0.2);
        final anim2 = AlwaysStoppedAnimation(0.8);

        final painter1 = AdaptiveBottomNavPainter(
          repaint: anim1,
          progress: 0.2,
          style: AdaptiveBottomNavigationStyle.wave,
          previousIndex: 0,
          currentIndex: 1,
          itemCount: 3,
          indicatorColor: Colors.blue,
          selectedColor: Colors.white,
          unselectedColor: Colors.grey,
          backgroundColor: Colors.black,
          textDirection: TextDirection.ltr,
        );

        final painter2 = AdaptiveBottomNavPainter(
          repaint: anim2,
          progress: 0.8,
          style: AdaptiveBottomNavigationStyle.wave,
          previousIndex: 0,
          currentIndex: 1,
          itemCount: 3,
          indicatorColor: Colors.blue,
          selectedColor: Colors.white,
          unselectedColor: Colors.grey,
          backgroundColor: Colors.black,
          textDirection: TextDirection.ltr,
        );

        expect(painter1.shouldRepaint(painter2), isTrue);
      });

      test('paints multiple frames without throwing or memory corruption', () {
        final anim = AlwaysStoppedAnimation(0.5);
        final painter = AdaptiveBottomNavPainter(
          repaint: anim,
          progress: 0.5,
          style: AdaptiveBottomNavigationStyle.classicCurve,
          previousIndex: 0,
          currentIndex: 1,
          itemCount: 4,
          indicatorColor: Colors.blue,
          selectedColor: Colors.white,
          unselectedColor: Colors.grey,
          backgroundColor: Colors.black,
          textDirection: TextDirection.ltr,
        );

        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        const size = Size(360, 64);

        // Paint 50 consecutive frames simulating 60fps render ticks
        for (int i = 0; i < 50; i++) {
          painter.paint(canvas, size);
        }

        final picture = recorder.endRecording();
        addTearDown(picture.dispose);
      });
    });
  });
}
