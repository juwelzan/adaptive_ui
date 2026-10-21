// ignore_for_file: no_logic_in_create_state
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/adaptive_layout_data.dart';
import 'adaptive_builder.dart';
import 'bloc/adaptive_bloc_types.dart';

/// Base class for responsive stateful widgets with optional native BLoC scoping.
///
/// Developers can define state providers at the widget level by overriding [setProvider].
///
/// Providers configured in [setProvider] are instantiated once in [AdaptiveState.initState]
/// and cached for the lifetime of this widget element. They are not re-evaluated
/// during ordinary rebuilds (e.g. from [State.setState]), preventing state resets
/// or memory churn.
abstract class AdaptiveStatefulWidget extends StatefulWidget {
  const AdaptiveStatefulWidget({super.key});

  /// Defines scoped state providers (e.g. `BlocProvider`, `RepositoryProvider`) injected above this widget.
  ///
  /// Evaluated once during [AdaptiveState.initState]. Instances created via `create`
  /// are owned by this widget and automatically closed when unmounted. Instances provided
  /// via `.value` are not closed.
  List<AdaptiveProviderItem> setProvider() => const [];

  /// Determines whether [setProvider] should be re-evaluated when the parent rebuilds
  /// with a new widget configuration.
  ///
  /// Defaults to `false` to preserve active BLoC/Cubit state and subscriptions.
  /// Override this if your provider definitions depend on constructor arguments that change.
  bool updateShouldNotifyProviders(
          covariant AdaptiveStatefulWidget oldWidget) =>
      false;

  @override
  State<AdaptiveStatefulWidget> createState() => createAdaptiveState();

  /// Creates the mutable state for this widget.
  ///
  /// Subclasses should return an instance of [AdaptiveState].
  State<AdaptiveStatefulWidget> createAdaptiveState();
}

/// The state class paired with [AdaptiveStatefulWidget].
///
/// Preserves standard Flutter lifecycle semantics ([initState], [didChangeDependencies],
/// [didUpdateWidget], [dispose], [setState]) while managing responsive layout resolution
/// and cached provider scoping.
abstract class AdaptiveState<T extends AdaptiveStatefulWidget>
    extends State<T> {
  List<AdaptiveProviderItem>? _cachedProviders;

  /// The active providers registered by this stateful widget.
  ///
  /// Cached during [initState] via [widget.setProvider].
  List<AdaptiveProviderItem> get providers => _cachedProviders ?? const [];

  @override
  void initState() {
    super.initState();
    _cachedProviders = widget.setProvider();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.updateShouldNotifyProviders(oldWidget)) {
      _cachedProviders = widget.setProvider();
    }
  }

  /// Manually forces re-evaluation of [AdaptiveStatefulWidget.setProvider].
  ///
  /// Use with caution: re-evaluating providers creates new BLoC instances and
  /// closes previous owned instances, resetting descendant state.
  @protected
  void reconfigureProviders() {
    setState(() {
      _cachedProviders = widget.setProvider();
    });
  }

  /// Builds the widget with resolved [layout] constraints and responsive metrics.
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout);

  @override
  Widget build(BuildContext context) {
    final List<AdaptiveProviderItem> currentProviders = providers;
    final Widget content = AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) =>
          buildAdaptive(ctx, layout),
    );

    if (currentProviders.isNotEmpty) {
      return MultiBlocProvider(
        providers: currentProviders,
        child: content,
      );
    }

    return content;
  }
}
