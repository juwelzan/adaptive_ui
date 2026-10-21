import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/adaptive_context.dart';
import '../../core/adaptive_layout_data.dart';

/// Listener signature receiving the state and current ambient [AdaptiveLayoutData].
typedef AdaptiveBlocWidgetListener<S> = void Function(
  BuildContext context,
  S state,
  AdaptiveLayoutData layout,
);

/// A reactive BLoC listener executing side effects without rebuilding the UI.
class AdaptiveBlocListener<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  const AdaptiveBlocListener({
    super.key,
    required BlocWidgetListener<S> listener,
    this.listenWhen,
    this.bloc,
    this.child,
  })  : _listener = listener,
        _adaptiveListener = null;

  /// Creates a listener that receives both the emitted state and ambient [AdaptiveLayoutData].
  ///
  /// Useful when executing responsive side-effects (e.g. presenting a bottom sheet on
  /// compact mobile screens vs a dialog on tablet/desktop screens).
  const AdaptiveBlocListener.adaptive({
    super.key,
    required AdaptiveBlocWidgetListener<S> adaptiveListener,
    this.listenWhen,
    this.bloc,
    this.child,
  })  : _listener = null,
        _adaptiveListener = adaptiveListener;

  final BlocWidgetListener<S>? _listener;
  final AdaptiveBlocWidgetListener<S>? _adaptiveListener;
  final BlocListenerCondition<S>? listenWhen;
  final B? bloc;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<B, S>(
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
      child: child,
    );
  }
}

/// Ergonomic alias for [AdaptiveBlocListener] targeting [Cubit] state streamables.
typedef AdaptiveCubitListener<C extends StateStreamable<S>, S>
    = AdaptiveBlocListener<C, S>;

/// Ergonomic alias for [AdaptiveBlocWidgetListener] targeting [Cubit] states.
typedef AdaptiveCubitWidgetListener<S> = AdaptiveBlocWidgetListener<S>;
