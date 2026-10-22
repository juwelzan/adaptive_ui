import 'package:flutter/material.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';

/// Layout orientation mode for [AdaptiveRadioGroup].
enum AdaptiveRadioLayout {
  /// Arranges radio items vertically in a column.
  vertical,

  /// Arranges radio items horizontally in a row.
  horizontal,

  /// Arranges radio items in a flowing wrap container.
  wrap,

  /// Automatically displays as a row on wider screens and collapses to a column on compact screens.
  auto,
}

/// An individual option item for [AdaptiveRadioGroup].
class AdaptiveRadioOption<T> {
  const AdaptiveRadioOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.enabled = true,
  });

  /// The value represented by this radio option.
  final T value;

  /// The primary label widget for this option.
  final Widget title;

  /// An optional secondary description widget.
  final Widget? subtitle;

  /// Whether this individual option is interactive.
  final bool enabled;
}

/// A responsive, accessible group of radio buttons supporting multiple layout orientations,
/// title headers, helper/error text, and [AdaptiveThemeData] design tokens.
class AdaptiveRadioGroup<T> extends StatelessWidget {
  const AdaptiveRadioGroup({
    super.key,
    required this.options,
    required this.groupValue,
    required this.onChanged,
    this.layout = AdaptiveRadioLayout.auto,
    this.title,
    this.labelText,
    this.helperText,
    this.errorText,
    this.activeColor,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.enabled = true,
    this.required = false,
  });

  /// List of radio options available for selection.
  final List<AdaptiveRadioOption<T>> options;

  /// The currently selected value.
  final T? groupValue;

  /// Invoked when the user selects an option.
  final ValueChanged<T?>? onChanged;

  /// Layout orientation of the radio group items. Defaults to [AdaptiveRadioLayout.auto].
  final AdaptiveRadioLayout layout;

  /// Optional header widget displayed above the options.
  final Widget? title;

  /// Optional header label text displayed above the options if [title] is null.
  final String? labelText;

  /// Optional helper text displayed below the options.
  final String? helperText;

  /// Optional error text displayed below the options.
  final String? errorText;

  /// Color used for the active/selected radio button.
  final Color? activeColor;

  /// Spacing between radio options.
  final double spacing;

  /// Run spacing between wrapped lines when [layout] is [AdaptiveRadioLayout.wrap].
  final double runSpacing;

  /// Whether the entire radio group is interactive.
  final bool enabled;

  /// Whether a selection is required. Appends an asterisk to [labelText].
  final bool required;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layoutData) {
        final AdaptiveThemeData theme = AdaptiveScope.themeOf(ctx);
        final Color effectiveActiveColor = activeColor ?? theme.colors.primary;
        final double touchSize =
            layoutData.isCompact ? theme.sizing.touchTargetMin : 36.0;

        final Widget headerLabel;
        final String? effectiveLabelText =
            required && labelText != null ? '$labelText *' : labelText;

        if (title != null) {
          headerLabel = title!;
        } else if (effectiveLabelText != null) {
          headerLabel = Text(
            effectiveLabelText,
            style: theme.typography.labelLarge.copyWith(
              color: errorText != null
                  ? theme.colors.error
                  : (enabled
                      ? theme.colors.textPrimary
                      : theme.colors.disabled),
              fontWeight: FontWeight.w600,
            ),
          );
        } else {
          headerLabel = const SizedBox.shrink();
        }

        final bool hasHeader = title != null || effectiveLabelText != null;

        List<Widget> optionWidgets =
            options.map((AdaptiveRadioOption<T> option) {
          final bool isOptionEnabled = enabled && option.enabled;
          final bool isSelected = option.value == groupValue;

          final Widget radio = ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: touchSize, minHeight: touchSize),
            // ignore: deprecated_member_use
            child: Radio<T>(
              value: option.value,
              // ignore: deprecated_member_use
              groupValue: groupValue,
              // ignore: deprecated_member_use
              onChanged: isOptionEnabled ? onChanged : null,
              activeColor: effectiveActiveColor,
            ),
          );

          final Widget optionContent = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              radio,
              const SizedBox(width: 4.0),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultTextStyle.merge(
                      style: theme.typography.bodyMedium.copyWith(
                        color: isOptionEnabled
                            ? theme.colors.textPrimary
                            : theme.colors.disabled,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      child: option.title,
                    ),
                    if (option.subtitle != null) ...[
                      const SizedBox(height: 2.0),
                      DefaultTextStyle.merge(
                        style: theme.typography.bodySmall.copyWith(
                          color: theme.colors.textSecondary,
                        ),
                        child: option.subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );

          return isOptionEnabled && onChanged != null
              ? InkWell(
                  onTap: () => onChanged!(option.value),
                  borderRadius: theme.radii.toBorderRadius(theme.radii.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 2.0),
                    child: optionContent,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 2.0),
                  child: optionContent,
                );
        }).toList();

        Widget optionsLayout;
        switch (layout) {
          case AdaptiveRadioLayout.vertical:
            optionsLayout = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: optionWidgets
                  .map((w) => Padding(
                        padding: EdgeInsets.only(bottom: spacing / 2),
                        child: w,
                      ))
                  .toList(),
            );
            break;

          case AdaptiveRadioLayout.horizontal:
            optionsLayout = SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: optionWidgets
                    .map((w) => Padding(
                          padding: EdgeInsets.only(right: spacing),
                          child: w,
                        ))
                    .toList(),
              ),
            );
            break;

          case AdaptiveRadioLayout.wrap:
            optionsLayout = Wrap(
              spacing: spacing,
              runSpacing: runSpacing,
              children: optionWidgets,
            );
            break;

          case AdaptiveRadioLayout.auto:
            if (layoutData.isCompact) {
              optionsLayout = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: optionWidgets
                    .map((w) => Padding(
                          padding: EdgeInsets.only(bottom: spacing / 2),
                          child: w,
                        ))
                    .toList(),
              );
            } else {
              optionsLayout = Wrap(
                spacing: spacing,
                runSpacing: runSpacing,
                children: optionWidgets,
              );
            }
            break;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasHeader) ...[
              headerLabel,
              const SizedBox(height: 6.0),
            ],
            optionsLayout,
            if (errorText != null) ...[
              const SizedBox(height: 4.0),
              Text(
                errorText!,
                style: theme.typography.caption.copyWith(
                  color: theme.colors.error,
                ),
              ),
            ] else if (helperText != null) ...[
              const SizedBox(height: 4.0),
              Text(
                helperText!,
                style: theme.typography.caption.copyWith(
                  color: theme.colors.textSecondary,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// A [FormField] wrapper for [AdaptiveRadioGroup], providing validation, error rendering,
/// and form state management.
class AdaptiveRadioGroupFormField<T> extends FormField<T> {
  AdaptiveRadioGroupFormField({
    super.key,
    super.onSaved,
    super.validator,
    super.initialValue,
    super.autovalidateMode,
    super.enabled = true,
    required List<AdaptiveRadioOption<T>> options,
    AdaptiveRadioLayout layout = AdaptiveRadioLayout.auto,
    Widget? title,
    String? labelText,
    String? helperText,
    Color? activeColor,
    double spacing = 8.0,
    double runSpacing = 8.0,
    bool required = false,
    ValueChanged<T?>? onChanged,
  }) : super(
          builder: (FormFieldState<T> field) {
            void handleChanged(T? value) {
              field.didChange(value);
              onChanged?.call(value);
            }

            return AdaptiveRadioGroup<T>(
              options: options,
              groupValue: field.value,
              onChanged: enabled ? handleChanged : null,
              layout: layout,
              title: title,
              labelText: labelText,
              helperText: helperText,
              errorText: field.errorText,
              activeColor: activeColor,
              spacing: spacing,
              runSpacing: runSpacing,
              enabled: enabled,
              required: required,
            );
          },
        );
}
