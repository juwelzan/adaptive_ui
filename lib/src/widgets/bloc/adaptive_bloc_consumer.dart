import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/adaptive_context.dart';
import '../../core/adaptive_layout_data.dart';
import 'adaptive_bloc_builder.dart';
import 'adaptive_bloc_listener.dart';

/// A reactive BLoC consumer that combines listener side-effects with adaptive layout rendering.
class AdaptiveBlocConsumer<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  const AdaptiveBlocConsumer({
    super.key,
    required BlocWidgetListener<S> listener,
    required BlocWidgetBuilder<S> builder,
    this.listenWhen,
    this.buildWhen,
    this.bloc,
  })  : _listener = listener,
        _adaptiveListener = null,
        _builder = builder,
        _adaptiveBuilder = null;

  /// Creates a consumer supplying ambient [AdaptiveLayoutData] to its builder and optional adaptive listener.
  const AdaptiveBlocConsumer.adaptive({
    super.key,
    BlocWidgetListener<S>? listener,
    AdaptiveBlocWidgetListener<S>? adaptiveListener,
    required AdaptiveBlocStateBuilder<S> adaptiveBuilder,
    this.listenWhen,
    this.buildWhen,
    this.bloc,
  })  : assert(listener != null || adaptiveListener != null,
            'Either listener or adaptiveListener must be provided.'),
        _listener = listener,
        _adaptiveListener = adaptiveListener,
        _builder = null,
        _adaptiveBuilder = adaptiveBuilder;

  final BlocWidgetListener<S>? _listener;
  final AdaptiveBlocWidgetListener<S>? _adaptiveListener;
  final BlocWidgetBuilder<S>? _builder;
  final AdaptiveBlocStateBuilder<S>? _adaptiveBuilder;
  final BlocListenerCondition<S>? listenWhen;
  final BlocBuilderCondition<S>? buildWhen;
  final B? bloc;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<B, S>(
      bloc: bloc,
      listener: (BuildContext ctx, S state) {
        final AdaptiveBlocWidgetListener<S>? adaptiveL = _adaptiveListener;
        if (adaptiveL != null) {
          final AdaptiveLayoutData layout = AdaptiveContext.of(ctx);
          adaptiveL(ctx, state, layout);
        } else {
          _listener!(ctx, state);
        }
      },
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

/// Ergonomic alias for [AdaptiveBlocConsumer] targeting [Cubit] state streamables.
typedef AdaptiveCubitConsumer<C extends StateStreamable<S>, S>
    = AdaptiveBlocConsumer<C, S>;
