import 'package:flutter/material.dart';

import '../../core/adaptive_layout_data.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';
import '../layout/adaptive_scroll_view.dart';

/// A production-quality adaptive form container that wraps Flutter's native [Form]
/// with responsive constraint clamping ([maxContentWidth]), optional keyboard-safe
/// scrolling, automatic field spacing, and [AdaptiveThemeData] integration.
class AdaptiveForm extends StatefulWidget {
  const AdaptiveForm({
    super.key,
    this.formKey,
    this.child,
    this.children,
    this.spacing = 16.0,
    this.maxContentWidth = 720.0,
    this.scrollable = false,
    this.padding,
    this.autovalidateMode,
    this.onChanged,
    this.canPop,
    this.onPopInvokedWithResult,
  }) : assert(child != null || children != null,
            'Either child or children must be provided to AdaptiveForm');

  /// Optional explicit [GlobalKey<FormState>] provided by the developer.
  /// If null, an internal key is managed by [AdaptiveFormState].
  final GlobalKey<FormState>? formKey;

  /// Single child widget for the form.
  final Widget? child;

  /// List of form field children. Automatically spaced using [spacing] if [child] is null.
  final List<Widget>? children;

  /// Vertical spacing between form fields when [children] is provided.
  final double spacing;

  /// Maximum content width to clamp the form on wider viewports (default 720dp).
  /// If null, the form spans the full available width.
  final double? maxContentWidth;

  /// Whether to wrap the form in an [AdaptiveScrollView] for safe scrolling and
  /// keyboard avoidance.
  final bool scrollable;

  /// Padding applied around the form content.
  final EdgeInsetsGeometry? padding;

  /// Used to configure automatic validation of form fields.
  final AutovalidateMode? autovalidateMode;

  /// Called when one of the form fields changes.
  final VoidCallback? onChanged;

  /// Determines whether the form can be popped.
  final bool? canPop;

  /// Called when a pop invocation is executed.
  final PopInvokedWithResultCallback<Object?>? onPopInvokedWithResult;

  /// Returns the closest [FormState] above the given context.
  static FormState? of(BuildContext context) => Form.of(context);

  @override
  State<AdaptiveForm> createState() => AdaptiveFormState();
}

/// State for an [AdaptiveForm], exposing programmatic validation, saving, and reset methods.
class AdaptiveFormState extends State<AdaptiveForm> {
  late GlobalKey<FormState> _internalKey;

  GlobalKey<FormState> get _effectiveKey => widget.formKey ?? _internalKey;

  /// The underlying [FormState].
  FormState? get currentState => _effectiveKey.currentState;

  @override
  void initState() {
    super.initState();
    _internalKey = GlobalKey<FormState>();
  }

  /// Validates all descendant form fields that have validators.
  bool validate() => currentState?.validate() ?? false;

  /// Saves all descendant form fields via their onSaved callbacks.
  void save() => currentState?.save();

  /// Resets all descendant form fields to their initial values.
  void reset() => currentState?.reset();

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final EdgeInsetsGeometry effectivePadding = widget.padding ??
            (layout.isCompact
                ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)
                : const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0));

        Widget formContent;
        if (widget.children != null) {
          formContent = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < widget.children!.length; i++) ...[
                if (i > 0) SizedBox(height: widget.spacing),
                widget.children![i],
              ],
            ],
          );
        } else {
          formContent = widget.child!;
        }

        Widget paddedContent = Padding(
          padding: effectivePadding,
          child: formContent,
        );

        if (widget.maxContentWidth != null) {
          paddedContent = Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.maxContentWidth!),
              child: paddedContent,
            ),
          );
        }

        Widget boundedContent = Form(
          key: _effectiveKey,
          autovalidateMode: widget.autovalidateMode,
          onChanged: widget.onChanged,
          canPop: widget.canPop,
          onPopInvokedWithResult: widget.onPopInvokedWithResult,
          child: paddedContent,
        );

        if (widget.scrollable) {
          return AdaptiveScrollView(
            centerContent: widget.maxContentWidth != null,
            maxContentWidth: widget.maxContentWidth ?? 720.0,
            child: boundedContent,
          );
        }

        return boundedContent;
      },
    );
  }
}
