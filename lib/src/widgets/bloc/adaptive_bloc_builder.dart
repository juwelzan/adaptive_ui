import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/adaptive_context.dart';
import '../../core/adaptive_layout_data.dart';

/// Builder signature receiving the current state and ambient [AdaptiveLayoutData].
typedef AdaptiveBlocStateBuilder<S> = Widget Function(
  BuildContext context,
  S state,
  AdaptiveLayoutData layout,
);

/// A reactive BLoC builder that supports both standard and adaptive layout builders.
class AdaptiveBlocBuilder<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  const AdaptiveBlocBuilder({
    super.key,
    required BlocWidgetBuilder<S> builder,
    this.buildWhen,
    this.bloc,
  })  : _builder = builder,
        _adaptiveBuilder = null;

  /// Creates a builder that supplies both the state and the current [AdaptiveLayoutData].
  const AdaptiveBlocBuilder.adaptive({
    super.key,
    required AdaptiveBlocStateBuilder<S> adaptiveBuilder,
    this.buildWhen,
    this.bloc,
  })  : _builder = null,
        _adaptiveBuilder = adaptiveBuilder;

  final BlocWidgetBuilder<S>? _builder;
  final AdaptiveBlocStateBuilder<S>? _adaptiveBuilder;
  final BlocBuilderCondition<S>? buildWhen;
  final B? bloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      bloc: bloc,
      buildWhen: buildWhen,
      builder: (BuildContext ctx, S state) {
        if (_adaptiveBuilder != null) {
          final AdaptiveLayoutData layout = AdaptiveContext.of(ctx);
          return _adaptiveBuilder(ctx, state, layout);
        }
        return _builder!(ctx, state);
      },
    );
  }
}
