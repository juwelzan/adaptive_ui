import 'package:flutter/material.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../theme/adaptive_component_themes.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';

/// Type alias for [DropdownMenuItem] used within [AdaptiveDropdownField].
typedef AdaptiveDropdownMenuItem<T> = DropdownMenuItem<T>;

/// Type alias for [AdaptiveDropdownField] matching Flutter's [DropdownButtonFormField] naming.
typedef AdaptiveDropdownFormField<T> = AdaptiveDropdownField<T>;

/// A responsive, accessible dropdown form field that integrates with Flutter's [Form]
/// and [FormField] validation engine while adopting [AdaptiveThemeData] design tokens.
class AdaptiveDropdownField<T> extends StatelessWidget {
  const AdaptiveDropdownField({
    super.key,
    required this.items,
    this.value,
    this.initialValue,
    this.onChanged,
    this.hint,
    this.hintText,
    this.disabledHint,
    this.labelText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.icon,
    this.iconSize = 24.0,
    this.isExpanded = true,
    this.isDense = false,
    this.elevation = 8,
    this.style,
    this.dropdownColor,
    this.menuMaxHeight,
    this.focusNode,
    this.autofocus = false,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.enabled = true,
    this.required = false,
    this.decoration,
    this.filled,
    this.fillColor,
    this.borderRadius,
    this.border,
    this.contentPadding,
  });

  /// The list of items the user can select from.
  final List<DropdownMenuItem<T>>? items;

  /// The currently selected or initial value.
  final T? value;

  /// The initial value of the form field.
  final T? initialValue;

  /// Called when the user selects an item.
  final ValueChanged<T?>? onChanged;

  /// A placeholder widget to display when [value] is null.
  final Widget? hint;

  /// Optional text hint displayed when [hint] is null and [value] is null.
  final String? hintText;

  /// A message to display when the dropdown is disabled.
  final Widget? disabledHint;

  /// Optional label text displayed on or above the field.
  final String? labelText;

  /// Optional helper text displayed below the field.
  final String? helperText;

  /// Optional error text displayed below the field.
  final String? errorText;

  /// Leading icon displayed inside the field.
  final Widget? prefixIcon;

  /// Custom trailing dropdown arrow icon.
  final Widget? icon;

  /// Size of the dropdown arrow icon.
  final double iconSize;

  /// Set true if the dropdown button should take up the full available width.
  final bool isExpanded;

  /// Reduce the field's internal vertical padding.
  final bool isDense;

  /// Z-coordinate at which to place the popup menu.
  final int elevation;

  /// Text style applied to the selected item.
  final TextStyle? style;

  /// Background color of the popup menu.
  final Color? dropdownColor;

  /// The maximum height of the menu before scrolling occurs.
  final double? menuMaxHeight;

  /// Keyboard focus node.
  final FocusNode? focusNode;

  /// Whether the dropdown should request focus on mount.
  final bool autofocus;

  /// Validation function called by [FormState.validate].
  final FormFieldValidator<T>? validator;

  /// Called when the enclosing [Form] is saved via [FormState.save].
  final FormFieldSetter<T>? onSaved;

  /// Automatic validation mode.
  final AutovalidateMode? autovalidateMode;

  /// Whether the dropdown field is interactive.
  final bool enabled;

  /// Whether a selection is required. Appends an asterisk to [labelText].
  final bool required;

  /// Custom input decoration override.
  final InputDecoration? decoration;

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
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveThemeData theme = AdaptiveScope.themeOf(ctx);
        final AdaptiveInputThemeData inputTheme = theme.inputTheme;

        final double minHeight = layout.isCompact
            ? (inputTheme.minHeightCompact ?? 48.0)
            : (inputTheme.minHeightRegular ?? 42.0);

        final BorderRadius effectiveBorderRadius = borderRadius ??
            inputTheme.borderRadius ??
            theme.radii.toBorderRadius(theme.radii.md);

        final Color effectiveFillColor = fillColor ??
            inputTheme.fillColor ??
            theme.colors.surfaceVariant.withValues(alpha: 0.4);

        final bool effectiveFilled = filled ?? inputTheme.filled ?? true;

        final Color normalBorderColor =
            inputTheme.borderColor ?? theme.colors.outline;
        final Color focusBorderColor =
            inputTheme.focusedBorderColor ?? theme.colors.primary;
        final Color errBorderColor =
            inputTheme.errorBorderColor ?? theme.colors.error;

        final double normalBorderWidth = inputTheme.borderWidth ?? 1.0;
        final double focusBorderWidth = inputTheme.focusedBorderWidth ?? 2.0;

        final EdgeInsetsGeometry effectivePadding = contentPadding ??
            inputTheme.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

        final String? effectiveLabel =
            required && labelText != null ? '$labelText *' : labelText;

        final Widget? effectiveHint = hint ??
            (hintText != null
                ? Text(hintText!, style: inputTheme.hintStyle)
                : null);

        final InputDecoration defaultDecoration = InputDecoration(
          labelText: effectiveLabel,
          helperText: helperText,
          errorText: errorText,
          prefixIcon: prefixIcon,
          filled: effectiveFilled,
          fillColor: effectiveFillColor,
          hintStyle: inputTheme.hintStyle,
          labelStyle: inputTheme.labelStyle,
          errorStyle: inputTheme.errorStyle,
          helperStyle: inputTheme.helperStyle,
          prefixIconColor: inputTheme.prefixIconColor,
          suffixIconColor: inputTheme.suffixIconColor,
          border: border ??
              OutlineInputBorder(
                borderRadius: effectiveBorderRadius,
                borderSide: BorderSide(
                    color: normalBorderColor, width: normalBorderWidth),
              ),
          enabledBorder: border ??
              OutlineInputBorder(
                borderRadius: effectiveBorderRadius,
                borderSide: BorderSide(
                  color: inputTheme.disabledBorderColor != null && !enabled
                      ? inputTheme.disabledBorderColor!
                      : normalBorderColor,
                  width: normalBorderWidth,
                ),
              ),
          focusedBorder: border ??
              OutlineInputBorder(
                borderRadius: effectiveBorderRadius,
                borderSide: BorderSide(
                    color: focusBorderColor, width: focusBorderWidth),
              ),
          errorBorder: border ??
              OutlineInputBorder(
                borderRadius: effectiveBorderRadius,
                borderSide:
                    BorderSide(color: errBorderColor, width: normalBorderWidth),
              ),
          focusedErrorBorder: border ??
              OutlineInputBorder(
                borderRadius: effectiveBorderRadius,
                borderSide: BorderSide(
                  color: inputTheme.focusedErrorBorderColor ?? errBorderColor,
                  width: focusBorderWidth,
                ),
              ),
          contentPadding: effectivePadding,
        );

        final InputDecoration effectiveDecoration = (decoration != null
                ? decoration!.copyWith(
                    labelText: decoration!.labelText ?? effectiveLabel,
                    helperText: decoration!.helperText ?? helperText,
                    errorText: decoration!.errorText ?? errorText,
                    prefixIcon: decoration!.prefixIcon ?? prefixIcon,
                  )
                : defaultDecoration)
            .applyDefaults(Theme.of(ctx).inputDecorationTheme);

        return Semantics(
          hint: required ? 'Required' : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: DropdownButtonFormField<T>(
              initialValue: initialValue ?? value,
              items: items,
              onChanged: enabled ? onChanged : null,
              hint: effectiveHint,
              disabledHint: disabledHint,
              decoration: effectiveDecoration,
              icon: icon,
              iconSize: iconSize,
              isExpanded: isExpanded,
              isDense: isDense,
              elevation: elevation,
              style: style,
              dropdownColor: dropdownColor ?? theme.colors.surface,
              menuMaxHeight: menuMaxHeight,
              focusNode: focusNode,
              autofocus: autofocus,
              validator: validator,
              onSaved: onSaved,
              autovalidateMode: autovalidateMode,
            ),
          ),
        );
      },
    );
  }
}
