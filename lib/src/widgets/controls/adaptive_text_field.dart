import 'package:flutter/material.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';

/// A text input field with responsive font scaling and comfortable minimum touch target heights.
class AdaptiveTextField extends StatelessWidget {
  const AdaptiveTextField({
    super.key,
    this.controller,
    this.decoration,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final InputDecoration? decoration;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveThemeData theme = AdaptiveScope.themeOf(ctx);
        final double minHeight = layout.isCompact ? 48.0 : 42.0;

        final InputDecoration effectiveDecoration = (decoration ??
                InputDecoration(
                  hintText: hintText,
                  labelText: labelText,
                  prefixIcon: prefixIcon,
                  filled: true,
                  fillColor: theme.colors.surfaceVariant.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: theme.radii.toBorderRadius(theme.radii.md),
                    borderSide: BorderSide(color: theme.colors.outline),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                ))
            .applyDefaults(Theme.of(ctx).inputDecorationTheme);

        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: TextField(
            controller: controller,
            decoration: effectiveDecoration,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            maxLines: maxLines,
            enabled: enabled,
            autofocus: autofocus,
          ),
        );
      },
    );
  }
}
