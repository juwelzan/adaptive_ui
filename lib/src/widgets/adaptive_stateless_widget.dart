import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/adaptive_layout_data.dart';
import 'adaptive_builder.dart';
import 'bloc/adaptive_bloc_types.dart';

/// Base class for responsive stateless widgets with optional native BLoC scoping.
abstract class AdaptiveStatelessWidget extends StatelessWidget {
  const AdaptiveStatelessWidget({super.key});

  /// Defines scoped state providers (e.g. `BlocProvider`, `RepositoryProvider`) injected above this widget.
  List<AdaptiveProviderItem> setProvider() => const [];

  /// Builds the widget with resolved [layout] constraints and responsive metrics.
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout);

  @override
  Widget build(BuildContext context) {
    final List<AdaptiveProviderItem> providers = setProvider();
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
