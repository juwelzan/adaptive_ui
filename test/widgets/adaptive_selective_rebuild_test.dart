import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

class ComplexState {
  const ComplexState({
    required this.studentName,
    required this.totalStudents,
    required this.department,
  });

  final String studentName;
  final int totalStudents;
  final String department;

  ComplexState copyWith({
    String? studentName,
    int? totalStudents,
    String? department,
  }) {
    return ComplexState(
      studentName: studentName ?? this.studentName,
      totalStudents: totalStudents ?? this.totalStudents,
      department: department ?? this.department,
    );
  }
}

class DashboardCubit extends Cubit<ComplexState> {
  DashboardCubit()
      : super(const ComplexState(
          studentName: 'John',
          totalStudents: 42,
          department: 'Computer Science',
        ));

  void updateName(String name) => emit(state.copyWith(studentName: name));
  void updateTotal(int total) => emit(state.copyWith(totalStudents: total));
  void updateDepartment(String dept) => emit(state.copyWith(department: dept));
  void emitSame() => emit(state.copyWith());
}

// Track rebuild counts accurately
class RebuildTracker {
  int headerRebuilds = 0;
  int nameRebuilds = 0;
  int countRebuilds = 0;
  int departmentRebuilds = 0;
}

class TrackedDashboardView extends StatelessWidget {
  const TrackedDashboardView({
    super.key,
    required this.tracker,
  });

  final RebuildTracker tracker;

  @override
  Widget build(BuildContext context) {
    return AdaptiveColumn(
      children: [
        // Sibling header that should never rebuild on Cubit state changes
        Builder(
          builder: (ctx) {
            tracker.headerRebuilds++;
            return const Text('Static Header');
          },
        ),
        // Selective consumer for studentName
        AdaptiveBlocSelector<DashboardCubit, ComplexState, String>(
          selector: (state) => state.studentName,
          builder: (ctx, name) {
            tracker.nameRebuilds++;
            return Text('Student: $name');
          },
        ),
        // Selective consumer for totalStudents
        AdaptiveBlocSelector<DashboardCubit, ComplexState, int>(
          selector: (state) => state.totalStudents,
          builder: (ctx, count) {
            tracker.countRebuilds++;
            return Text('Count: $count');
          },
        ),
        // Adaptive selector for department
        AdaptiveBlocSelector<DashboardCubit, ComplexState, String>.adaptive(
          selector: (state) => state.department,
          adaptiveBuilder: (ctx, dept, layout) {
            tracker.departmentRebuilds++;
            return Text('Dept: $dept (${layout.containerBreakpoint.name})');
          },
        ),
      ],
    );
  }
}

class RebuildScreen extends AdaptiveStatelessWidget {
  const RebuildScreen({
    super.key,
    required this.cubit,
    required this.tracker,
  });

  final DashboardCubit cubit;
  final RebuildTracker tracker;

  @override
  List<AdaptiveProviderItem> setProvider() => [
        BlocProvider<DashboardCubit>.value(value: cubit),
      ];

  @override
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout) {
    return TrackedDashboardView(tracker: tracker);
  }
}

void main() {
  group('Granular Selective Rebuilds & Isolation', () {
    late DashboardCubit cubit;
    late RebuildTracker tracker;

    setUp(() {
      cubit = DashboardCubit();
      tracker = RebuildTracker();
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('Selective rebuilds only trigger affected consumers',
        (tester) async {
      await tester.pumpAdaptive(
        child: RebuildScreen(cubit: cubit, tracker: tracker),
      );

      // Initial build expectations
      expect(find.text('Static Header'), findsOneWidget);
      expect(find.text('Student: John'), findsOneWidget);
      expect(find.text('Count: 42'), findsOneWidget);
      expect(find.text('Dept: Computer Science (compact)'), findsOneWidget);

      expect(tracker.headerRebuilds, equals(1));
      expect(tracker.nameRebuilds, equals(1));
      expect(tracker.countRebuilds, equals(1));
      expect(tracker.departmentRebuilds, equals(1));

      // 1. Update ONLY studentName:
      cubit.updateName('Jane');
      await tester.pumpAndSettle();

      expect(find.text('Student: Jane'), findsOneWidget);
      // ONLY name consumer should have rebuilt!
      expect(tracker.nameRebuilds, equals(2));
      expect(tracker.headerRebuilds, equals(1),
          reason: 'Header sibling must NOT rebuild');
      expect(tracker.countRebuilds, equals(1),
          reason: 'Count consumer must NOT rebuild when only name changes');
      expect(tracker.departmentRebuilds, equals(1),
          reason: 'Dept consumer must NOT rebuild when only name changes');

      // 2. Update ONLY totalStudents:
      cubit.updateTotal(99);
      await tester.pumpAndSettle();

      expect(find.text('Count: 99'), findsOneWidget);
      // ONLY count consumer should have rebuilt!
      expect(tracker.nameRebuilds, equals(2),
          reason: 'Name consumer must NOT rebuild when count changes');
      expect(tracker.headerRebuilds, equals(1));
      expect(tracker.countRebuilds, equals(2));
      expect(tracker.departmentRebuilds, equals(1));

      // 3. Update department:
      cubit.updateDepartment('Mathematics');
      await tester.pumpAndSettle();

      expect(find.text('Dept: Mathematics (compact)'), findsOneWidget);
      expect(tracker.nameRebuilds, equals(2));
      expect(tracker.headerRebuilds, equals(1));
      expect(tracker.countRebuilds, equals(2));
      expect(tracker.departmentRebuilds, equals(2));
    });

    testWidgets('Emitting equal state value does NOT rebuild consumer',
        (tester) async {
      await tester.pumpAdaptive(
        child: RebuildScreen(cubit: cubit, tracker: tracker),
      );

      expect(tracker.nameRebuilds, equals(1));
      expect(tracker.countRebuilds, equals(1));

      // Emit identical copy of state
      cubit.emitSame();
      await tester.pumpAndSettle();

      // No consumers should rebuild because selected values are == previous values
      expect(tracker.nameRebuilds, equals(1));
      expect(tracker.countRebuilds, equals(1));
      expect(tracker.departmentRebuilds, equals(1));
      expect(tracker.headerRebuilds, equals(1));
    });
  });
}
