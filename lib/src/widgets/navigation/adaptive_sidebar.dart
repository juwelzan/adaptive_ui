import 'package:flutter/material.dart';

import '../../core/adaptive_breakpoints.dart';
import '../../core/adaptive_layout_data.dart';
import '../../theme/adaptive_motion.dart';
import '../adaptive_builder.dart';

/// Specification for a navigation item in [AdaptiveSidebar].
@immutable
class AdaptiveSidebarItem {
  const AdaptiveSidebarItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
    this.tooltip,
    this.enabled = true,
  });

  /// The icon widget displayed for this destination.
  final Widget icon;

  /// Optional icon displayed when this item is selected.
  final Widget? selectedIcon;

  /// The label widget describing this destination.
  final Widget label;

  /// Optional badge widget displayed adjacent to the icon or trailing edge.
  final Widget? badge;

  /// Tooltip text shown on hover or long-press, especially useful in collapsed mode.
  final String? tooltip;

  /// Whether this navigation item is interactive. Defaults to `true`.
  final bool enabled;
}

/// A responsive, animated navigation sidebar supporting expanded and collapsed modes.
///
/// Automatically transitions between collapsed (icon-only, 72dp) and expanded (icon + label, 240dp)
/// modes based on parent constraints or explicit configuration.
class AdaptiveSidebar extends StatelessWidget {
  const AdaptiveSidebar({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.isExpanded,
    this.autoExpandBreakpoint = Breakpoint.large,
    this.expandedWidth = 240.0,
    this.collapsedWidth = 72.0,
    this.header,
    this.footer,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
    this.itemSpacing = 4.0,
    this.animationDuration,
    this.animationCurve = AdaptiveMotion.emphasizedCurve,
    this.backgroundColor,
    this.selectedColor,
    this.indicatorColor,
    this.elevation = 0.0,
    this.border,
  });

  /// The navigation items displayed in this sidebar.
  final List<AdaptiveSidebarItem> items;

  /// Index of the currently selected destination.
  final int selectedIndex;

  /// Callback invoked when a navigation item is selected.
  final ValueChanged<int>? onDestinationSelected;

  /// Explicit expanded state. If `null`, automatically resolves based on [autoExpandBreakpoint].
  final bool? isExpanded;

  /// The breakpoint at or above which the sidebar automatically expands when [isExpanded] is null.
  /// Defaults to [Breakpoint.large] (1200dp).
  final Breakpoint autoExpandBreakpoint;

  /// Width in logical pixels when expanded. Defaults to 240.0 dp.
  final double expandedWidth;

  /// Width in logical pixels when collapsed. Defaults to 72.0 dp.
  final double collapsedWidth;

  /// Optional header widget placed at the top of the sidebar.
  final Widget? header;

  /// Optional footer widget pinned at the bottom of the sidebar.
  final Widget? footer;

  /// Optional widget placed immediately before the navigation items.
  final Widget? leading;

  /// Optional widget placed immediately after the navigation items.
  final Widget? trailing;

  /// Outer padding applied around sidebar contents.
  final EdgeInsetsGeometry padding;

  /// Vertical spacing between consecutive navigation items. Defaults to 4.0 dp.
  final double itemSpacing;

  /// Animation duration for expand/collapse and selection transitions.
  final Duration? animationDuration;

  /// Animation curve for expand/collapse transitions.
  final Curve animationCurve;

  /// Background color of the sidebar. If null, resolves from theme surface.
  final Color? backgroundColor;

  /// Text and icon color for the selected item.
  final Color? selectedColor;

  /// Background color for the selected indicator pill.
  final Color? indicatorColor;

  /// Elevation shadow depth.
  final double elevation;

  /// Optional side border (e.g. divider on the trailing edge).
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final ThemeData theme = Theme.of(ctx);
        final bool isDark = theme.brightness == Brightness.dark;
        final bool reducedMotion = AdaptiveMotion.isReducedMotion(ctx);

        final bool resolvedExpanded = isExpanded ??
            (layout.containerBreakpoint.index >= autoExpandBreakpoint.index);

        final double targetWidth =
            resolvedExpanded ? expandedWidth : collapsedWidth;

        // Ensure target width does not exceed bounded parent width
        final double effectiveWidth = layout.constraints.hasBoundedWidth
            ? targetWidth.clamp(0.0, layout.constraints.maxWidth)
            : targetWidth;

        final Duration duration = reducedMotion
            ? Duration.zero
            : (animationDuration ?? AdaptiveMotion.standard);

        final Color bg = backgroundColor ??
            (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F9FB));

        final Color effectiveIndicator = indicatorColor ??
            (isDark
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : theme.colorScheme.primary.withValues(alpha: 0.12));

        final Color effectiveSelectedText =
            selectedColor ?? theme.colorScheme.primary;

        final Color unselectedColor =
            isDark ? const Color(0xFF8E8E93) : const Color(0xFF6C6C70);

        Widget sidebarContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) ClipRect(child: header!),
            if (leading != null) ClipRect(child: leading!),
            Expanded(
              child: SingleChildScrollView(
                padding: padding,
                child: Column(
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      if (i > 0 && itemSpacing > 0)
                        SizedBox(height: itemSpacing),
                      _AdaptiveSidebarItemTile(
                        item: items[i],
                        isSelected: selectedIndex == i,
                        isExpanded: resolvedExpanded,
                        onTap: items[i].enabled
                            ? () => onDestinationSelected?.call(i)
                            : null,
                        duration: duration,
                        curve: animationCurve,
                        indicatorColor: effectiveIndicator,
                        selectedColor: effectiveSelectedText,
                        unselectedColor: unselectedColor,
                      ),
                    ],
                    if (trailing != null) ClipRect(child: trailing!),
                  ],
                ),
              ),
            ),
            if (footer != null) ClipRect(child: footer!),
          ],
        );

        return Material(
          elevation: elevation,
          color: bg,
          child: Container(
            decoration: BoxDecoration(border: border),
            child: AnimatedContainer(
              key: const Key('adaptive_sidebar_container'),
              duration: duration,
              curve: animationCurve,
              width: effectiveWidth,
              child: ClipRect(child: sidebarContent),
            ),
          ),
        );
      },
    );
  }
}

class _AdaptiveSidebarItemTile extends StatelessWidget {
  const _AdaptiveSidebarItemTile({
    required this.item,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    required this.duration,
    required this.curve,
    required this.indicatorColor,
    required this.selectedColor,
    required this.unselectedColor,
  });

  final AdaptiveSidebarItem item;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback? onTap;
  final Duration duration;
  final Curve curve;
  final Color indicatorColor;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    final Color itemColor = isSelected ? selectedColor : unselectedColor;
    final Widget iconWidget =
        isSelected ? (item.selectedIcon ?? item.icon) : item.icon;

    final IconThemeData iconTheme = IconThemeData(
      color: itemColor,
      size: 22.0,
    );

    final String? tooltipText = item.tooltip ??
        (!isExpanded && item.label is Text ? (item.label as Text).data : null);

    final bool hasOverlay = Overlay.maybeOf(context) != null;

    final Widget tile = Semantics(
      button: true,
      selected: isSelected,
      enabled: item.enabled,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: AnimatedContainer(
          duration: duration,
          curve: curve,
          constraints: const BoxConstraints(minHeight: 48.0),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? indicatorColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: LayoutBuilder(
            builder: (BuildContext ctx, BoxConstraints tileConstraints) {
              final bool canFitExpanded =
                  isExpanded && tileConstraints.maxWidth >= 80.0;

              if (canFitExpanded) {
                return ClipRect(
                  child: Row(
                    children: [
                      IconTheme(data: iconTheme, child: iconWidget),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: itemColor,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 14.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          child: item.label,
                        ),
                      ),
                      if (item.badge != null) ...[
                        const SizedBox(width: 8.0),
                        item.badge!,
                      ],
                    ],
                  ),
                );
              }

              return Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    IconTheme(data: iconTheme, child: iconWidget),
                    if (item.badge != null)
                      Positioned(
                        top: -4.0,
                        right: -6.0,
                        child: item.badge!,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    if (hasOverlay && tooltipText != null && tooltipText.isNotEmpty) {
      return Tooltip(
        message: tooltipText,
        waitDuration: const Duration(milliseconds: 600),
        child: tile,
      );
    }

    return tile;
  }
}
