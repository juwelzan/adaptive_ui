import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveValue', () {
    final compactLayout = AdaptiveLayoutData.fallback(
      constraints: const BoxConstraints(maxWidth: 390.0),
    );
    final mediumLayout = AdaptiveLayoutData.fallback(
      constraints: const BoxConstraints(maxWidth: 700.0),
    );
    final largeLayout = AdaptiveLayoutData.fallback(
      constraints: const BoxConstraints(maxWidth: 1400.0),
    );

    test('fixed value resolves identically across viewports', () {
      const value = AdaptiveValue.fixed(42.0);
      expect(value.resolve(compactLayout), equals(42.0));
      expect(value.resolve(mediumLayout), equals(42.0));
      expect(value.resolve(largeLayout), equals(42.0));
    });

    test('breakpoint value resolves differently per breakpoint', () {
      const value = AdaptiveValue.breakpoint(
        compact: 14.0,
        medium: 18.0,
        expanded: 22.0,
        large: 26.0,
        fallback: 16.0,
      );
      expect(value.resolve(compactLayout), equals(14.0));
      expect(value.resolve(mediumLayout), equals(18.0));
      expect(value.resolve(largeLayout), equals(26.0));
    });

    test('builder value evaluates procedural function', () {
      final value =
          AdaptiveValue.builder((layout) => layout.availableWidth * 0.5);
      expect(value.resolve(compactLayout), equals(195.0));
      expect(value.resolve(mediumLayout), equals(350.0));
    });

    test('auto value invokes autoResolver callback', () {
      const value = AdaptiveValue<double>.auto();
      expect(value.isAuto, isTrue);
      expect(value.resolve(compactLayout, () => 99.0), equals(99.0));
      expect(() => value.resolve(compactLayout), throwsStateError);
    });
  });

  group('AdaptiveInsets', () {
    final compactLayout = AdaptiveLayoutData.fallback(
      constraints: const BoxConstraints(maxWidth: 390.0),
    );
    final mediumLayout = AdaptiveLayoutData.fallback(
      constraints: const BoxConstraints(maxWidth: 700.0),
    );

    test('auto insets resolves 16dp on compact and 24dp on medium', () {
      const insets = AdaptiveInsets.auto();
      expect(insets.resolve(compactLayout), equals(const EdgeInsets.all(16.0)));
      expect(insets.resolve(mediumLayout), equals(const EdgeInsets.all(24.0)));
    });

    test('fixed and symmetric insets resolve accurately', () {
      final allInsets = AdaptiveInsets.all(20.0);
      expect(
          allInsets.resolve(compactLayout), equals(const EdgeInsets.all(20.0)));

      final symInsets =
          AdaptiveInsets.symmetric(horizontal: 16.0, vertical: 8.0);
      expect(
        symInsets.resolve(compactLayout),
        equals(const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
      );
    });
  });
}
