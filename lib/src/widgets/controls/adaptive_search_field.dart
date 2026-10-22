import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../theme/adaptive_component_themes.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';

/// A responsive and accessible search field component featuring an optional debounce timer,
/// clear button, responsive touch sizing, and integration with [AdaptiveThemeData].
class AdaptiveSearchField extends StatefulWidget {
  const AdaptiveSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.debounceDuration,
    this.prefixIcon,
    this.clearIcon,
    this.showClearButton = true,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction = TextInputAction.search,
    this.filled,
    this.fillColor,
    this.borderRadius,
    this.border,
    this.contentPadding,
  });

  /// Controls the text being edited. If null, an internal controller is managed.
  final TextEditingController? controller;

  /// Defines the keyboard focus. If null, an internal focus node is managed.
  final FocusNode? focusNode;

  /// Hint text displayed inside the field.
  final String hintText;

  /// Invoked whenever the query changes (debounced if [debounceDuration] is set).
  final ValueChanged<String>? onChanged;

  /// Invoked when the user submits their search query (e.g. presses enter).
  final ValueChanged<String>? onSubmitted;

  /// Invoked when the user clears the search query via the clear icon.
  final VoidCallback? onClear;

  /// Optional debounce duration to throttle [onChanged] calls while typing.
  final Duration? debounceDuration;

  /// Custom leading search icon. Defaults to [Icons.search].
  final Widget? prefixIcon;

  /// Custom trailing clear icon. Defaults to [Icons.clear].
  final Widget? clearIcon;

  /// Whether to show the clear button when the query is non-empty.
  final bool showClearButton;

  /// Whether the search field is interactive.
  final bool enabled;

  /// Whether the field should request focus immediately.
  final bool autofocus;

  /// Action button on software keyboards. Defaults to [TextInputAction.search].
  final TextInputAction textInputAction;

  /// Explicit filled toggle override.
  final bool? filled;

  /// Explicit fill color override.
  final Color? fillColor;

  /// Explicit border radius override.
  final BorderRadius? borderRadius;

  /// Explicit border override.
  final InputBorder? border;

  /// Explicit content padding override.
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<AdaptiveSearchField> createState() => _AdaptiveSearchFieldState();
}

class _AdaptiveSearchFieldState extends State<AdaptiveSearchField> {
  TextEditingController? _internalController;
  Timer? _debounceTimer;
  late bool _hasText;

  TextEditingController get _effectiveController =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _hasText = _effectiveController.text.isNotEmpty;
    _effectiveController.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(AdaptiveSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleTextChange);
      if (oldWidget.controller == null) {
        _internalController?.dispose();
        _internalController = null;
      }
      _effectiveController.addListener(_handleTextChange);
      _hasText = _effectiveController.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _effectiveController.removeListener(_handleTextChange);
    _internalController?.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final bool hasText = _effectiveController.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _onQueryChanged(String query) {
    if (widget.debounceDuration != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceDuration!, () {
        if (mounted) {
          widget.onChanged?.call(query);
        }
      });
    } else {
      widget.onChanged?.call(query);
    }
  }

  void _clearQuery() {
    _debounceTimer?.cancel();
    _effectiveController.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveThemeData theme = AdaptiveScope.themeOf(ctx);
        final AdaptiveInputThemeData inputTheme = theme.inputTheme;

        final double minHeight = layout.isCompact
            ? (inputTheme.minHeightCompact ?? 48.0)
            : (inputTheme.minHeightRegular ?? 42.0);

        final BorderRadius effectiveBorderRadius = widget.borderRadius ??
            inputTheme.borderRadius ??
            theme.radii.toBorderRadius(theme.radii.full);

        final Color effectiveFillColor = widget.fillColor ??
            inputTheme.fillColor ??
            theme.colors.surfaceVariant.withValues(alpha: 0.45);

        final bool effectiveFilled = widget.filled ?? inputTheme.filled ?? true;

        final Color normalBorderColor =
            inputTheme.borderColor ?? theme.colors.outline;
        final Color focusBorderColor =
            inputTheme.focusedBorderColor ?? theme.colors.primary;

        final double normalBorderWidth = inputTheme.borderWidth ?? 1.0;
        final double focusBorderWidth = inputTheme.focusedBorderWidth ?? 2.0;

        final EdgeInsetsGeometry effectivePadding = widget.contentPadding ??
            inputTheme.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0);

        final Widget? clearButton = (widget.showClearButton && _hasText)
            ? Semantics(
                label: 'Clear search',
                button: true,
                child: IconButton(
                  icon: widget.clearIcon ??
                      Icon(
                        Icons.clear,
                        size: 18.0,
                        color: inputTheme.suffixIconColor ??
                            theme.colors.onSurfaceVariant,
                      ),
                  onPressed: widget.enabled ? _clearQuery : null,
                  splashRadius: 18.0,
                  tooltip: 'Clear',
                ),
              )
            : null;

        final InputDecoration decoration = InputDecoration(
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon ??
              Icon(
                Icons.search,
                color:
                    inputTheme.prefixIconColor ?? theme.colors.onSurfaceVariant,
              ),
          suffixIcon: clearButton,
          filled: effectiveFilled,
          fillColor: effectiveFillColor,
          hintStyle: inputTheme.hintStyle,
          border: widget.border ??
              OutlineInputBorder(
                borderRadius: effectiveBorderRadius,
                borderSide: BorderSide(
                    color: normalBorderColor, width: normalBorderWidth),
              ),
          enabledBorder: widget.border ??
              OutlineInputBorder(
                borderRadius: effectiveBorderRadius,
                borderSide: BorderSide(
                    color: normalBorderColor, width: normalBorderWidth),
              ),
          focusedBorder: widget.border ??
              OutlineInputBorder(
                borderRadius: effectiveBorderRadius,
                borderSide: BorderSide(
                    color: focusBorderColor, width: focusBorderWidth),
              ),
          contentPadding: effectivePadding,
        ).applyDefaults(Theme.of(ctx).inputDecorationTheme);

        return Semantics(
          textField: true,
          label: widget.hintText,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: TextField(
              controller: _effectiveController,
              focusNode: widget.focusNode,
              decoration: decoration,
              textInputAction: widget.textInputAction,
              onChanged: _onQueryChanged,
              onSubmitted: widget.onSubmitted,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              maxLines: 1,
            ),
          ),
        );
      },
    );
  }
}
