// ignore_for_file: no_logic_in_create_state
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/adaptive_layout_data.dart';
import 'adaptive_builder.dart';
import 'bloc/adaptive_bloc_types.dart';

/// Base class for responsive stateful widgets with optional native BLoC scoping.
abstract class AdaptiveStatefulWidget extends StatefulWidget {
  const AdaptiveStatefulWidget({super.key});

  /// Defines scoped state providers (e.g. `BlocProvider`, `RepositoryProvider`) injected above this widget.
  List<AdaptiveProviderItem> setProvider() => const [];

  @override
  AdaptiveState<AdaptiveStatefulWidget> createState() => createAdaptiveState();

  /// Creates the mutable responsive state for this widget.
  AdaptiveState<AdaptiveStatefulWidget> createAdaptiveState();
}

/// The state class paired with [AdaptiveStatefulWidget].
abstract class AdaptiveState<T extends AdaptiveStatefulWidget>
    extends State<T> {
  /// Builds the widget with resolved [layout] constraints and responsive metrics.
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout);

  @override
  Widget build(BuildContext context) {
    final List<AdaptiveProviderItem> providers = widget.setProvider();
    final Widget content = AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) =>
          buildAdaptive(ctx, layout),
    );

    if (providers.isNotEmpty) {
      return MultiBlocProvider(
        providers: providers,
        child: content,
      );
    }

    return content;
  }
}
