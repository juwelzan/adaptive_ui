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

    test('custom breakpoints copyWith and equality', () {
      final custom = breakpoints.copyWith(compactMax: 500.0);
      expect(custom.compactMax, equals(500.0));
      expect(custom.resolve(450.0), equals(Breakpoint.compact));
      expect(custom.resolve(550.0), equals(Breakpoint.medium));
      expect(custom, isNot(equals(breakpoints)));
    });
  });
}
