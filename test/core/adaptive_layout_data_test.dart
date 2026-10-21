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

      // Window breakpoint reflects physical display
      expect(layout.windowBreakpoint, equals(Breakpoint.extraLarge));
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
