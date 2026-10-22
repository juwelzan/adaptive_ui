import 'package:flutter/material.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';

/// A checkbox widget guaranteeing accessible touch targets (>= 48x48dp) on touch displays,
/// supporting optional titles, subtitles, error text, and keyboard navigation.
class AdaptiveCheckbox extends StatelessWidget {
  const AdaptiveCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.errorText,
    this.activeColor,
    this.checkColor,
    this.focusColor,
    this.hoverColor,
    this.tristate = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.shape,
    this.side,
  });

  /// Whether this checkbox is checked, unchecked, or null (indeterminate).
  final bool? value;

  /// Called when the value of the checkbox should change.
  final ValueChanged<bool?>? onChanged;

  /// Optional label widget displayed alongside the checkbox.
  final Widget? title;

  /// Optional secondary description widget displayed below the title.
  final Widget? subtitle;

  /// Optional error text displayed beneath the control.
  final String? errorText;

  /// The color to use when this checkbox is checked.
  final Color? activeColor;

  /// The color to use for the check icon.
  final Color? checkColor;

  /// The color for the checkbox's focus highlight.
  final Color? focusColor;

  /// The color for the checkbox's hover highlight.
  final Color? hoverColor;

  /// If true the checkbox's [value] can be true, false, or null.
  final bool tristate;

  /// Whether the checkbox is interactive.
  final bool enabled;

  /// Whether this widget should request focus on mount.
  final bool autofocus;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Custom shape for the checkbox outline.
  final OutlinedBorder? shape;

  /// Custom border side.
  final BorderSide? side;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveThemeData theme = AdaptiveScope.themeOf(ctx);
        final double touchSize =
            layout.isCompact ? theme.sizing.touchTargetMin : 36.0;

        final Color effectiveActiveColor = activeColor ?? theme.colors.primary;
        final Color effectiveCheckColor = checkColor ?? theme.colors.onPrimary;
        final Color effectiveBorderColor =
            errorText != null ? theme.colors.error : theme.colors.outline;

        final Widget checkboxWidget = ConstrainedBox(
          constraints:
              BoxConstraints(minWidth: touchSize, minHeight: touchSize),
          child: Checkbox(
            value: value,
            onChanged: enabled ? onChanged : null,
            tristate: tristate,
            activeColor: effectiveActiveColor,
            checkColor: effectiveCheckColor,
            focusColor: focusColor,
            hoverColor: hoverColor,
            autofocus: autofocus,
            focusNode: focusNode,
            shape: shape ??
                RoundedRectangleBorder(
                  borderRadius: theme.radii.toBorderRadius(theme.radii.xs),
                ),
            side: side ?? BorderSide(color: effectiveBorderColor, width: 1.5),
          ),
        );

        if (title == null && subtitle == null && errorText == null) {
          return checkboxWidget;
        }

        final Widget content = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            checkboxWidget,
            if (title != null || subtitle != null) ...[
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      DefaultTextStyle.merge(
                        style: theme.typography.bodyMedium.copyWith(
                          color: enabled
                              ? theme.colors.textPrimary
                              : theme.colors.disabled,
                          fontWeight: FontWeight.w500,
                        ),
                        child: title!,
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2.0),
                      DefaultTextStyle.merge(
                        style: theme.typography.bodySmall.copyWith(
                          color: theme.colors.textSecondary,
                        ),
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );

        final Widget interactiveContent = enabled && onChanged != null
            ? InkWell(
                onTap: () {
                  if (tristate) {
                    if (value == null) {
                      onChanged!(true);
                    } else if (value!) {
                      onChanged!(false);
                    } else {
                      onChanged!(null);
                    }
                  } else {
                    onChanged!(!(value ?? false));
                  }
                },
                borderRadius: theme.radii.toBorderRadius(theme.radii.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: content,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: content,
              );

        if (errorText == null) {
          return interactiveContent;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            interactiveContent,
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 4.0),
              child: Text(
                errorText!,
                style: theme.typography.caption.copyWith(
                  color: theme.colors.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A [FormField] wrapper for [AdaptiveCheckbox], providing validation, error rendering,
/// and form state management.
class AdaptiveCheckboxFormField extends FormField<bool> {
  AdaptiveCheckboxFormField({
    super.key,
    super.onSaved,
    super.validator,
    bool initialValue = false,
    super.autovalidateMode,
    super.enabled = true,
    Widget? title,
    Widget? subtitle,
    Color? activeColor,
    Color? checkColor,
    ValueChanged<bool?>? onChanged,
    OutlinedBorder? shape,
    BorderSide? side,
  }) : super(
          initialValue: initialValue,
          builder: (FormFieldState<bool> field) {
            void handleChanged(bool? value) {
              field.didChange(value);
              onChanged?.call(value);
            }

            return AdaptiveCheckbox(
              value: field.value ?? false,
              onChanged: enabled ? handleChanged : null,
              title: title,
              subtitle: subtitle,
              errorText: field.errorText,
              activeColor: activeColor,
              checkColor: checkColor,
              enabled: enabled,
              shape: shape,
              side: side,
            );
          },
        );
}
