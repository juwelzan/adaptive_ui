import 'package:flutter/widgets.dart';

import '../../core/adaptive_breakpoints.dart';
import '../../core/adaptive_context.dart';
import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';

/// Signature for slot-based layout builders that consume [AdaptiveLayoutData].
typedef AdaptiveLayoutSlotBuilder = Widget Function(
  BuildContext context,
  AdaptiveLayoutData layout,
);

/// Signature for layout builders consuming [AdaptiveLayoutData] alongside an optional static [child].
typedef AdaptiveLayoutWidgetBuilder = Widget Function(
  BuildContext context,
  AdaptiveLayoutData layout,
  Widget? child,
);

/// A declarative, constraint-driven responsive widget that selects the appropriate
/// layout slot based on parent constraints and active breakpoints.
///
/// If a specific breakpoint slot is omitted, [AdaptiveLayoutBuilder] falls back
/// gracefully to adjacent or smaller breakpoint handlers:
/// - [extraLarge] -> [large] -> [expanded] -> [medium] -> [compact] -> [fallback] -> [builder]
/// - [large] -> [expanded] -> [medium] -> [compact] -> [fallback] -> [builder]
/// - [expanded] -> [medium] -> [compact] -> [fallback] -> [builder]
/// - [medium] -> [compact] -> [fallback] -> [builder]
/// - [compact] -> [medium] -> [fallback] -> [builder]
///
/// For performance optimization, an optional [child] can be passed to prevent
/// expensive subtrees from rebuilding when parent dimensions change.
///
/// Local breakpoint configurations can be supplied via [breakpoints] to override
/// the ambient scope for this specific component subtree.
class AdaptiveLayoutBuilder extends StatefulWidget {
  /// Creates a declarative responsive layout builder.
  const AdaptiveLayoutBuilder({
    super.key,
    this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
    this.fallback,
    this.builder,
    this.child,
    this.breakpoints,
    this.preserveState = false,
  }) : assert(
          compact != null ||
              medium != null ||
              expanded != null ||
              large != null ||
              extraLarge != null ||
              fallback != null ||
              builder != null,
          'AdaptiveLayoutBuilder requires at least one breakpoint builder, fallback, or general builder.',
        );

  /// Builder invoked when container width falls within [Breakpoint.compact].
  final AdaptiveLayoutSlotBuilder? compact;

  /// Builder invoked when container width falls within [Breakpoint.medium].
  final AdaptiveLayoutSlotBuilder? medium;

  /// Builder invoked when container width falls within [Breakpoint.expanded].
  final AdaptiveLayoutSlotBuilder? expanded;

  /// Builder invoked when container width falls within [Breakpoint.large].
  final AdaptiveLayoutSlotBuilder? large;

  /// Builder invoked when container width falls within [Breakpoint.extraLarge].
  final AdaptiveLayoutSlotBuilder? extraLarge;

  /// Fallback builder invoked when no matching breakpoint slot is provided.
  final AdaptiveLayoutSlotBuilder? fallback;

  /// General builder invoked when no slot is selected or to consume the static [child].
  final AdaptiveLayoutWidgetBuilder? builder;

  /// Optional static child widget passed to [builder] to avoid rebuilding expensive subtrees.
  final Widget? child;

  /// Optional custom breakpoint configuration to override the ambient scope.
  final AdaptiveBreakpoints? breakpoints;

  /// Whether to preserve state of child components across breakpoint layout switches.
  ///
  /// When true, wraps the active slot content in a stable [KeyedSubtree] so that
  /// shared stateful components (such as form inputs, scroll positions, or stateful widgets)
  /// retain their state when parent constraints cross breakpoint thresholds.
  final bool preserveState;

  Widget _selectWidget(
    BuildContext context,
    AdaptiveLayoutData layout, [
    Widget? effectiveChild,
  ]) {
    AdaptiveLayoutSlotBuilder? selectedBuilder;

    switch (layout.containerBreakpoint) {
      case Breakpoint.compact:
        selectedBuilder = compact ?? medium ?? expanded ?? large ?? extraLarge;
        break;
      case Breakpoint.medium:
        selectedBuilder = medium ?? compact ?? expanded ?? large ?? extraLarge;
        break;
      case Breakpoint.expanded:
        selectedBuilder = expanded ?? medium ?? compact ?? large ?? extraLarge;
        break;
      case Breakpoint.large:
        selectedBuilder = large ?? expanded ?? medium ?? compact ?? extraLarge;
        break;
      case Breakpoint.extraLarge:
        selectedBuilder = extraLarge ?? large ?? expanded ?? medium ?? compact;
        break;
    }

    if (selectedBuilder != null) {
      return selectedBuilder(context, layout);
    }

    if (fallback != null) {
      return fallback!(context, layout);
    }

    if (builder != null) {
      return builder!(context, layout, effectiveChild ?? child);
    }

    return const SizedBox.shrink();
  }

  @override
  State<AdaptiveLayoutBuilder> createState() => _AdaptiveLayoutBuilderState();
}

class _AdaptiveLayoutBuilderState extends State<AdaptiveLayoutBuilder> {
  final GlobalKey _stateKey = GlobalKey();
  final GlobalKey _childKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final AdaptiveLayoutData layout = AdaptiveContext.resolve(
          context,
          constraints,
          breakpoints: widget.breakpoints,
        );

        final AdaptiveScope? scope = AdaptiveScope.maybeOf(context);

        Widget? effectiveChild = widget.child;
        if (widget.preserveState && effectiveChild != null) {
          effectiveChild = KeyedSubtree(key: _childKey, child: effectiveChild);
        }

        Widget content = widget._selectWidget(context, layout, effectiveChild);

        if (widget.preserveState) {
          content = KeyedSubtree(key: _stateKey, child: content);
        }

        if (scope != null) {
          return AdaptiveScope(
            config: widget.breakpoints != null
                ? scope.config.copyWith(breakpoints: widget.breakpoints)
                : scope.config,
            theme: scope.theme,
            layout: layout,
            child: content,
          );
        }

        return content;
      },
    );
  }
}
