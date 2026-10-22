import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/adaptive_breakpoints.dart';
import '../../core/adaptive_layout_data.dart';
import '../../theme/adaptive_motion.dart';
import '../../theme/adaptive_theme.dart';
import '../../theme/adaptive_theme_data.dart';
import '../adaptive_builder.dart';
import 'adaptive_sidebar_models.dart';
import 'adaptive_sidebar_styles.dart';
import 'adaptive_sidebar_tile.dart';

export 'adaptive_dropdown.dart';
export 'adaptive_sidebar_models.dart';
export 'adaptive_sidebar_styles.dart';

/// A modern, responsive, animated navigation sidebar supporting nine visual design
/// models, animated hierarchical submenus, dropdown actions, and compact rail modes.
class AdaptiveSidebar extends StatefulWidget {
  const AdaptiveSidebar({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.isExpanded,
    this.autoExpandBreakpoint = Breakpoint.large,
    this.expandedWidth = 240.0,
    this.collapsedWidth = 72.0,
    this.style = AdaptiveSidebarStyle.classicModern,
    this.submenuAnimation = AdaptiveSubmenuAnimation.expand,
    this.expansionMode = AdaptiveSubmenuExpansionMode.independent,
    this.onSubmenuExpansionChanged,
    this.header,
    this.footer,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
    this.itemSpacing = 4.0,
    this.submenuIndentation = 16.0,
    this.animationDuration,
    this.animationCurve = AdaptiveMotion.emphasizedCurve,
    this.backgroundColor,
    this.selectedColor,
    this.indicatorColor,
    this.elevation,
    this.border,
    this.enableRailToggle = false,
  });

  /// The navigation items displayed in this sidebar.
  final List<AdaptiveSidebarItem> items;

  /// Index of the currently selected destination.
  final int selectedIndex;

  /// Callback invoked when a navigation destination is selected.
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

  /// Visual design model applied to this sidebar. Defaults to [AdaptiveSidebarStyle.classicModern].
  final AdaptiveSidebarStyle style;

  /// Transition animation used when expanding/collapsing hierarchical submenus.
  final AdaptiveSubmenuAnimation submenuAnimation;

  /// Expansion policy for submenus (independent vs accordion).
  final AdaptiveSubmenuExpansionMode expansionMode;

  /// Optional callback invoked when a submenu expands or collapses.
  final void Function(int index, bool isExpanded)? onSubmenuExpansionChanged;

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

  /// Horizontal indentation applied to nested child items. Defaults to 16.0 dp.
  final double submenuIndentation;

  /// Animation duration for expand/collapse and selection transitions.
  final Duration? animationDuration;

  /// Animation curve for expand/collapse transitions.
  final Curve animationCurve;

  /// Background color of the sidebar. If null, resolves from the active [style].
  final Color? backgroundColor;

  /// Text and icon color for the selected item. If null, resolves from the active [style].
  final Color? selectedColor;

  /// Background color for the selected indicator pill. If null, resolves from the active [style].
  final Color? indicatorColor;

  /// Elevation shadow depth. If null, resolves from the active [style].
  final double? elevation;

  /// Optional exterior border. If null, resolves from the active [style].
  final Border? border;

  /// Whether to render an interactive collapse/expand toggle button.
  final bool enableRailToggle;

  @override
  State<AdaptiveSidebar> createState() => _AdaptiveSidebarState();
}

class _AdaptiveSidebarState extends State<AdaptiveSidebar> {
  final Set<int> _expandedSubmenus = <int>{};
  bool _internalExpanded = true;

  @override
  void initState() {
    super.initState();
    _initSubmenuStates();
  }

  @override
  void didUpdateWidget(covariant AdaptiveSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _initSubmenuStates();
    }
  }

  void _initSubmenuStates() {
    for (int i = 0; i < widget.items.length; i++) {
      if (widget.items[i].initiallyExpanded) {
        _expandedSubmenus.add(i);
      }
    }
  }

  void _toggleSubmenu(int index) {
    setState(() {
      final bool currentlyExpanded = _expandedSubmenus.contains(index);
      if (currentlyExpanded) {
        _expandedSubmenus.remove(index);
        widget.onSubmenuExpansionChanged?.call(index, false);
      } else {
        if (widget.expansionMode == AdaptiveSubmenuExpansionMode.accordion) {
          _expandedSubmenus.clear();
        }
        _expandedSubmenus.add(index);
        widget.onSubmenuExpansionChanged?.call(index, true);
      }
    });
  }

  void _toggleRailExpansion() {
    setState(() {
      _internalExpanded = !_internalExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final bool reducedMotion = AdaptiveMotion.isReducedMotion(ctx);

        // Resolve expanded state
        final bool autoExpanded = layout.containerBreakpoint.index >=
            widget.autoExpandBreakpoint.index;
        final bool resolvedExpanded = widget.isExpanded ??
            (widget.enableRailToggle ? _internalExpanded : autoExpanded);

        final double targetWidth =
            resolvedExpanded ? widget.expandedWidth : widget.collapsedWidth;

        // Ensure target width does not exceed bounded parent width
        final double effectiveWidth = layout.constraints.hasBoundedWidth
            ? targetWidth.clamp(0.0, layout.constraints.maxWidth)
            : targetWidth;

        final Duration duration = reducedMotion
            ? Duration.zero
            : (widget.animationDuration ?? AdaptiveMotion.standard);

        final AdaptiveThemeData theme = AdaptiveTheme.of(ctx);
        final AdaptiveSidebarStyle effectiveStyle =
            widget.style != AdaptiveSidebarStyle.classicModern
                ? widget.style
                : (theme.sidebarTheme.style ?? widget.style);

        final AdaptiveSidebarStyleSpec styleSpec =
            AdaptiveSidebarStyleSpec.resolve(
          context: ctx,
          style: effectiveStyle,
          customBackgroundColor: widget.backgroundColor,
          customSelectedColor: widget.selectedColor,
          customIndicatorColor: widget.indicatorColor,
          customBorder: widget.border,
          customElevation: widget.elevation,
        );

        final bool hasOverlay = Overlay.maybeOf(ctx) != null;

        int runningIndex = 0;
        final List<Widget> renderedTiles = <Widget>[];

        for (int i = 0; i < widget.items.length; i++) {
          final int itemIndex = runningIndex;
          runningIndex++;

          final AdaptiveSidebarItem item = widget.items[i];
          final bool isSubmenuOpen = _expandedSubmenus.contains(i);

          // Check if any descendant of this item is selected
          bool isAncestor = false;
          final List<int> childIndices = [];
          if (item.hasChildren) {
            for (int c = 0; c < item.children.length; c++) {
              final int childIdx = runningIndex++;
              childIndices.add(childIdx);
              if (widget.selectedIndex == childIdx) {
                isAncestor = true;
              }
            }
          }

          final bool isSelected = widget.selectedIndex == itemIndex;

          if (i > 0 && widget.itemSpacing > 0) {
            renderedTiles.add(SizedBox(height: widget.itemSpacing));
          }

          renderedTiles.add(
            AdaptiveSidebarTile(
              key: ValueKey(
                  'sidebar_${widget.style.name}_${widget.submenuAnimation.name}_item_${item.id ?? i}'),
              item: item,
              depth: 0,
              itemIndex: itemIndex,
              isSelected: isSelected,
              isAncestorOfSelected: isAncestor,
              isExpandedSidebar: resolvedExpanded,
              isSubmenuExpanded: isSubmenuOpen,
              onTap: item.enabled
                  ? () => widget.onDestinationSelected?.call(itemIndex)
                  : null,
              onSubmenuToggle: () => _toggleSubmenu(i),
              styleSpec: styleSpec,
              submenuAnimation: widget.submenuAnimation,
              duration: duration,
              curve: widget.animationCurve,
              indentation: widget.submenuIndentation,
              onDestinationSelected: widget.onDestinationSelected,
              selectedIndex: widget.selectedIndex,
            ),
          );
        }

        Widget sidebarContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.header != null) ClipRect(child: widget.header!),
            if (widget.leading != null) ClipRect(child: widget.leading!),
            Expanded(
              child: SingleChildScrollView(
                padding: widget.padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...renderedTiles,
                    if (widget.trailing != null)
                      ClipRect(child: widget.trailing!),
                  ],
                ),
              ),
            ),
            if (widget.enableRailToggle)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: IconButton(
                  key: const Key('adaptive_sidebar_rail_toggle'),
                  icon: Icon(
                    resolvedExpanded
                        ? Icons.keyboard_double_arrow_left
                        : Icons.keyboard_double_arrow_right,
                    size: 20.0,
                    color: styleSpec.inactiveIconColor,
                  ),
                  tooltip: hasOverlay
                      ? (resolvedExpanded
                          ? 'Collapse sidebar'
                          : 'Expand sidebar')
                      : null,
                  onPressed: _toggleRailExpansion,
                ),
              ),
            if (widget.footer != null) ClipRect(child: widget.footer!),
          ],
        );

        Widget surface = AnimatedContainer(
          key: const Key('adaptive_sidebar_container'),
          duration: duration,
          curve: widget.animationCurve,
          width: effectiveWidth,
          decoration: BoxDecoration(
            color: styleSpec.useBackdropFilter
                ? styleSpec.backgroundColor
                : styleSpec.backgroundColor,
            borderRadius: styleSpec.sidebarBorderRadius,
            border: styleSpec.border,
            boxShadow: styleSpec.elevation > 0.0
                ? [
                    BoxShadow(
                      color: styleSpec.shadowColor,
                      blurRadius: styleSpec.elevation * 2.0,
                      offset: Offset(0, styleSpec.elevation / 2.0),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: styleSpec.sidebarBorderRadius,
            child: sidebarContent,
          ),
        );

        // Frosted Glass Backdrop Filter
        if (styleSpec.useBackdropFilter) {
          surface = ClipRRect(
            borderRadius: styleSpec.sidebarBorderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: styleSpec.blurSigma,
                sigmaY: styleSpec.blurSigma,
              ),
              child: surface,
            ),
          );
        }

        // Floating Outer Margin
        if (styleSpec.outerMargin != EdgeInsets.zero) {
          surface = Padding(
            padding: styleSpec.outerMargin,
            child: surface,
          );
        }

        return Material(
          color: Colors.transparent,
          elevation: 0.0,
          child: surface,
        );
      },
    );
  }
}
