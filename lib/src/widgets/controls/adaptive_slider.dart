import 'package:flutter/material.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';

/// A slider control that adapts colors, touch targets, and layout dimensions to current
/// [AdaptiveThemeData] design tokens, with optional title, value indicators, and FormField support.
class AdaptiveSlider extends StatelessWidget {
  const AdaptiveSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.title,
    this.valueFormatter,
    this.showValue = false,
    this.showMinMax = false,
    this.minLabel,
    this.maxLabel,
    this.errorText,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.onChangeStart,
    this.onChangeEnd,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
  });

  /// The currently selected value.
  final double value;

  /// Called during a drag when the user is selecting a new value for the slider.
  final ValueChanged<double>? onChanged;

  /// The minimum value the user can select.
  final double min;

  /// The maximum value the user can select.
  final double max;

  /// The number of discrete divisions.
  final int? divisions;

  /// A label to show above the slider during a drag.
  final String? label;

  /// Optional header title displayed above the slider.
  final Widget? title;

  /// Formatter for displaying the current value when [showValue] is true.
  final String Function(double value)? valueFormatter;

  /// Whether to display the formatted current value in the header row.
  final bool showValue;

  /// Whether to display min and max labels beneath the track.
  final bool showMinMax;

  /// Custom minimum value label widget.
  final Widget? minLabel;

  /// Custom maximum value label widget.
  final Widget? maxLabel;

  /// Optional error text displayed beneath the slider.
  final String? errorText;

  /// The color to use for the portion of the track that is active.
  final Color? activeColor;

  /// The color for the inactive portion of the track.
  final Color? inactiveColor;

  /// The color of the thumb.
  final Color? thumbColor;

  /// Called when the user starts selecting a new value.
  final ValueChanged<double>? onChangeStart;

  /// Called when the user is done selecting a new value.
  final ValueChanged<double>? onChangeEnd;

  /// Whether the slider is interactive.
  final bool enabled;

  /// Whether this widget should request focus on mount.
  final bool autofocus;

  /// Optional focus node.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveThemeData theme = AdaptiveScope.themeOf(ctx);

        final Color effectiveActiveColor = activeColor ?? theme.colors.primary;
        final Color effectiveInactiveColor =
            inactiveColor ?? theme.colors.surfaceVariant;

        final Widget sliderWidget = Slider.adaptive(
          value: value.clamp(min, max),
          onChanged: enabled ? onChanged : null,
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          activeColor: effectiveActiveColor,
          inactiveColor: effectiveInactiveColor,
          thumbColor: thumbColor,
          onChangeStart: onChangeStart,
          onChangeEnd: onChangeEnd,
          autofocus: autofocus,
          focusNode: focusNode,
        );

        if (title == null && !showValue && !showMinMax && errorText == null) {
          return sliderWidget;
        }

        final String formattedValue = valueFormatter != null
            ? valueFormatter!(value)
            : (value == value.roundToDouble()
                ? value.toInt().toString()
                : value.toStringAsFixed(1));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null || showValue)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (title != null)
                      Expanded(
                        child: DefaultTextStyle.merge(
                          style: theme.typography.bodyMedium.copyWith(
                            color: enabled
                                ? theme.colors.textPrimary
                                : theme.colors.disabled,
                            fontWeight: FontWeight.w500,
                          ),
                          child: title!,
                        ),
                      ),
                    if (showValue) ...[
                      const SizedBox(width: 8.0),
                      Text(
                        formattedValue,
                        style: theme.typography.bodyMedium.copyWith(
                          color: enabled
                              ? theme.colors.primary
                              : theme.colors.disabled,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            sliderWidget,
            if (showMinMax)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    minLabel ??
                        Text(
                          min.toStringAsFixed(
                              min == min.roundToDouble() ? 0 : 1),
                          style: theme.typography.caption.copyWith(
                            color: theme.colors.textSecondary,
                          ),
                        ),
                    maxLabel ??
                        Text(
                          max.toStringAsFixed(
                              max == max.roundToDouble() ? 0 : 1),
                          style: theme.typography.caption.copyWith(
                            color: theme.colors.textSecondary,
                          ),
                        ),
                  ],
                ),
              ),
            if (errorText != null)
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

/// A [FormField] wrapper for [AdaptiveSlider], providing validation, error rendering,
/// and form state management.
class AdaptiveSliderFormField extends FormField<double> {
  AdaptiveSliderFormField({
    super.key,
    super.onSaved,
    super.validator,
    double initialValue = 0.0,
    super.autovalidateMode,
    super.enabled = true,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    String? label,
    Widget? title,
    String Function(double value)? valueFormatter,
    bool showValue = false,
    bool showMinMax = false,
    Widget? minLabel,
    Widget? maxLabel,
    Color? activeColor,
    Color? inactiveColor,
    Color? thumbColor,
    ValueChanged<double>? onChanged,
  }) : super(
          initialValue: initialValue,
          builder: (FormFieldState<double> field) {
            void handleChanged(double value) {
              field.didChange(value);
              onChanged?.call(value);
            }

            return AdaptiveSlider(
              value: field.value ?? initialValue,
              onChanged: enabled ? handleChanged : null,
              min: min,
              max: max,
              divisions: divisions,
              label: label,
              title: title,
              valueFormatter: valueFormatter,
              showValue: showValue,
              showMinMax: showMinMax,
              minLabel: minLabel,
              maxLabel: maxLabel,
              errorText: field.errorText,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              thumbColor: thumbColor,
              enabled: enabled,
            );
          },
        );
}
