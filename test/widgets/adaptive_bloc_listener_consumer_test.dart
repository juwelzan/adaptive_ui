import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

class TestNotificationState {
  const TestNotificationState({required this.message, required this.count});
  final String message;
  final int count;

  TestNotificationState copyWith({String? message, int? count}) {
    return TestNotificationState(
      message: message ?? this.message,
      count: count ?? this.count,
    );
  }
}

class TestNotificationCubit extends Cubit<TestNotificationState> {
  TestNotificationCubit()
      : super(const TestNotificationState(message: 'initial', count: 0));

  void emitMessage(String msg) => emit(state.copyWith(message: msg));
  void increment() => emit(state.copyWith(count: state.count + 1));
}

void main() {
  group('AdaptiveBlocListener & AdaptiveCubitListener', () {
    late TestNotificationCubit cubit;

    setUp(() {
      cubit = TestNotificationCubit();
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('fires standard listener on state changes', (tester) async {
      final List<String> received = [];

      await tester.pumpAdaptive(
        child: BlocProvider<TestNotificationCubit>.value(
          value: cubit,
          child: AdaptiveBlocListener<TestNotificationCubit,
              TestNotificationState>(
            listener: (context, state) {
              received.add(state.message);
            },
            child: const Text('Child Content'),
          ),
        ),
      );

      expect(find.text('Child Content'), findsOneWidget);
      expect(received, isEmpty);

      cubit.emitMessage('Message 1');
      await tester.pump();

      expect(received, equals(['Message 1']));
    });

    testWidgets('fires adaptiveListener supplying resolved layout metrics',
        (tester) async {
      String? lastMessage;
      Breakpoint? lastBreakpoint;

      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0), // compact
        child: BlocProvider<TestNotificationCubit>.value(
          value: cubit,
          child: AdaptiveBlocListener<TestNotificationCubit,
              TestNotificationState>.adaptive(
            adaptiveListener: (context, state, layout) {
              lastMessage = state.message;
              lastBreakpoint = layout.containerBreakpoint;
            },
            child: const Text('Listener Active'),
          ),
        ),
      );

      cubit.emitMessage('Alert from cubit');
      await tester.pump();

      expect(lastMessage, equals('Alert from cubit'));
      expect(lastBreakpoint, equals(Breakpoint.compact));
    });

    testWidgets('respects listenWhen filter condition', (tester) async {
      int listenerCalls = 0;

      await tester.pumpAdaptive(
        child: BlocProvider<TestNotificationCubit>.value(
          value: cubit,
          child: AdaptiveBlocListener<TestNotificationCubit,
              TestNotificationState>(
            listenWhen: (prev, curr) => prev.count != curr.count,
            listener: (context, state) {
              listenerCalls++;
            },
            child: const Text('Filtered Listener'),
          ),
        ),
      );

      // Emitting message only (count unchanged) should NOT trigger listener
      cubit.emitMessage('New Message');
      await tester.pump();
      expect(listenerCalls, equals(0));

      // Incrementing count SHOULD trigger listener
      cubit.increment();
      await tester.pump();
      expect(listenerCalls, equals(1));
    });

    testWidgets(
        'cancels subscription and does not fire when widget is unmounted',
        (tester) async {
      int listenerCalls = 0;

      await tester.pumpAdaptive(
        child: BlocProvider<TestNotificationCubit>.value(
          value: cubit,
          child: AdaptiveBlocListener<TestNotificationCubit,
              TestNotificationState>(
            listener: (context, state) => listenerCalls++,
            child: const Text('Mountable'),
          ),
        ),
      );

      cubit.increment();
      await tester.pump();
      expect(listenerCalls, equals(1));

      // Unmount the listener
      await tester.pumpAdaptive(child: const Text('Unmounted'));
      await tester.pumpAndSettle();

      // Emit state on cubit after unmount
      cubit.increment();
      await tester.pump();

      // Listener must not be called again
      expect(listenerCalls, equals(1));
    });
  });

  group('AdaptiveBlocConsumer & AdaptiveCubitConsumer', () {
    late TestNotificationCubit cubit;

    setUp(() {
      cubit = TestNotificationCubit();
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('combines listener and builder reactively', (tester) async {
      final List<String> received = [];

      await tester.pumpAdaptive(
        child: BlocProvider<TestNotificationCubit>.value(
          value: cubit,
          child: AdaptiveBlocConsumer<TestNotificationCubit,
              TestNotificationState>(
            listener: (context, state) {
              received.add(state.message);
            },
            builder: (context, state) {
              return Text('Count: ${state.count}');
            },
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);
      expect(received, isEmpty);

      cubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('Count: 1'), findsOneWidget);
      expect(received, equals(['initial']));
    });

    testWidgets(
        'AdaptiveBlocConsumer.adaptive supplies layout data to both builder and listener',
        (tester) async {
      Breakpoint? listenedBreakpoint;
      String? listenedMessage;

      await tester.pumpAdaptive(
        size: const Size(1024.0, 768.0), // expanded
        child: BlocProvider<TestNotificationCubit>.value(
          value: cubit,
          child: AdaptiveBlocConsumer<TestNotificationCubit,
              TestNotificationState>.adaptive(
            adaptiveListener: (context, state, layout) {
              listenedBreakpoint = layout.containerBreakpoint;
              listenedMessage = state.message;
            },
            adaptiveBuilder: (context, state, layout) {
              return Text(
                'State: ${state.message} on ${layout.containerBreakpoint.name}',
              );
            },
          ),
        ),
      );

      expect(find.text('State: initial on expanded'), findsOneWidget);
      expect(listenedBreakpoint, isNull);

      cubit.emitMessage('DesktopAlert');
      await tester.pumpAndSettle();

      expect(find.text('State: DesktopAlert on expanded'), findsOneWidget);
      expect(listenedBreakpoint, equals(Breakpoint.expanded));
      expect(listenedMessage, equals('DesktopAlert'));
    });

    testWidgets('respects buildWhen and listenWhen independently',
        (tester) async {
      int buildCount = 0;
      int listenCount = 0;

      await tester.pumpAdaptive(
        child: BlocProvider<TestNotificationCubit>.value(
          value: cubit,
          child: AdaptiveBlocConsumer<TestNotificationCubit,
              TestNotificationState>(
            buildWhen: (prev, curr) => prev.count != curr.count,
            listenWhen: (prev, curr) => prev.message != curr.message,
            listener: (context, state) => listenCount++,
            builder: (context, state) {
              buildCount++;
              return Text('Builds: $buildCount');
            },
          ),
        ),
      );

      expect(buildCount, equals(1));
      expect(listenCount, equals(0));

      // Emit message only -> triggers listener but NOT builder
      cubit.emitMessage('New Msg');
      await tester.pump();

      expect(buildCount, equals(1));
      expect(listenCount, equals(1));

      // Increment count only -> triggers builder but NOT listener
      cubit.increment();
      await tester.pump();

      expect(buildCount, equals(2));
      expect(listenCount, equals(1));
    });
  });
}
