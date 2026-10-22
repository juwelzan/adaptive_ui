import 'package:flutter/material.dart';

import '../../core/adaptive_layout_data.dart';
import '../../core/adaptive_scope.dart';
import '../../core/adaptive_value.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';
import '../surfaces/adaptive_card.dart';

/// A structured section container for grouping related form fields with headers,
/// subtitles, responsive multi-column layouts, and optional card framing.
class AdaptiveFormSection extends StatelessWidget {
  const AdaptiveFormSection({
    super.key,
    required this.children,
    this.title,
    this.titleText,
    this.subtitle,
    this.subtitleText,
    this.spacing = 16.0,
    this.columns = 1,
    this.card = true,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
  });

  /// The form fields or widgets contained in this section.
  final List<Widget> children;

  /// Header title widget.
  final Widget? title;

  /// Header title text used when [title] is null.
  final String? titleText;

  /// Secondary subtitle widget.
  final Widget? subtitle;

  /// Secondary subtitle text used when [subtitle] is null.
  final String? subtitleText;

  /// Vertical and horizontal spacing between form fields.
  final double spacing;

  /// Target column count on wide screens (>= medium breakpoint).
  /// Automatically collapses to 1 column on compact screens.
  final int columns;

  /// Whether to frame the section inside an [AdaptiveCard].
  final bool card;

  /// Internal padding.
  final EdgeInsetsGeometry? padding;

  /// External margin.
  final EdgeInsetsGeometry? margin;

  /// Surface background color override.
  final Color? backgroundColor;

  /// Boundary border color override.
  final Color? borderColor;

  /// Corner radius override.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final AdaptiveThemeData theme = AdaptiveScope.themeOf(ctx);

        final Widget? headerTitle = title ??
            (titleText != null
                ? Text(
                    titleText!,
                    style: theme.typography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colors.textPrimary,
                    ),
                  )
                : null);

        final Widget? headerSubtitle = subtitle ??
            (subtitleText != null
                ? Text(
                    subtitleText!,
                    style: theme.typography.bodySmall.copyWith(
                      color: theme.colors.textSecondary,
                    ),
                  )
                : null);

        final bool hasHeader = headerTitle != null || headerSubtitle != null;

        // Build responsive field grid/column
        final bool isMultiColumn = columns > 1 && !layout.isCompact;
        Widget fieldsLayout;

        if (isMultiColumn) {
          final List<Widget> rows = [];
          for (int i = 0; i < children.length; i += columns) {
            final List<Widget> rowChildren = [];
            for (int col = 0; col < columns; col++) {
              final int index = i + col;
              if (index < children.length) {
                rowChildren.add(
                  Expanded(child: children[index]),
                );
              } else {
                rowChildren.add(const Expanded(child: SizedBox.shrink()));
              }
              if (col < columns - 1) {
                rowChildren.add(SizedBox(width: spacing));
              }
            }
            rows.add(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowChildren,
            ));
            if (i + columns < children.length) {
              rows.add(SizedBox(height: spacing));
            }
          }
          fieldsLayout = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: rows,
          );
        } else {
          fieldsLayout = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: spacing),
                children[i],
              ],
            ],
          );
        }

        final Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasHeader) ...[
              if (headerTitle != null) headerTitle,
              if (headerSubtitle != null) ...[
                const SizedBox(height: 4.0),
                headerSubtitle,
              ],
              const SizedBox(height: 16.0),
            ],
            fieldsLayout,
          ],
        );

        Widget sectionContent = content;
        if (padding != null) {
          sectionContent = Padding(
            padding: padding!,
            child: content,
          );
        }

        if (card) {
          return Padding(
            padding: margin ?? EdgeInsets.zero,
            child: AdaptiveCard(
              color: backgroundColor ?? theme.colors.surface,
              borderRadius:
                  borderRadius ?? theme.radii.toBorderRadius(theme.radii.md),
              elevation: 0.0,
              padding: padding == null
                  ? const AdaptiveInsets.auto()
                  : AdaptiveInsets.all(0.0),
              child: sectionContent,
            ),
          );
        }

        return Padding(
          padding: margin ?? EdgeInsets.zero,
          child: sectionContent,
        );
      },
    );
  }
}
