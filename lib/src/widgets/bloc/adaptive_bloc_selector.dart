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
/// preventing full-screen layout recalculations and unnecessary child rebuilds.
///
/// ### Equality Semantics
/// [AdaptiveBlocSelector] relies on Dart's standard `==` equality operator between
/// successive evaluated slices returned by [selector].
/// - If [selector] produces a value equal (`==`) to the previous value, the [builder]
///   is **not** called.
/// - When unrelated state fields in [S] change, this widget remains unaffected and does
///   not rebuild.
/// - Unrelated siblings in the widget tree do not rebuild when this selector updates.
///
/// For optimal performance, [T] should be an immutable value type (such as [int],
/// [String], [bool], a Dart 3 Record, or an object implementing value equality via `Equatable`).
class AdaptiveBlocSelector<B extends StateStreamable<S>, S, T>
    extends StatelessWidget {
  const AdaptiveBlocSelector({
    super.key,
    required this.selector,
    required BlocWidgetBuilder<T> builder,
    this.bloc,
  })  : _builder = builder,
        _adaptiveBuilder = null;

  /// Creates a selector that supplies both the selected state slice and ambient [AdaptiveLayoutData].
  ///
  /// Use this constructor when rendering of the selected slice depends on responsive layout
  /// metrics (e.g. breakpoint, columns, readable line bounds).
  const AdaptiveBlocSelector.adaptive({
    super.key,
    required this.selector,
    required AdaptiveBlocSelectorBuilder<T> adaptiveBuilder,
    this.bloc,
  })  : _builder = null,
        _adaptiveBuilder = adaptiveBuilder;

  /// Selector function extracting a targeted slice [T] from state [S].
  final BlocWidgetSelector<S, T> selector;

  /// Builder invoked when the selected value changes.
  final BlocWidgetBuilder<T>? _builder;

  /// Adaptive builder receiving both the selected value and [AdaptiveLayoutData].
  final AdaptiveBlocSelectorBuilder<T>? _adaptiveBuilder;

  /// The optional [B] instance. If omitted, looked up via [BuildContext].
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

/// Ergonomic alias for [AdaptiveBlocSelector] targeting [Cubit] state streamables.
typedef AdaptiveCubitSelector<C extends StateStreamable<S>, S, T>
    = AdaptiveBlocSelector<C, S, T>;
