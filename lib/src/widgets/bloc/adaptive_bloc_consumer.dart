import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/adaptive_context.dart';
import '../../core/adaptive_layout_data.dart';
import 'adaptive_bloc_builder.dart';

/// A reactive BLoC consumer that combines listener side-effects with adaptive layout rendering.
class AdaptiveBlocConsumer<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  const AdaptiveBlocConsumer({
    super.key,
    required this.listener,
    required BlocWidgetBuilder<S> builder,
    this.listenWhen,
    this.buildWhen,
    this.bloc,
  })  : _builder = builder,
        _adaptiveBuilder = null;

  /// Creates a consumer supplying ambient [AdaptiveLayoutData] to its builder.
  const AdaptiveBlocConsumer.adaptive({
    super.key,
    required this.listener,
    required AdaptiveBlocStateBuilder<S> adaptiveBuilder,
    this.listenWhen,
    this.buildWhen,
    this.bloc,
  })  : _builder = null,
        _adaptiveBuilder = adaptiveBuilder;

  final BlocWidgetListener<S> listener;
  final BlocWidgetBuilder<S>? _builder;
  final AdaptiveBlocStateBuilder<S>? _adaptiveBuilder;
  final BlocListenerCondition<S>? listenWhen;
  final BlocBuilderCondition<S>? buildWhen;
  final B? bloc;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<B, S>(
      bloc: bloc,
      listener: listener,
      listenWhen: listenWhen,
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
