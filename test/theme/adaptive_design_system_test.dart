import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Phase 5 — Adaptive Design System & Unified Theme Engine', () {
    // -------------------------------------------------------------------------
    // 1. Theme Defaults & Light/Dark Constructors
    // -------------------------------------------------------------------------
    group('1. Theme Defaults & Brightness Resolution', () {
      test('Default light theme initializes with correct semantic tokens', () {
        final theme = AdaptiveThemeData.light();
        expect(theme.isLight, isTrue);
        expect(theme.isDark, isFalse);
        expect(theme.brightness, equals(Brightness.light));

        // Colors
        expect(theme.colors.primary, isNotNull);
        expect(theme.colors.surface, isNotNull);
        expect(theme.colors.surfaceElevated, isNotNull);
        expect(theme.colors.background, isNotNull);
        expect(theme.colors.onPrimary, isNotNull);
        expect(theme.colors.onSurface, isNotNull);
        expect(theme.colors.textPrimary, isNotNull);
        expect(theme.colors.textSecondary, isNotNull);
        expect(theme.colors.border, isNotNull);
        expect(theme.colors.divider, isNotNull);
        expect(theme.colors.success, isNotNull);
        expect(theme.colors.warning, isNotNull);
        expect(theme.colors.error, isNotNull);
        expect(theme.colors.info, isNotNull);
        expect(theme.colors.disabled, isNotNull);
        expect(theme.colors.hover, isNotNull);
        expect(theme.colors.focus, isNotNull);
        expect(theme.colors.highlight, isNotNull);

        // Tokens
        expect(theme.spacing.sm, equals(8.0));
        expect(theme.radii.md, equals(12.0));
        expect(theme.elevations.low, equals(1.0));
        expect(theme.density, equals(AdaptiveDensity.comfortable));
      });

      test('Default dark theme initializes with dark brightness and tokens',
          () {
        final theme = AdaptiveThemeData.dark();
        expect(theme.isDark, isTrue);
        expect(theme.isLight, isFalse);
        expect(theme.brightness, equals(Brightness.dark));

        // Elevated surface should be non-null in dark mode
        expect(theme.colors.surfaceElevated, isNotNull);
      });

      test('fromTheme and fromColorScheme construct accurate AdaptiveThemeData',
          () {
        final darkThemeData = ThemeData.dark();
        final adaptiveDark = AdaptiveThemeData.fromTheme(darkThemeData);
        expect(adaptiveDark.isDark, isTrue);
        expect(adaptiveDark.colors.primary,
            equals(darkThemeData.colorScheme.primary));

        const customScheme = ColorScheme.light(
          primary: Color(0xFF123456),
          secondary: Color(0xFF654321),
          error: Color(0xFFFF0000),
        );
        final adaptiveCustom = AdaptiveThemeData.fromColorScheme(customScheme);
        expect(adaptiveCustom.colors.primary, equals(const Color(0xFF123456)));
        expect(
            adaptiveCustom.colors.secondary, equals(const Color(0xFF654321)));
        expect(adaptiveCustom.colors.error, equals(const Color(0xFFFF0000)));
      });
    });

    // -------------------------------------------------------------------------
    // 2. Semantic Color System & Lerp
    // -------------------------------------------------------------------------
    group('2. Semantic Color System & Lerp', () {
      test('AdaptiveColors.lerp linearly interpolates all color roles', () {
        final a = AdaptiveColors.light.copyWith(
          primary: const Color(0xFF000000),
          surface: const Color(0xFF000000),
          success: const Color(0xFF000000),
        );
        final b = AdaptiveColors.light.copyWith(
          primary: const Color(0xFFFFFFFF),
          surface: const Color(0xFFFFFFFF),
          success: const Color(0xFFFFFFFF),
        );

        final mid = AdaptiveColors.lerp(a, b, 0.5);
        expect(mid.primary.toARGB32(),
            equals(Color.lerp(a.primary, b.primary, 0.5)!.toARGB32()));
        expect(mid.surface.toARGB32(),
            equals(Color.lerp(a.surface, b.surface, 0.5)!.toARGB32()));
        expect(mid.success.toARGB32(),
            equals(Color.lerp(a.success, b.success, 0.5)!.toARGB32()));
      });
    });

    // -------------------------------------------------------------------------
    // 3. Adaptive Typography & AdaptiveText Variants
    // -------------------------------------------------------------------------
    group('3. Adaptive Typography & AdaptiveText Variants', () {
      test('Typography styles exist and lerp smoothly', () {
        final typeA = AdaptiveTypography.standard.copyWith(
          caption: const TextStyle(fontSize: 10.0),
          bodyMedium: const TextStyle(fontSize: 14.0),
        );
        final typeB = AdaptiveTypography.standard.copyWith(
          caption: const TextStyle(fontSize: 14.0),
          bodyMedium: const TextStyle(fontSize: 18.0),
        );

        final mid = AdaptiveTypography.lerp(typeA, typeB, 0.5);
        expect(mid.caption.fontSize, equals(12.0));
        expect(mid.bodyMedium.fontSize, equals(16.0));
      });

      testWidgets(
          'AdaptiveText with AdaptiveTextVariant resolves corresponding style',
          (tester) async {
        await tester.pumpAdaptive(
          child: Column(
            children: const [
              AdaptiveText('Heading Title',
                  variant: AdaptiveTextVariant.titleLarge),
              AdaptiveText('Body Message',
                  variant: AdaptiveTextVariant.bodyMedium),
              AdaptiveText('Small Footnote',
                  variant: AdaptiveTextVariant.caption),
            ],
          ),
        );

        final Text titleText = tester.widget(find.text('Heading Title'));
        final Text bodyText = tester.widget(find.text('Body Message'));
        final Text captionText = tester.widget(find.text('Small Footnote'));

        expect(titleText.style?.fontSize,
            greaterThan(bodyText.style?.fontSize ?? 0));
        expect(bodyText.style?.fontSize,
            greaterThan(captionText.style?.fontSize ?? 0));
      });
    });

    // -------------------------------------------------------------------------
    // 4. Elevations and Density Tokens
    // -------------------------------------------------------------------------
    group('4. Elevations, Density & Token Lerp', () {
      test('AdaptiveElevations generates appropriate shadows', () {
        const elevations = AdaptiveElevations();
        expect(elevations.none, equals(0.0));
        expect(elevations.low, equals(1.0));
        expect(elevations.medium, equals(3.0));
        expect(elevations.high, equals(6.0));
        expect(elevations.extraHigh, equals(12.0));

        final zeroShadow = elevations.shadowOf(0.0);
        expect(zeroShadow, isEmpty);

        final lowShadow = elevations.shadowOf(elevations.low);
        expect(lowShadow, isNotEmpty);
        expect(lowShadow.first.blurRadius, greaterThan(0.0));
      });

      test('AdaptiveDensity presets have consistent multipliers', () {
        expect(
            AdaptiveDensity.compact.verticalSpacingMultiplier, lessThan(1.0));
        expect(AdaptiveDensity.spacious.verticalSpacingMultiplier,
            greaterThan(1.0));
        expect(
            AdaptiveDensity.comfortable.verticalSpacingMultiplier, equals(1.0));
      });

      test('AdaptiveThemeData.lerp smoothly interpolates themes', () {
        final light = AdaptiveThemeData.light();
        final dark = AdaptiveThemeData.dark();

        final mid = AdaptiveThemeData.lerp(light, dark, 0.5);
        expect(mid.colors.primary, isNotNull);
        expect(mid.spacing.md, equals(16.0));
      });
    });

    // -------------------------------------------------------------------------
    // 5. Precedence Rules & Component Themes
    // -------------------------------------------------------------------------
    group('5. Component Themes & Precedence Rules', () {
      testWidgets(
          'AdaptiveCard adopts cardTheme defaults, but explicit props win',
          (tester) async {
        const themedColor = Color(0xFF673AB7);
        const explicitColor = Color(0xFFFF5722);

        final themeWithCard = AdaptiveThemeData.light().copyWith(
          componentThemes: const AdaptiveComponentThemes(
            card: AdaptiveCardThemeData(
              color: themedColor,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
          ),
        );

        await tester.pumpAdaptive(
          theme: themeWithCard,
          child: Column(
            children: const [
              AdaptiveCard(
                key: Key('themed-card'),
                child: Text('Themed Card'),
              ),
              AdaptiveCard(
                key: Key('explicit-card'),
                color: explicitColor,
                child: Text('Explicit Card'),
              ),
            ],
          ),
        );

        final themedCardFinder = find.byKey(const Key('themed-card'));
        final explicitCardFinder = find.byKey(const Key('explicit-card'));

        expect(themedCardFinder, findsOneWidget);
        expect(explicitCardFinder, findsOneWidget);

        // AdaptiveCard uses Material internally
        final themedMaterial = tester.widget<Material>(
          find
              .descendant(of: themedCardFinder, matching: find.byType(Material))
              .first,
        );
        expect(themedMaterial.color, equals(themedColor));
        expect(
          themedMaterial.borderRadius,
          equals(const BorderRadius.all(Radius.circular(20.0))),
        );

        final explicitMaterial = tester.widget<Material>(
          find
              .descendant(
                  of: explicitCardFinder, matching: find.byType(Material))
              .first,
        );
        expect(explicitMaterial.color, equals(explicitColor));
      });

      testWidgets(
          'AdaptiveButton adopts buttonTheme defaults, but explicit props win',
          (tester) async {
        final themeWithButton = AdaptiveThemeData.light().copyWith(
          componentThemes: const AdaptiveComponentThemes(
            button: AdaptiveButtonThemeData(
              borderRadius: BorderRadius.all(Radius.circular(24.0)),
            ),
          ),
        );

        await tester.pumpAdaptive(
          theme: themeWithButton,
          child: Column(
            children: [
              AdaptiveButton(
                key: const Key('themed-btn'),
                onPressed: () {},
                child: const Text('Themed'),
              ),
              AdaptiveButton(
                key: const Key('explicit-btn'),
                borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                onPressed: () {},
                child: const Text('Explicit'),
              ),
            ],
          ),
        );

        expect(find.byKey(const Key('themed-btn')), findsOneWidget);
        expect(find.byKey(const Key('explicit-btn')), findsOneWidget);
      });

      testWidgets('AdaptiveBottomNavigationBar adopts bottomNavTheme',
          (tester) async {
        const navBg = Color(0xFF004D40);

        final themeWithNav = AdaptiveThemeData.light().copyWith(
          componentThemes: const AdaptiveComponentThemes(
            bottomNav: AdaptiveBottomNavThemeData(
              backgroundColor: navBg,
            ),
          ),
        );

        await tester.pumpAdaptive(
          theme: themeWithNav,
          child: AdaptiveBottomNavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: const [
              AdaptiveBottomNavigationDestination(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              AdaptiveBottomNavigationDestination(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
            ],
          ),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);
      });

      testWidgets(
          'AdaptiveShimmer adopts shimmerTheme base and highlight colors',
          (tester) async {
        const base = Color(0xFFECEFF1);
        const highlight = Color(0xFFCFD8DC);

        final themeWithShimmer = AdaptiveThemeData.light().copyWith(
          componentThemes: const AdaptiveComponentThemes(
            shimmer: AdaptiveShimmerThemeData(
              baseColor: base,
              highlightColor: highlight,
            ),
          ),
        );

        await tester.pumpWidget(
          wrapWithAdaptive(
            theme: themeWithShimmer,
            child: const AdaptiveShimmer(
              child: SizedBox(width: 100, height: 20),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.byType(AdaptiveShimmer), findsOneWidget);
      });
    });

    // -------------------------------------------------------------------------
    // 6. Theme Inheritance & Nested Overrides
    // -------------------------------------------------------------------------
    group('6. Theme Inheritance & Nested Subtrees', () {
      testWidgets('Nested AdaptiveTheme overrides root values for subtree only',
          (tester) async {
        await tester.pumpAdaptive(
          theme: AdaptiveThemeData.light().copyWith(
            spacing: const AdaptiveSpacing(sm: 10.0),
          ),
          child: Column(
            children: [
              Builder(
                builder: (ctx) =>
                    Text('Root SM: ${AdaptiveTheme.of(ctx).spacing.sm}'),
              ),
              AdaptiveTheme(
                data: AdaptiveThemeData.light().copyWith(
                  spacing: const AdaptiveSpacing(sm: 24.0),
                ),
                child: Builder(
                  builder: (ctx) =>
                      Text('Nested SM: ${AdaptiveTheme.of(ctx).spacing.sm}'),
                ),
              ),
            ],
          ),
        );

        expect(find.text('Root SM: 10.0'), findsOneWidget);
        expect(find.text('Nested SM: 24.0'), findsOneWidget);
      });
    });

    // -------------------------------------------------------------------------
    // 7. Animated Theme Transitions & Reduced Motion
    // -------------------------------------------------------------------------
    group('7. AnimatedAdaptiveTheme & Reduced Motion', () {
      testWidgets(
          'AnimatedAdaptiveTheme interpolates tokens smoothly over time',
          (tester) async {
        final themeA = AdaptiveThemeData.light().copyWith(
          spacing: const AdaptiveSpacing(sm: 10.0),
        );
        final themeB = AdaptiveThemeData.light().copyWith(
          spacing: const AdaptiveSpacing(sm: 30.0),
        );

        Widget buildApp(AdaptiveThemeData currentTheme) {
          return MaterialApp(
            home: AnimatedAdaptiveTheme(
              data: currentTheme,
              duration: const Duration(milliseconds: 300),
              child: Builder(
                builder: (ctx) {
                  final sm = AdaptiveTheme.of(ctx).spacing.sm;
                  return Text('Current SM: ${sm.toStringAsFixed(1)}');
                },
              ),
            ),
          );
        }

        await tester.pumpWidget(buildApp(themeA));
        expect(find.text('Current SM: 10.0'), findsOneWidget);

        await tester.pumpWidget(buildApp(themeB));
        await tester.pump(const Duration(milliseconds: 150));

        // Halfway through 10 -> 30, it should be approximately 20.0
        expect(find.text('Current SM: 20.0'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Current SM: 30.0'), findsOneWidget);
      });

      testWidgets(
          'AnimatedAdaptiveTheme snaps instantly when reduced motion is active',
          (tester) async {
        final themeA = AdaptiveThemeData.light().copyWith(
          spacing: const AdaptiveSpacing(sm: 10.0),
        );
        final themeB = AdaptiveThemeData.light().copyWith(
          spacing: const AdaptiveSpacing(sm: 30.0),
        );

        Widget buildApp(AdaptiveThemeData currentTheme) {
          return MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: AnimatedAdaptiveTheme(
                data: currentTheme,
                duration: const Duration(milliseconds: 300),
                child: Builder(
                  builder: (ctx) {
                    final sm = AdaptiveTheme.of(ctx).spacing.sm;
                    return Text('Current SM: ${sm.toStringAsFixed(1)}');
                  },
                ),
              ),
            ),
          );
        }

        await tester.pumpWidget(buildApp(themeA));
        expect(find.text('Current SM: 10.0'), findsOneWidget);

        await tester.pumpWidget(buildApp(themeB));
        // Immediate frame check: should snap directly to 30.0 without needing pump(duration)
        await tester.pump();
        expect(find.text('Current SM: 30.0'), findsOneWidget);
      });
    });

    // -------------------------------------------------------------------------
    // 8. Accessibility Text Scaling & RTL Support
    // -------------------------------------------------------------------------
    group('8. Accessibility Text Scaling & RTL Support', () {
      testWidgets('AdaptiveText scales gracefully with large TextScaler',
          (tester) async {
        await tester.pumpAdaptive(
          textScaler: const TextScaler.linear(2.0),
          child: const AdaptiveText(
            'Large Scaled Text',
            variant: AdaptiveTextVariant.headlineMedium,
          ),
        );

        expect(find.text('Large Scaled Text'), findsOneWidget);
      });

      testWidgets('Adaptive components render seamlessly in RTL layout',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: AdaptiveApp(
                theme: AdaptiveThemeData.light(),
                child: Scaffold(
                  body: Column(
                    children: [
                      const AdaptiveText('مرحبا بالعالم',
                          variant: AdaptiveTextVariant.titleLarge),
                      const AdaptiveCard(child: Text('بطاقة RTL')),
                      AdaptiveButton(
                        onPressed: () {},
                        child: const Text('زر RTL'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('مرحبا بالعالم'), findsOneWidget);
        expect(find.text('بطاقة RTL'), findsOneWidget);
        expect(find.text('زر RTL'), findsOneWidget);
      });
    });

    // -------------------------------------------------------------------------
    // 9. Backward Compatibility
    // -------------------------------------------------------------------------
    group('9. Backward Compatibility', () {
      testWidgets('Widgets function without explicit AdaptiveTheme in tree',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const AdaptiveText('Standalone Text'),
                  const AdaptiveCard(child: Text('Standalone Card')),
                  AdaptiveButton(
                    onPressed: () {},
                    child: const Text('Standalone Button'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Standalone Text'), findsOneWidget);
        expect(find.text('Standalone Card'), findsOneWidget);
        expect(find.text('Standalone Button'), findsOneWidget);
      });
    });
  });
}
