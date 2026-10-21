import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

class TestCounterWidget extends AdaptiveStatefulWidget {
  const TestCounterWidget({
    super.key,
    this.onInit,
    this.onDispose,
    this.tag = 'A',
    this.allowProviderUpdate = false,
  });

  final VoidCallback? onInit;
  final VoidCallback? onDispose;
  final String tag;
  final bool allowProviderUpdate;

  @override
  List<AdaptiveProviderItem> setProvider() => [
        RepositoryProvider<String>.value(value: tag),
      ];

  @override
  bool updateShouldNotifyProviders(covariant TestCounterWidget oldWidget) =>
      allowProviderUpdate && oldWidget.tag != tag;

  @override
  AdaptiveState<TestCounterWidget> createAdaptiveState() =>
      _TestCounterWidgetState();
}

class _TestCounterWidgetState extends AdaptiveState<TestCounterWidget> {
  int count = 0;

  @override
  void initState() {
    super.initState();
    widget.onInit?.call();
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  void triggerReconfigure() {
    reconfigureProviders();
  }

  @override
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout) {
    final repoTag = context.read<String>();
    return Column(
      children: [
        Text('Count: $count on ${layout.containerBreakpoint.name}'),
        Text('Repo: $repoTag'),
        Text('ProviderCount: ${providers.length}'),
        ElevatedButton(
          onPressed: () {
            setState(() {
              count++;
            });
          },
          child: const Text('Increment'),
        ),
        ElevatedButton(
          onPressed: triggerReconfigure,
          child: const Text('Reconfigure'),
        ),
      ],
    );
  }
}

void main() {
  group('AdaptiveStatefulWidget Lifecycle & State', () {
    testWidgets('preserves state and rebuilds on setState with layout snapshot',
        (tester) async {
      await tester.pumpAdaptive(
        size: const Size(360.0, 640.0),
        child: const TestCounterWidget(),
      );

      expect(find.text('Count: 0 on compact'), findsOneWidget);
      expect(find.text('Repo: A'), findsOneWidget);

      await tester.tap(find.text('Increment'));
      await tester.pump();

      expect(find.text('Count: 1 on compact'), findsOneWidget);
      expect(find.text('Repo: A'), findsOneWidget);
    });

    testWidgets('calls initState and dispose in correct sequence',
        (tester) async {
      bool initialized = false;
      bool disposed = false;

      await tester.pumpAdaptive(
        child: TestCounterWidget(
          onInit: () => initialized = true,
          onDispose: () => disposed = true,
        ),
      );

      expect(initialized, isTrue);
      expect(disposed, isFalse);
      expect(find.text('ProviderCount: 1'), findsOneWidget);

      // Unmount
      await tester.pumpAdaptive(child: const SizedBox.shrink());

      expect(disposed, isTrue);
    });

    testWidgets(
        'didUpdateWidget does not reconfigure providers when updateShouldNotifyProviders is false',
        (tester) async {
      await tester.pumpAdaptive(
        child: const TestCounterWidget(tag: 'InitialTag'),
      );

      expect(find.text('Repo: InitialTag'), findsOneWidget);

      // Rebuild with new widget instance but allowProviderUpdate = false
      await tester.pumpAdaptive(
        child: const TestCounterWidget(tag: 'UpdatedTag'),
      );

      // Cached provider should remain unchanged
      expect(find.text('Repo: InitialTag'), findsOneWidget);
    });

    testWidgets(
        'didUpdateWidget reconfigures providers when updateShouldNotifyProviders is true',
        (tester) async {
      await tester.pumpAdaptive(
        child: const TestCounterWidget(
          tag: 'InitialTag',
          allowProviderUpdate: true,
        ),
      );

      expect(find.text('Repo: InitialTag'), findsOneWidget);

      // Rebuild with new widget instance and allowProviderUpdate = true
      await tester.pumpAdaptive(
        child: const TestCounterWidget(
          tag: 'UpdatedTag',
          allowProviderUpdate: true,
        ),
      );

      // Providers are reconfigured with new tag
      expect(find.text('Repo: UpdatedTag'), findsOneWidget);
    });

    testWidgets('reconfigureProviders manually forces provider re-evaluation',
        (tester) async {
      await tester.pumpAdaptive(
        child: const TestCounterWidget(tag: 'Tag1'),
      );

      expect(find.text('Repo: Tag1'), findsOneWidget);

      await tester.tap(find.text('Reconfigure'));
      await tester.pump();

      expect(find.text('Repo: Tag1'), findsOneWidget);
    });
  });
}
