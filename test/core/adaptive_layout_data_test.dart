import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveLayoutData', () {
    test('reports correct available dimensions and breakpoint flags', () {
      final layout = AdaptiveLayoutData.fallback(
        constraints: const BoxConstraints(maxWidth: 800.0, maxHeight: 600.0),
        screenSize: const Size(1920.0, 1080.0),
      );

      // Parent container width governs component layout
      expect(layout.availableWidth, equals(800.0));
      expect(layout.availableHeight, equals(600.0));
      expect(layout.containerBreakpoint, equals(Breakpoint.medium));
      expect(layout.isMedium, isTrue);
      expect(layout.isCompact, isFalse);
      expect(layout.isMobile, isFalse);
      expect(layout.isTablet, isTrue);
      expect(layout.isDesktop, isFalse);

      // Window breakpoint reflects physical display
      expect(layout.windowBreakpoint, equals(Breakpoint.extraLarge));
    });

    test('verifies semantic device form-factor aliases', () {
      final compactLayout = AdaptiveLayoutData.fallback(
        constraints: const BoxConstraints(maxWidth: 400.0),
      );
      expect(compactLayout.isMobile, isTrue);
      expect(compactLayout.isTablet, isFalse);
      expect(compactLayout.isDesktop, isFalse);

      final expandedLayout = AdaptiveLayoutData.fallback(
        constraints: const BoxConstraints(maxWidth: 900.0),
      );
      expect(expandedLayout.isMobile, isFalse);
      expect(expandedLayout.isTablet, isTrue);
      expect(expandedLayout.isDesktop, isFalse);

      final desktopLayout = AdaptiveLayoutData.fallback(
        constraints: const BoxConstraints(maxWidth: 1400.0),
      );
      expect(desktopLayout.isMobile, isFalse);
      expect(desktopLayout.isTablet, isFalse);
      expect(desktopLayout.isDesktop, isTrue);
    });

    test('delegates pattern matching via when and value', () {
      final layout = AdaptiveLayoutData.fallback(
        constraints: const BoxConstraints(maxWidth: 800.0),
      ); // medium

      final resolvedString = layout.when<String>(
        compact: () => 'mobile',
        medium: () => 'tablet',
        large: () => 'desktop',
      );
      expect(resolvedString, equals('tablet'));

      final resolvedInt = layout.value<int>(
        compact: 1,
        medium: 2,
        large: 4,
      );
      expect(resolvedInt, equals(2));
    });

    test('detects keyboard visibility via viewInsets', () {
      final withoutKb = AdaptiveLayoutData.fallback();
      expect(withoutKb.isKeyboardVisible, isFalse);

      final withKb = withoutKb.copyWith(
        viewInsets: const EdgeInsets.only(bottom: 280.0),
      );
      expect(withKb.isKeyboardVisible, isTrue);
    });
  });
}
