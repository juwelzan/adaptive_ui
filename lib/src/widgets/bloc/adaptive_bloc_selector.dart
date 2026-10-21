import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/adaptive_context.dart';
import '../../core/adaptive_layout_data.dart';

/// Builder signature receiving the selected value and resolved [AdaptiveLayoutData].
typedef AdaptiveBlocSelectorBuilder<T> = Widget Function(
  BuildContext context,
  T value,
  AdaptiveLayoutData layout,
);

/// A reactive widget that rebuilds strictly when a targeted state slice changes,
/// preventing full-screen layout recalculations.
class AdaptiveBlocSelector<B extends StateStreamable<S>, S, T>
    extends StatelessWidget {
  const AdaptiveBlocSelector({
    super.key,
    required this.selector,
    required BlocWidgetBuilder<T> builder,
    this.bloc,
  })  : _builder = builder,
        _adaptiveBuilder = null;

  /// Creates a selector that supplies both the selected state slice and the current [AdaptiveLayoutData].
  const AdaptiveBlocSelector.adaptive({
    super.key,
    required this.selector,
    required AdaptiveBlocSelectorBuilder<T> adaptiveBuilder,
    this.bloc,
  })  : _builder = null,
        _adaptiveBuilder = adaptiveBuilder;

  final BlocWidgetSelector<S, T> selector;
  final BlocWidgetBuilder<T>? _builder;
  final AdaptiveBlocSelectorBuilder<T>? _adaptiveBuilder;
  final B? bloc;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<B, S, T>(
      bloc: bloc,
      selector: selector,
      builder: (BuildContext ctx, T stateSlice) {
        final AdaptiveBlocSelectorBuilder<T>? adaptiveB = _adaptiveBuilder;
        if (adaptiveB != null) {
          final AdaptiveLayoutData layout = AdaptiveContext.of(ctx);
          return adaptiveB(ctx, stateSlice, layout);
        }
        return _builder!(ctx, stateSlice);
      },
    );
  }
}
