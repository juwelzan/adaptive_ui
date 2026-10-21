import 'package:flutter/material.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';

/// Style variants for [AdaptiveButton].
enum AdaptiveButtonVariant {
  primary,
  secondary,
  outline,
  text,
}

/// A responsive button guaranteeing WCAG touch target dimensions (>= 48dp) and responsive full-width expansion.
class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = AdaptiveButtonVariant.primary,
    this.fullWidthOnCompact = false,
    this.isLoading = false,
    this.icon,
    this.padding,
  });

  /// Action callback triggered upon tap. If null, the button renders disabled.
  final VoidCallback? onPressed;

  /// The button label or child widget.
  final Widget child;

  /// Visual style variant. Defaults to [AdaptiveButtonVariant.primary].
  final AdaptiveButtonVariant variant;

  /// Whether the button automatically expands to full parent width on [Breakpoint.compact].
  final bool fullWidthOnCompact;

  /// Displays an adaptive progress indicator in place of the child when active.
  final bool isLoading;

  /// Optional prefix icon.
  final Widget? icon;

  /// Custom padding override.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveThemeData theme = AdaptiveScope.themeOf(ctx);
        final double minHeight = layout.isCompact
            ? theme.sizing.buttonHeightCompact
            : theme.sizing.buttonHeightRegular;

        final double minWidth = layout.isCompact && fullWidthOnCompact
            ? double.infinity
            : theme.sizing.touchTargetMin;

        Widget content = isLoading
            ? SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    variant == AdaptiveButtonVariant.primary
                        ? theme.colors.onPrimary
                        : theme.colors.primary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8.0),
                  ],
                  Flexible(child: child),
                ],
              );

        ButtonStyle buttonStyle = ElevatedButton.styleFrom(
          minimumSize: Size(minWidth, minHeight),
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: theme.radii.toBorderRadius(theme.radii.md),
          ),
        );

        switch (variant) {
          case AdaptiveButtonVariant.primary:
            buttonStyle = buttonStyle.copyWith(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return theme.colors.surfaceVariant;
                }
                return theme.colors.primary;
              }),
              foregroundColor: WidgetStateProperty.all(theme.colors.onPrimary),
            );
            return ElevatedButton(
              style: buttonStyle,
              onPressed: isLoading ? null : onPressed,
              child: content,
            );

          case AdaptiveButtonVariant.secondary:
            buttonStyle = buttonStyle.copyWith(
              backgroundColor:
                  WidgetStateProperty.all(theme.colors.surfaceVariant),
              foregroundColor:
                  WidgetStateProperty.all(theme.colors.onSurfaceVariant),
            );
            return ElevatedButton(
              style: buttonStyle,
              onPressed: isLoading ? null : onPressed,
              child: content,
            );

          case AdaptiveButtonVariant.outline:
            return OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(minWidth, minHeight),
                padding: padding ??
                    const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12.0),
                side: BorderSide(color: theme.colors.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: theme.radii.toBorderRadius(theme.radii.md),
                ),
              ),
              onPressed: isLoading ? null : onPressed,
              child: content,
            );

          case AdaptiveButtonVariant.text:
            return TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size(minWidth, minHeight),
                padding: padding ??
                    const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: theme.radii.toBorderRadius(theme.radii.md),
                ),
              ),
              onPressed: isLoading ? null : onPressed,
              child: content,
            );
        }
      },
    );
  }
}
