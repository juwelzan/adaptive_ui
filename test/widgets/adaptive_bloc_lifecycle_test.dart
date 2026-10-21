import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

// Test Events & States
sealed class CounterEvent {}

final class IncrementEvent extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc({this.onClosed}) : super(0) {
    on<IncrementEvent>((event, emit) => emit(state + 1));
  }

  final VoidCallback? onClosed;

  @override
  Future<void> close() {
    onClosed?.call();
    return super.close();
  }
}

class TestCubit extends Cubit<String> {
  TestCubit({this.onClosed}) : super('initial');

  final VoidCallback? onClosed;

  void update(String val) => emit(val);

  @override
  Future<void> close() {
    onClosed?.call();
    return super.close();
  }
}

class TestRepository {
  const TestRepository(this.tag);
  final String tag;
}

// Stateful adaptive screen with lifecycle hooks
class ScopedDashboardWidget extends AdaptiveStatefulWidget {
  const ScopedDashboardWidget({
    super.key,
    required this.cubitFactory,
    required this.blocFactory,
    required this.repository,
    this.shouldNotifyProviders = false,
  });

  final TestCubit Function() cubitFactory;
  final CounterBloc Function() blocFactory;
  final TestRepository repository;
  final bool shouldNotifyProviders;

  @override
  List<AdaptiveProviderItem> setProvider() {
    return [
      BlocProvider<TestCubit>(create: (_) => cubitFactory()),
      BlocProvider<CounterBloc>(create: (_) => blocFactory()),
      RepositoryProvider<TestRepository>.value(value: repository),
    ];
  }

  @override
  bool updateShouldNotifyProviders(covariant ScopedDashboardWidget oldWidget) {
    return shouldNotifyProviders;
  }

  @override
  State<ScopedDashboardWidget> createAdaptiveState() =>
      _ScopedDashboardWidgetState();
}

class _ScopedDashboardWidgetState extends AdaptiveState<ScopedDashboardWidget> {
  @override
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout) {
    final repo = context.read<TestRepository>();
    return Column(
      children: [
        Text('Repo: ${repo.tag}'),
        AdaptiveBlocSelector<TestCubit, String, String>(
          selector: (s) => s,
          builder: (ctx, val) => Text('Cubit: $val'),
        ),
        AdaptiveBlocSelector<CounterBloc, int, int>(
          selector: (s) => s,
          builder: (ctx, count) => Text('Bloc: $count'),
        ),
        Text('Layout: ${layout.containerBreakpoint.name}'),
      ],
    );
  }
}

// Widget providing existing externally-owned instances
class ExternalProviderWidget extends AdaptiveStatelessWidget {
  const ExternalProviderWidget({
    super.key,
    required this.externalCubit,
  });

  final TestCubit externalCubit;

  @override
  List<AdaptiveProviderItem> setProvider() {
    return [
      BlocProvider<TestCubit>.value(value: externalCubit),
    ];
  }

  @override
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout) {
    return AdaptiveBlocSelector<TestCubit, String, String>(
      selector: (s) => s,
      builder: (ctx, val) => Text('External: $val'),
    );
  }
}

void main() {
  group('Adaptive BLoC Provider Lifecycle & Ownership', () {
    testWidgets(
        'Providers are available to descendants (Cubit, Bloc, Repository)',
        (tester) async {
      int cubitCreated = 0;
      int blocCreated = 0;

      await tester.pumpAdaptive(
        child: ScopedDashboardWidget(
          cubitFactory: () {
            cubitCreated++;
            return TestCubit();
          },
          blocFactory: () {
            blocCreated++;
            return CounterBloc();
          },
          repository: const TestRepository('ProductionRepo'),
        ),
      );

      expect(cubitCreated, equals(1));
      expect(blocCreated, equals(1));
      expect(find.text('Repo: ProductionRepo'), findsOneWidget);
      expect(find.text('Cubit: initial'), findsOneWidget);
      expect(find.text('Bloc: 0'), findsOneWidget);

      // Verify reads from descendants
      final BuildContext ctx = tester.element(find.text('Cubit: initial'));
      expect(ctx.read<TestCubit>().state, equals('initial'));
      expect(ctx.read<CounterBloc>().state, equals(0));
      expect(ctx.read<TestRepository>().tag, equals('ProductionRepo'));
    });

    testWidgets(
        'Provider instances are cached and NOT recreated on ordinary rebuilds',
        (tester) async {
      int cubitCreated = 0;
      int blocCreated = 0;

      // Pump initial widget
      await tester.pumpAdaptive(
        child: ScopedDashboardWidget(
          cubitFactory: () {
            cubitCreated++;
            return TestCubit();
          },
          blocFactory: () {
            blocCreated++;
            return CounterBloc();
          },
          repository: const TestRepository('Repo1'),
        ),
      );

      expect(cubitCreated, equals(1));
      expect(blocCreated, equals(1));

      // Rebuild parent with new widget instance (shouldNotifyProviders = false)
      await tester.pumpAdaptive(
        child: ScopedDashboardWidget(
          cubitFactory: () {
            cubitCreated++;
            return TestCubit();
          },
          blocFactory: () {
            blocCreated++;
            return CounterBloc();
          },
          repository: const TestRepository('Repo2'),
          shouldNotifyProviders: false,
        ),
      );

      // Verify that factories were NOT called again
      expect(cubitCreated, equals(1));
      expect(blocCreated, equals(1));
    });

    testWidgets('Owned Cubit and Bloc instances are properly closed on unmount',
        (tester) async {
      bool cubitClosed = false;
      bool blocClosed = false;

      await tester.pumpAdaptive(
        child: ScopedDashboardWidget(
          cubitFactory: () => TestCubit(onClosed: () => cubitClosed = true),
          blocFactory: () => CounterBloc(onClosed: () => blocClosed = true),
          repository: const TestRepository('Repo'),
        ),
      );

      expect(cubitClosed, isFalse);
      expect(blocClosed, isFalse);

      // Unmount the widget tree by pumping a different child
      await tester.pumpAdaptive(
        child: const Text('Unmounted'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unmounted'), findsOneWidget);
      expect(cubitClosed, isTrue);
      expect(blocClosed, isTrue);
    });

    testWidgets(
        'Externally owned instances provided via .value are NOT closed by framework',
        (tester) async {
      bool externalClosed = false;
      final TestCubit externalCubit =
          TestCubit(onClosed: () => externalClosed = true);

      await tester.pumpAdaptive(
        child: ExternalProviderWidget(externalCubit: externalCubit),
      );

      expect(find.text('External: initial'), findsOneWidget);
      expect(externalClosed, isFalse);

      // Unmount
      await tester.pumpAdaptive(
        child: const Text('Cleared'),
      );
      await tester.pumpAndSettle();

      // Ensure externally owned cubit was NOT closed by the widget unmounting
      expect(externalClosed, isFalse);

      // Clean up manually
      await externalCubit.close();
      expect(externalClosed, isTrue);
    });
  });
}
