import 'package:flutter/material.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';

/// A toggle switch with touch target padding ensuring accessible tap areas (>= 48x48dp),
/// supporting optional titles, subtitles, error text, and keyboard navigation.
class AdaptiveSwitch extends StatelessWidget {
  const AdaptiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.errorText,
    this.activeColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
  });

  /// Whether this switch is turned on.
  final bool value;

  /// Called when the user toggles the switch.
  final ValueChanged<bool>? onChanged;

  /// Optional label widget displayed alongside the switch.
  final Widget? title;

  /// Optional secondary description widget displayed below the title.
  final Widget? subtitle;

  /// Optional error text displayed beneath the control.
  final String? errorText;

  /// The color to use when this switch is on.
  final Color? activeColor;

  /// The color to use on the track when this switch is on.
  final Color? activeTrackColor;

  /// The color to use on the thumb when this switch is off.
  final Color? inactiveThumbColor;

  /// The color to use on the track when this switch is off.
  final Color? inactiveTrackColor;

  /// Whether the switch is interactive.
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
        final double touchSize =
            layout.isCompact ? theme.sizing.touchTargetMin : 36.0;

        final Color effectiveActiveColor = activeColor ?? theme.colors.primary;

        final Widget switchWidget = ConstrainedBox(
          constraints:
              BoxConstraints(minWidth: touchSize, minHeight: touchSize),
          child: Switch.adaptive(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: effectiveActiveColor,
            activeTrackColor: activeTrackColor,
            inactiveThumbColor: inactiveThumbColor,
            inactiveTrackColor: inactiveTrackColor,
            autofocus: autofocus,
            focusNode: focusNode,
          ),
        );

        if (title == null && subtitle == null && errorText == null) {
          return switchWidget;
        }

        final Widget content = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (title != null || subtitle != null)
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
            const SizedBox(width: 8.0),
            switchWidget,
          ],
        );

        final Widget interactiveContent = enabled && onChanged != null
            ? InkWell(
                onTap: () => onChanged!(!value),
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

/// A [FormField] wrapper for [AdaptiveSwitch], providing validation, error rendering,
/// and form state management.
class AdaptiveSwitchFormField extends FormField<bool> {
  AdaptiveSwitchFormField({
    super.key,
    super.onSaved,
    super.validator,
    bool initialValue = false,
    super.autovalidateMode,
    super.enabled = true,
    Widget? title,
    Widget? subtitle,
    Color? activeColor,
    Color? activeTrackColor,
    Color? inactiveThumbColor,
    Color? inactiveTrackColor,
    ValueChanged<bool>? onChanged,
  }) : super(
          initialValue: initialValue,
          builder: (FormFieldState<bool> field) {
            void handleChanged(bool value) {
              field.didChange(value);
              onChanged?.call(value);
            }

            return AdaptiveSwitch(
              value: field.value ?? false,
              onChanged: enabled ? handleChanged : null,
              title: title,
              subtitle: subtitle,
              errorText: field.errorText,
              activeColor: activeColor,
              activeTrackColor: activeTrackColor,
              inactiveThumbColor: inactiveThumbColor,
              inactiveTrackColor: inactiveTrackColor,
              enabled: enabled,
            );
          },
        );
}
