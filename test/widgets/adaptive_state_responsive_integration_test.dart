import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

class SessionState {
  const SessionState({
    required this.counter,
    required this.username,
  });

  final int counter;
  final String username;

  SessionState copyWith({int? counter, String? username}) {
    return SessionState(
      counter: counter ?? this.counter,
      username: username ?? this.username,
    );
  }
}

class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionState(counter: 0, username: 'Dr. John'));

  void increment() => emit(state.copyWith(counter: state.counter + 1));
  void setUsername(String name) => emit(state.copyWith(username: name));
}

class StatefulSessionScreen extends AdaptiveStatefulWidget {
  const StatefulSessionScreen({super.key});

  @override
  List<AdaptiveProviderItem> setProvider() => [
        BlocProvider<SessionCubit>(create: (_) => SessionCubit()),
      ];

  @override
  AdaptiveState<StatefulSessionScreen> createAdaptiveState() =>
      _StatefulSessionScreenState();
}

class _StatefulSessionScreenState extends AdaptiveState<StatefulSessionScreen> {
  @override
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout) {
    return Scaffold(
      body: AdaptiveColumn(
        children: [
          Text('Breakpoint: ${layout.containerBreakpoint.name}'),
          AdaptiveBlocSelector<SessionCubit, SessionState, int>.adaptive(
            selector: (s) => s.counter,
            adaptiveBuilder: (ctx, count, l) => Text(
              'Count: $count on ${l.containerBreakpoint.name}',
            ),
          ),
          AdaptiveBlocSelector<SessionCubit, SessionState, String>(
            selector: (s) => s.username,
            builder: (ctx, name) => Text('User: $name'),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('Adaptive State & Responsive Layout Integration', () {
    testWidgets(
        'breakpoint change preserves active BLoC/Cubit state without reset',
        (tester) async {
      // 1. Mount in compact viewport
      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        child: const StatefulSessionScreen(),
      );

      expect(find.text('Breakpoint: compact'), findsOneWidget);
      expect(find.text('Count: 0 on compact'), findsOneWidget);
      expect(find.text('User: Dr. John'), findsOneWidget);

      // 2. Mutate state while in compact view
      final BuildContext elementCtx =
          tester.element(find.text('User: Dr. John'));
      final cubit = elementCtx.read<SessionCubit>();
      cubit.increment();
      cubit.increment();
      cubit.setUsername('Prof. Turing');
      await tester.pumpAndSettle();

      expect(find.text('Count: 2 on compact'), findsOneWidget);
      expect(find.text('User: Prof. Turing'), findsOneWidget);

      // 3. Resize viewport to expanded (1024x768)
      await tester.pumpAdaptive(
        size: const Size(1024.0, 768.0),
        child: const StatefulSessionScreen(),
      );
      await tester.pumpAndSettle();

      // 4. Verify that state was NOT reset to 0 / 'Dr. John'
      expect(find.text('Breakpoint: expanded'), findsOneWidget);
      expect(find.text('Count: 2 on expanded'), findsOneWidget);
      expect(find.text('User: Prof. Turing'), findsOneWidget);
    });

    testWidgets(
        'state-managed widgets render safely inside nested responsive rows, columns, expanded, and cards',
        (tester) async {
      final cubit = SessionCubit();
      int cardRebuilds = 0;

      await tester.pumpAdaptive(
        size: const Size(800.0, 600.0),
        child: BlocProvider<SessionCubit>.value(
          value: cubit,
          child: AdaptiveColumn(
            spacing: const AdaptiveValue.fixed(12.0),
            children: [
              AdaptiveRow(
                spacing: const AdaptiveValue.fixed(8.0),
                children: [
                  Expanded(
                    child: AdaptiveCard(
                      child: AdaptiveBlocSelector<SessionCubit, SessionState,
                          String>(
                        selector: (s) => s.username,
                        builder: (ctx, name) => ListTile(
                          leading: const Icon(Icons.person),
                          title: Text('Name: $name'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AdaptiveCard(
                      child: Builder(
                        builder: (ctx) {
                          cardRebuilds++;
                          return AdaptiveBlocSelector<SessionCubit,
                              SessionState, int>(
                            selector: (s) => s.counter,
                            builder: (ctx, count) => ListTile(
                              leading: const Icon(Icons.numbers),
                              title: Text('Score: $count'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      expect(find.text('Name: Dr. John'), findsOneWidget);
      expect(find.text('Score: 0'), findsOneWidget);
      expect(cardRebuilds, equals(1));

      // Mutate only counter:
      cubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('Score: 1'), findsOneWidget);
      expect(find.text('Name: Dr. John'), findsOneWidget);
      // The parent card builder should NOT have rebuilt
      expect(cardRebuilds, equals(1));

      // Clean up
      await cubit.close();
    });

    testWidgets(
        'nested stateful adaptive widgets under constrained parent render without error',
        (tester) async {
      final cubit = SessionCubit();

      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        child: BlocProvider<SessionCubit>.value(
          value: cubit,
          child: Center(
            child: SizedBox(
              width: 150.0, // Constrained width
              child: AdaptiveCard(
                child: AdaptiveBlocSelector<SessionCubit, SessionState, int>(
                  selector: (s) => s.counter,
                  builder: (ctx, count) => Text('Tight: $count'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tight: 0'), findsOneWidget);

      cubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('Tight: 1'), findsOneWidget);

      await cubit.close();
    });
  });
}
