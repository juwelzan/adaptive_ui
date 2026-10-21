import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/adaptive_layout_data.dart';
import 'adaptive_builder.dart';
import 'bloc/adaptive_bloc_types.dart';

/// Base class for responsive stateless widgets with optional native BLoC scoping.
///
/// Subclasses can override [setProvider] to inject dependencies (such as [BlocProvider]
/// or [RepositoryProvider]) above this widget's subtree without writing repetitive
/// wrapping boilerplate.
///
/// ### Lifecycle and Ownership
/// - Providers configured with `create: (context) => ...` are owned by the provider scope
///   and automatically closed/disposed when this widget is unmounted from the tree.
/// - Providers configured with `value: existingInstance` are externally owned and will
///   **not** be closed when this widget is unmounted.
/// - If [setProvider] returns an empty list (the default), no `MultiBlocProvider` wrapper
///   is inserted into the widget tree, eliminating unnecessary nesting overhead.
abstract class AdaptiveStatelessWidget extends StatelessWidget {
  const AdaptiveStatelessWidget({super.key});

  /// Defines scoped state providers (e.g. `BlocProvider`, `RepositoryProvider`) injected above this widget.
  ///
  /// Subclasses may override this to declare widget-scoped or subtree-scoped BLoC/Cubit/Repository providers.
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
