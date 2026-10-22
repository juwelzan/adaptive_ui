import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../theme/adaptive_component_themes.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';

/// A production-quality adaptive text input field that integrates with Flutter's
/// [Form] and [FormField] validation engine while responding smoothly to responsive
/// layout constraints and [AdaptiveThemeData].
class AdaptiveTextField extends StatelessWidget {
  const AdaptiveTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.decoration,
    this.hintText,
    this.labelText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.suffixText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.onEditingComplete,
    this.onSubmitted,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.enabled = true,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection,
    this.selectionControls,
    this.autovalidateMode,
    this.required = false,
    this.filled,
    this.fillColor,
    this.borderRadius,
    this.border,
    this.contentPadding,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// An optional initial value. Must be null if [controller] is provided.
  final String? initialValue;

  /// Defines the keyboard focus for this widget.
  final FocusNode? focusNode;

  /// Custom input decoration. If null, a responsive decoration based on
  /// [AdaptiveInputThemeData] and ambient design tokens is generated.
  final InputDecoration? decoration;

  /// Hint text displayed inside the field when empty.
  final String? hintText;

  /// Optional label text displayed on or above the field.
  final String? labelText;

  /// Optional helper text displayed below the field.
  final String? helperText;

  /// Optional error text displayed below the field.
  final String? errorText;

  /// Leading icon displayed inside the field.
  final Widget? prefixIcon;

  /// Trailing icon displayed inside the field.
  final Widget? suffixIcon;

  /// Leading widget displayed before the editable text.
  final Widget? prefix;

  /// Trailing widget displayed after the editable text.
  final Widget? suffix;

  /// Leading text prefix.
  final String? prefixText;

  /// Trailing text suffix.
  final String? suffixText;

  /// Type of keyboard to display for editing.
  final TextInputType? keyboardType;

  /// Action button configuration on software keyboards.
  final TextInputAction? textInputAction;

  /// Capitalization behavior for input.
  final TextCapitalization textCapitalization;

  /// Text style applied to the editable text.
  final TextStyle? style;

  /// Strut style for line height calculation.
  final StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// How the text should be aligned vertically.
  final TextAlignVertical? textAlignVertical;

  /// Text directionality.
  final TextDirection? textDirection;

  /// Whether the text can be edited or is read-only.
  final bool readOnly;

  /// Whether to show the cursor.
  final bool? showCursor;

  /// Whether this field should focus automatically.
  final bool autofocus;

  /// Character used to obscure text when [obscureText] is true.
  final String obscuringCharacter;

  /// Whether to hide the text being edited (e.g. for passwords).
  final bool obscureText;

  /// Whether to enable auto-correction.
  final bool autocorrect;

  /// Configuration for smart dashes.
  final SmartDashesType? smartDashesType;

  /// Configuration for smart quotes.
  final SmartQuotesType? smartQuotesType;

  /// Whether to show input suggestions.
  final bool enableSuggestions;

  /// Maximum lines for multiline input.
  final int? maxLines;

  /// Minimum lines for multiline input.
  final int? minLines;

  /// Whether this widget expands to fill its parent.
  final bool expands;

  /// Maximum character count.
  final int? maxLength;

  /// Enforcement mode when [maxLength] is reached.
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// Called when text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the field is tapped.
  final GestureTapCallback? onTap;

  /// Called when user taps outside the field.
  final TapRegionCallback? onTapOutside;

  /// Called when editing completes.
  final VoidCallback? onEditingComplete;

  /// Deprecated legacy callback for field submission. Use [onFieldSubmitted].
  final ValueChanged<String>? onSubmitted;

  /// Called when the user indicates they are done editing.
  final ValueChanged<String>? onFieldSubmitted;

  /// Called when the enclosing [Form] is saved via [FormState.save].
  final FormFieldSetter<String>? onSaved;

  /// Validation function called by [FormState.validate].
  final FormFieldValidator<String>? validator;

  /// Optional input formatters to filter or transform text.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether the field is enabled for user interaction.
  final bool enabled;

  /// Width of the text cursor.
  final double cursorWidth;

  /// Height of the text cursor.
  final double? cursorHeight;

  /// Corner radius of the cursor.
  final Radius? cursorRadius;

  /// Cursor color.
  final Color? cursorColor;

  /// Keyboard brightness appearance.
  final Brightness? keyboardAppearance;

  /// Padding around the field when scrolling into view.
  final EdgeInsets scrollPadding;

  /// Whether selection controls are enabled.
  final bool? enableInteractiveSelection;

  /// Custom text selection controls.
  final TextSelectionControls? selectionControls;

  /// Mode for automatic validation.
  final AutovalidateMode? autovalidateMode;

  /// Whether this field is required. If true, appends an indicator to [labelText]
  /// and marks the widget as required in accessibility semantics.
  final bool required;

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

        final InputDecoration defaultDecoration = InputDecoration(
          hintText: hintText,
          labelText: effectiveLabel,
          helperText: helperText,
          errorText: errorText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          prefix: prefix,
          suffix: suffix,
          prefixText: prefixText,
          suffixText: suffixText,
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
                    hintText: decoration!.hintText ?? hintText,
                    labelText: decoration!.labelText ?? effectiveLabel,
                    helperText: decoration!.helperText ?? helperText,
                    errorText: decoration!.errorText ?? errorText,
                    prefixIcon: decoration!.prefixIcon ?? prefixIcon,
                    suffixIcon: decoration!.suffixIcon ?? suffixIcon,
                  )
                : defaultDecoration)
            .applyDefaults(Theme.of(ctx).inputDecorationTheme);

        return Semantics(
          hint: required ? 'Required' : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: TextFormField(
              controller: controller,
              initialValue: initialValue,
              focusNode: focusNode,
              decoration: effectiveDecoration,
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              textInputAction: textInputAction,
              style: style,
              strutStyle: strutStyle,
              textAlign: textAlign,
              textAlignVertical: textAlignVertical,
              textDirection: textDirection,
              readOnly: readOnly,
              showCursor: showCursor,
              autofocus: autofocus,
              obscuringCharacter: obscuringCharacter,
              obscureText: obscureText,
              autocorrect: autocorrect,
              smartDashesType: smartDashesType,
              smartQuotesType: smartQuotesType,
              enableSuggestions: enableSuggestions,
              maxLines: maxLines,
              minLines: minLines,
              expands: expands,
              maxLength: maxLength,
              maxLengthEnforcement: maxLengthEnforcement,
              onChanged: onChanged,
              onTap: onTap,
              onTapOutside: onTapOutside ??
                  (PointerDownEvent event) {
                    // Soft unfocus on outside tap unless disabled or web
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
              onEditingComplete: onEditingComplete,
              onFieldSubmitted: onFieldSubmitted ?? onSubmitted,
              onSaved: onSaved,
              validator: validator,
              inputFormatters: inputFormatters,
              enabled: enabled,
              cursorWidth: cursorWidth,
              cursorHeight: cursorHeight,
              cursorRadius: cursorRadius,
              cursorColor: cursorColor,
              keyboardAppearance: keyboardAppearance,
              scrollPadding: scrollPadding,
              enableInteractiveSelection: enableInteractiveSelection,
              selectionControls: selectionControls,
              autovalidateMode: autovalidateMode,
            ),
          ),
        );
      },
    );
  }
}
