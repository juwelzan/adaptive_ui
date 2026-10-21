import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A reactive BLoC listener executing side effects without rebuilding the UI.
class AdaptiveBlocListener<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  const AdaptiveBlocListener({
    super.key,
    required this.listener,
    this.listenWhen,
    this.bloc,
    this.child,
  });

  final BlocWidgetListener<S> listener;
  final BlocListenerCondition<S>? listenWhen;
  final B? bloc;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<B, S>(
      bloc: bloc,
      listener: listener,
      listenWhen: listenWhen,
      child: child,
    );
  }
}

/// Ergonomic alias for [AdaptiveBlocListener] targeting [Cubit] state streamables.
typedef AdaptiveCubitListener<C extends StateStreamable<S>, S>
    = AdaptiveBlocListener<C, S>;
