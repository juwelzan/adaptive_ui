import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveBreakpoints', () {
    const breakpoints = AdaptiveBreakpoints.standard;

    test('resolves widths into correct Breakpoint tiers', () {
      expect(breakpoints.resolve(320.0), equals(Breakpoint.compact));
      expect(breakpoints.resolve(599.9), equals(Breakpoint.compact));
      expect(breakpoints.resolve(600.0), equals(Breakpoint.medium));
      expect(breakpoints.resolve(839.9), equals(Breakpoint.medium));
      expect(breakpoints.resolve(840.0), equals(Breakpoint.expanded));
      expect(breakpoints.resolve(1199.9), equals(Breakpoint.expanded));
      expect(breakpoints.resolve(1200.0), equals(Breakpoint.large));
      expect(breakpoints.resolve(1599.9), equals(Breakpoint.large));
      expect(breakpoints.resolve(1600.0), equals(Breakpoint.extraLarge));
      expect(breakpoints.resolve(2560.0), equals(Breakpoint.extraLarge));
    });

    test('verifies exact boundary and boundary-adjacent values', () {
      // Compact boundary: [0.0, 600.0)
      expect(breakpoints.resolve(0.0), equals(Breakpoint.compact));
      expect(breakpoints.resolve(599.999), equals(Breakpoint.compact));
      expect(breakpoints.resolve(600.0), equals(Breakpoint.medium));

      // Medium boundary: [600.0, 840.0)
      expect(breakpoints.resolve(600.001), equals(Breakpoint.medium));
      expect(breakpoints.resolve(839.999), equals(Breakpoint.medium));
      expect(breakpoints.resolve(840.0), equals(Breakpoint.expanded));

      // Expanded boundary: [840.0, 1200.0)
      expect(breakpoints.resolve(840.001), equals(Breakpoint.expanded));
      expect(breakpoints.resolve(1199.999), equals(Breakpoint.expanded));
      expect(breakpoints.resolve(1200.0), equals(Breakpoint.large));

      // Large boundary: [1200.0, 1600.0)
      expect(breakpoints.resolve(1200.001), equals(Breakpoint.large));
      expect(breakpoints.resolve(1599.999), equals(Breakpoint.large));
      expect(breakpoints.resolve(1600.0), equals(Breakpoint.extraLarge));

      // ExtraLarge: [1600.0, double.infinity)
      expect(breakpoints.resolve(1600.001), equals(Breakpoint.extraLarge));
      expect(breakpoints.resolve(4000.0), equals(Breakpoint.extraLarge));
    });

    test('rangeFor returns half-open intervals matching breakpoint definition',
        () {
      final compactRange = breakpoints.rangeFor(Breakpoint.compact);
      expect(compactRange.min, equals(0.0));
      expect(compactRange.max, equals(600.0));

      final mediumRange = breakpoints.rangeFor(Breakpoint.medium);
      expect(mediumRange.min, equals(600.0));
      expect(mediumRange.max, equals(840.0));

      final expandedRange = breakpoints.rangeFor(Breakpoint.expanded);
      expect(expandedRange.min, equals(840.0));
      expect(expandedRange.max, equals(1200.0));

      final largeRange = breakpoints.rangeFor(Breakpoint.large);
      expect(largeRange.min, equals(1200.0));
      expect(largeRange.max, equals(1600.0));

      final extraLargeRange = breakpoints.rangeFor(Breakpoint.extraLarge);
      expect(extraLargeRange.min, equals(1600.0));
      expect(extraLargeRange.max, equals(double.infinity));
    });

    test('Breakpoint enum boolean getters and comparison methods', () {
      expect(Breakpoint.compact.isCompact, isTrue);
      expect(Breakpoint.compact.isMedium, isFalse);
      expect(Breakpoint.medium.isMedium, isTrue);
      expect(Breakpoint.expanded.isExpanded, isTrue);
      expect(Breakpoint.large.isLarge, isTrue);
      expect(Breakpoint.extraLarge.isExtraLarge, isTrue);

      expect(Breakpoint.expanded.isAtLeast(Breakpoint.medium), isTrue);
      expect(Breakpoint.expanded.isAtLeast(Breakpoint.expanded), isTrue);
      expect(Breakpoint.expanded.isAtLeast(Breakpoint.large), isFalse);

      expect(Breakpoint.medium.isAtMost(Breakpoint.expanded), isTrue);
      expect(Breakpoint.large.isAtMost(Breakpoint.medium), isFalse);
    });

    test('Breakpoint.when dispatches with fallback inheritance', () {
      final fromCompact = Breakpoint.compact.when<String>(
        compact: () => 'compact',
        medium: () => 'medium',
      );
      expect(fromCompact, equals('compact'));

      // If extraLarge is not specified, it falls back downwards
      final fromExtraLarge = Breakpoint.extraLarge.when<String>(
        compact: () => 'compact',
        medium: () => 'medium',
      );
      expect(fromExtraLarge, equals('medium'));

      final fromExpanded = Breakpoint.expanded.when<String>(
        compact: () => 'compact',
        expanded: () => 'expanded',
      );
      expect(fromExpanded, equals('expanded'));
    });

    test('Breakpoint.value resolves values with fallback inheritance', () {
      expect(
        Breakpoint.compact.value<int>(compact: 1, medium: 2, large: 4),
        equals(1),
      );
      expect(
        Breakpoint.medium.value<int>(compact: 1, medium: 2, large: 4),
        equals(2),
      );
      expect(
        Breakpoint.expanded.value<int>(compact: 1, medium: 2, large: 4),
        equals(2), // falls back to medium
      );
      expect(
        Breakpoint.large.value<int>(compact: 1, medium: 2, large: 4),
        equals(4),
      );
      expect(
        Breakpoint.extraLarge.value<int>(compact: 1, medium: 2, large: 4),
        equals(4), // falls back to large
      );
    });

    test('custom breakpoints copyWith and equality', () {
      final custom = breakpoints.copyWith(compactMax: 500.0);
      expect(custom.compactMax, equals(500.0));
      expect(custom.resolve(450.0), equals(Breakpoint.compact));
      expect(custom.resolve(550.0), equals(Breakpoint.medium));
      expect(custom, isNot(equals(breakpoints)));
    });
  });
}
