import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

class SampleState {
  const SampleState({required this.name, required this.count});
  final String name;
  final int count;

  SampleState copyWith({String? name, int? count}) {
    return SampleState(
      name: name ?? this.name,
      count: count ?? this.count,
    );
  }
}

class SampleCubit extends Cubit<SampleState> {
  SampleCubit() : super(const SampleState(name: 'Alice', count: 0));

  void increment() => emit(state.copyWith(count: state.count + 1));
  void setName(String newName) => emit(state.copyWith(name: newName));
}

class SampleScreen extends AdaptiveStatelessWidget {
  const SampleScreen({super.key});

  @override
  List<AdaptiveProviderItem> setProvider() => [
        BlocProvider<SampleCubit>(
          create: (_) => SampleCubit(),
        ),
      ];

  @override
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout) {
    return Column(
      children: [
        AdaptiveBlocSelector<SampleCubit, SampleState, String>(
          selector: (state) => state.name,
          builder: (ctx, name) => Text('Name: $name'),
        ),
        AdaptiveBlocSelector<SampleCubit, SampleState, int>(
          selector: (state) => state.count,
          builder: (ctx, count) => Text('Count: $count'),
        ),
      ],
    );
  }
}

void main() {
  group('Adaptive BLoC Integration', () {
    testWidgets(
        'setProvider provides Cubit and AdaptiveBlocSelector updates reactively',
        (tester) async {
      await tester.pumpAdaptive(
        child: const SampleScreen(),
      );

      expect(find.text('Name: Alice'), findsOneWidget);
      expect(find.text('Count: 0'), findsOneWidget);

      final BuildContext context = tester.element(find.text('Name: Alice'));
      final cubit = context.read<SampleCubit>();

      // Update count
      cubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('Name: Alice'), findsOneWidget);
      expect(find.text('Count: 1'), findsOneWidget);

      // Update name
      cubit.setName('Bob');
      await tester.pumpAndSettle();

      expect(find.text('Name: Bob'), findsOneWidget);
      expect(find.text('Count: 1'), findsOneWidget);
    });
  });
}
