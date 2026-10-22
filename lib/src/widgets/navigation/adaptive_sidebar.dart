import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/adaptive_breakpoints.dart';
import '../../core/adaptive_layout_data.dart';
import '../../theme/adaptive_motion.dart';
import '../adaptive_builder.dart';
import 'adaptive_bottom_navigation_bar.dart';
import 'adaptive_sidebar_models.dart';
import 'adaptive_sidebar_styles.dart';
import 'adaptive_sidebar_tile.dart';

export 'adaptive_bottom_navigation_bar.dart';
export 'adaptive_dropdown.dart';
export 'adaptive_sidebar_models.dart';
export 'adaptive_sidebar_styles.dart';

/// A modern, unified responsive navigation system supporting two primary sidebar
/// models ([AdaptiveSidebarModel.classic] and [AdaptiveSidebarModel.floating]),
/// three floating modes ([AdaptiveFloatingSidebarMode.elevated],
/// [AdaptiveFloatingSidebarMode.inset], and [AdaptiveFloatingSidebarMode.minimal]),
/// and seamless automatic switching to a mobile bottom navigation bar on compact
/// viewports.
///
/// Developers define navigation items once using [AdaptiveSidebarItem]. The same
/// destination list drives both desktop/tablet sidebar presentation and mobile
/// bottom navigation without duplicated state or configuration drift.
class AdaptiveSidebar extends StatefulWidget {
  const AdaptiveSidebar({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onItemSelected,
    this.onDestinationSelected,
    this.isExpanded,
    this.autoExpandBreakpoint = Breakpoint.large,
    this.expandedWidth,
    this.collapsedWidth,
    this.model = AdaptiveSidebarModel.classic,
    this.floatingMode = AdaptiveFloatingSidebarMode.elevated,
    this.style,
    @Deprecated(
      'Use model and floatingMode with style (AdaptiveSidebarStyleData) instead.',
    )
    this.legacyStyle,
    this.submenuAnimation = AdaptiveSubmenuAnimation.expand,
    this.expansionMode = AdaptiveSubmenuExpansionMode.independent,
    this.onSubmenuExpansionChanged,
    this.header,
    this.footer,
    this.leading,
    this.trailing,
    this.padding,
    this.itemSpacing,
    this.submenuIndentation,
    this.animationDuration,
    this.animationCurve,
    this.backgroundColor,
    this.selectedColor,
    this.indicatorColor,
    this.elevation,
    this.border,
    this.enableRailToggle = false,
    this.onExpansionChanged,
    this.child,
    this.mobileBreakpoint = 600.0,
    this.bottomNavigation = const AdaptiveBottomNavigationConfig(),
    this.enableMobileBottomNavigation = true,
    this.pageController,
    this.pages,
    this.pageBuilder,
  });

  /// The unified navigation items displayed in this navigation system.
  final List<AdaptiveSidebarItem> items;

  /// Index of the currently selected destination.
  final int selectedIndex;

  /// Primary callback invoked when a navigation destination is selected.
  final ValueChanged<int>? onItemSelected;

  /// Callback invoked when a navigation destination is selected.
  ///
  /// Maintained for backward compatibility. Use [onItemSelected] in new code.
  final ValueChanged<int>? onDestinationSelected;

  /// Invokes both [onItemSelected] and [onDestinationSelected] if provided.
  void _handleItemSelected(int index) {
    onItemSelected?.call(index);
    onDestinationSelected?.call(index);
  }

  /// Explicit expanded state. If `null`, automatically resolves based on [autoExpandBreakpoint].
  final bool? isExpanded;

  /// The breakpoint at or above which the sidebar automatically expands when [isExpanded] is null.
  /// Defaults to [Breakpoint.large] (1200dp).
  final Breakpoint autoExpandBreakpoint;

  /// Width in logical pixels when expanded. If null, resolves from [style] or defaults to 240.0 dp.
  final double? expandedWidth;

  /// Width in logical pixels when collapsed. If null, resolves from [style] or defaults to 72.0 dp.
  final double? collapsedWidth;

  /// The primary architectural design model for this sidebar. Defaults to [AdaptiveSidebarModel.classic].
  final AdaptiveSidebarModel model;

  /// The presentation mode when [model] is [AdaptiveSidebarModel.floating].
  /// Defaults to [AdaptiveFloatingSidebarMode.elevated].
  final AdaptiveFloatingSidebarMode floatingMode;

  /// Centralized style data configuration for overriding visual appearance and dimensions.
  final AdaptiveSidebarStyleData? style;

  /// Legacy visual style enum, deprecated in favor of [model] and [floatingMode].
  @Deprecated(
    'Use model and floatingMode with style (AdaptiveSidebarStyleData) instead.',
  )
  final AdaptiveSidebarStyle? legacyStyle;

  /// Transition animation used when expanding/collapsing hierarchical submenus.
  final AdaptiveSubmenuAnimation submenuAnimation;

  /// Expansion policy for submenus (independent vs accordion).
  final AdaptiveSubmenuExpansionMode expansionMode;

  /// Optional callback invoked when a submenu expands or collapses.
  final void Function(int index, bool isExpanded)? onSubmenuExpansionChanged;

  /// Optional callback invoked when the sidebar rail expands or collapses.
  final ValueChanged<bool>? onExpansionChanged;

  /// Optional header widget placed at the top of the sidebar.
  final Widget? header;

  /// Optional footer widget pinned at the bottom of the sidebar.
  final Widget? footer;

  /// Optional widget placed immediately before the navigation items.
  final Widget? leading;

  /// Optional widget placed immediately after the navigation items.
  final Widget? trailing;

  /// Outer padding applied around sidebar contents. If null, resolves from [style] or model default.
  final EdgeInsetsGeometry? padding;

  /// Vertical spacing between consecutive navigation items. If null, resolves from [style] or model default.
  final double? itemSpacing;

  /// Horizontal indentation applied to nested child items. If null, resolves from [style] or defaults to 16.0 dp.
  final double? submenuIndentation;

  /// Animation duration for expand/collapse and selection transitions.
  final Duration? animationDuration;

  /// Animation curve for expand/collapse transitions.
  final Curve? animationCurve;

  /// Background color of the sidebar. If null, resolves according to 4-tier precedence.
  final Color? backgroundColor;

  /// Text and icon color for the selected item. If null, resolves according to 4-tier precedence.
  final Color? selectedColor;

  /// Background color for the selected indicator pill. If null, resolves according to 4-tier precedence.
  final Color? indicatorColor;

  /// Elevation shadow depth. If null, resolves according to 4-tier precedence.
  final double? elevation;

  /// Optional exterior border. If null, resolves according to 4-tier precedence.
  final Border? border;

  /// Whether to render an interactive collapse/expand toggle button.
  final bool enableRailToggle;

  /// Optional page content body hosted by this navigation system.
  ///
  /// On wider viewports, [child] is displayed alongside the sidebar within a [Row].
  /// On compact viewports (< [mobileBreakpoint]), [child] occupies the viewport with
  /// the bottom navigation bar pinned at the bottom within a [Column].
  final Widget? child;

  /// Viewport width threshold in logical pixels below which navigation
  /// automatically presents as a mobile bottom navigation bar.
  /// Defaults to 600.0 dp (compact phone boundary).
  final double mobileBreakpoint;

  /// Dedicated configuration for mobile bottom navigation presentation.
  final AdaptiveBottomNavigationConfig bottomNavigation;

  /// Whether to automatically switch to a bottom navigation bar when viewport
  /// width is below [mobileBreakpoint]. Defaults to `true`.
  final bool enableMobileBottomNavigation;

  /// Optional [PageController] synchronized bidirectionally with navigation selection.
  ///
  /// If provided, selecting destinations animates the controller, and user page swipes
  /// update the selected destination index without recursive callback loops.
  final PageController? pageController;

  /// Optional list of pages rendered inside an internal [PageView] synchronized
  /// with navigation selection.
  final List<Widget>? pages;

  /// Optional page builder rendered inside an internal [PageView] synchronized
  /// with navigation selection.
  final IndexedWidgetBuilder? pageBuilder;

  @override
  State<AdaptiveSidebar> createState() => _AdaptiveSidebarState();
}

class _AdaptiveSidebarState extends State<AdaptiveSidebar> {
  final Set<int> _expandedSubmenus = <int>{};
  bool _internalExpanded = true;
  PageController? _internalPageController;
  bool _isInternalNavigating = false;
  final GlobalKey _bodyKey = GlobalKey(debugLabel: 'adaptive_sidebar_body_key');

  @override
  void initState() {
    super.initState();
    _internalExpanded = widget.isExpanded ?? true;
    _initSubmenuStates();
    if (widget.pageController == null &&
        (widget.pages != null || widget.pageBuilder != null)) {
      _internalPageController =
          PageController(initialPage: widget.selectedIndex);
    }
  }

  @override
  void didUpdateWidget(covariant AdaptiveSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != null &&
        widget.isExpanded != oldWidget.isExpanded) {
      _internalExpanded = widget.isExpanded!;
    }
    if (widget.items != oldWidget.items) {
      _initSubmenuStates();
    }
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      final PageController? controller =
          widget.pageController ?? _internalPageController;
      if (controller != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (controller.hasClients) {
            final int? currentPage = controller.page?.round();
            if (currentPage != widget.selectedIndex) {
              _isInternalNavigating = true;
              controller.jumpToPage(widget.selectedIndex);
              _isInternalNavigating = false;
            }
          }
        });
      }
    }
    if (widget.pageController != oldWidget.pageController) {
      if (oldWidget.pageController == null && _internalPageController != null) {
        _internalPageController?.dispose();
        _internalPageController = null;
      }
      if (widget.pageController == null &&
          (widget.pages != null || widget.pageBuilder != null)) {
        _internalPageController =
            PageController(initialPage: widget.selectedIndex);
      }
    }
  }

  @override
  void dispose() {
    _internalPageController?.dispose();
    super.dispose();
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
      widget.onExpansionChanged?.call(_internalExpanded);
    });
  }

  void _onDestinationTapped(int index) {
    widget._handleItemSelected(index);

    final PageController? controller =
        widget.pageController ?? _internalPageController;
    if (controller != null && controller.hasClients) {
      final int? currentPage = controller.page?.round();
      if (currentPage != index) {
        _isInternalNavigating = true;
        controller
            .animateToPage(
          index,
          duration:
              widget.animationDuration ?? const Duration(milliseconds: 300),
          curve: widget.animationCurve ?? Curves.easeInOut,
        )
            .then((_) {
          _isInternalNavigating = false;
        });
      }
    }
  }

  Widget? _buildBodyContent() {
    if (widget.pages != null) {
      final PageController controller =
          widget.pageController ?? _internalPageController!;
      return PageView(
        controller: controller,
        onPageChanged: (int page) {
          if (!_isInternalNavigating) {
            widget._handleItemSelected(page);
          }
        },
        children: widget.pages!,
      );
    }
    if (widget.pageBuilder != null) {
      final PageController controller =
          widget.pageController ?? _internalPageController!;
      return PageView.builder(
        controller: controller,
        itemCount: widget.items.length,
        onPageChanged: (int page) {
          if (!_isInternalNavigating) {
            widget._handleItemSelected(page);
          }
        },
        itemBuilder: widget.pageBuilder!,
      );
    }
    return widget.child;
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext ctx, AdaptiveLayoutData layout) {
        final double availableWidth = layout.constraints.hasBoundedWidth
            ? layout.constraints.maxWidth
            : layout.screenSize.width;

        final Widget? rawBody = _buildBodyContent();
        final Widget? bodyWidget = rawBody != null
            ? KeyedSubtree(key: _bodyKey, child: rawBody)
            : null;

        // Determine whether to present mobile bottom navigation:
        // 1. Feature enabled
        // 2. Available width < mobileBreakpoint
        // 3. Either body is provided, or available width >= 120.0 dp (not a constrained rail slot)
        final bool isCompact = availableWidth < widget.mobileBreakpoint;
        final bool shouldShowBottomNav = widget.enableMobileBottomNavigation &&
            isCompact &&
            layout.constraints.hasBoundedWidth &&
            (bodyWidget != null || availableWidth >= 120.0);

        if (shouldShowBottomNav) {
          final int safeSelected = widget.items.isEmpty
              ? 0
              : widget.selectedIndex.clamp(0, widget.items.length - 1);

          final Widget bottomNav = AdaptiveBottomNavigationBar(
            items: widget.items,
            selectedIndex: safeSelected,
            onItemSelected: _onDestinationTapped,
            config: widget.bottomNavigation,
            backgroundColor: widget.backgroundColor,
            selectedColor: widget.selectedColor,
            indicatorColor: widget.indicatorColor,
            animationDuration: widget.animationDuration,
            animationCurve:
                widget.animationCurve ?? AdaptiveMotion.emphasizedCurve,
          );

          if (bodyWidget != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: bodyWidget),
                bottomNav,
              ],
            );
          } else {
            return bottomNav;
          }
        }

        // Wider layout: Render Classic or Floating sidebar
        final bool reducedMotion = AdaptiveMotion.isReducedMotion(ctx);

        final AdaptiveSidebarStyleSpec styleSpec =
            AdaptiveSidebarStyleSpec.resolve(
          context: ctx,
          model: widget.model,
          floatingMode: widget.floatingMode,
          styleData: widget.style,
          style: widget.legacyStyle,
          customBackgroundColor: widget.backgroundColor,
          customSelectedColor: widget.selectedColor,
          customIndicatorColor: widget.indicatorColor,
          customBorder: widget.border,
          customElevation: widget.elevation,
          customPadding: widget.padding,
          customItemSpacing: widget.itemSpacing,
          customExpandedWidth: widget.expandedWidth,
          customCollapsedWidth: widget.collapsedWidth,
          customSubmenuIndentation: widget.submenuIndentation,
          customAnimationDuration: widget.animationDuration,
          customAnimationCurve: widget.animationCurve,
        );

        // Resolve expanded state
        final bool autoExpanded = layout.containerBreakpoint.index >=
            widget.autoExpandBreakpoint.index;
        final bool resolvedExpanded = widget.enableRailToggle
            ? _internalExpanded
            : (widget.isExpanded ?? autoExpanded);

        final double targetWidth = resolvedExpanded
            ? styleSpec.expandedWidth
            : styleSpec.collapsedWidth;

        // Ensure target width does not exceed bounded parent width
        final double effectiveWidth = layout.constraints.hasBoundedWidth
            ? targetWidth.clamp(0.0, layout.constraints.maxWidth)
            : targetWidth;

        final Duration duration =
            reducedMotion ? Duration.zero : styleSpec.animationDuration;

        final bool hasOverlay = Overlay.maybeOf(ctx) != null;

        int runningIndex = 0;
        final List<Widget> renderedTiles = <Widget>[];

        for (int i = 0; i < widget.items.length; i++) {
          final AdaptiveSidebarItem item = widget.items[i];
          final int itemIndex = runningIndex;
          runningIndex++;

          // Skip if hidden on desktop
          if (!item.visibleOnDesktop) {
            continue;
          }

          final bool isSubmenuOpen = _expandedSubmenus.contains(i);

          // Check if any descendant of this item is selected
          bool isAncestor = false;
          if (item.hasChildren) {
            for (int c = 0; c < item.children.length; c++) {
              final int childIdx = runningIndex++;
              if (widget.selectedIndex == childIdx) {
                isAncestor = true;
              }
            }
          }

          final bool isSelected = widget.selectedIndex == itemIndex;

          if (renderedTiles.isNotEmpty && styleSpec.itemSpacing > 0) {
            renderedTiles.add(SizedBox(height: styleSpec.itemSpacing));
          }

          renderedTiles.add(
            AdaptiveSidebarTile(
              key: ValueKey(
                  'sidebar_${widget.model.name}_${widget.floatingMode.name}_item_${item.id ?? i}'),
              item: item,
              depth: 0,
              itemIndex: itemIndex,
              isSelected: isSelected,
              isAncestorOfSelected: isAncestor,
              isExpandedSidebar: resolvedExpanded,
              isSubmenuExpanded: isSubmenuOpen,
              onTap:
                  item.enabled ? () => _onDestinationTapped(itemIndex) : null,
              onSubmenuToggle: () => _toggleSubmenu(i),
              expansionMode: widget.expansionMode,
              styleSpec: styleSpec,
              submenuAnimation: widget.submenuAnimation,
              duration: duration,
              curve: styleSpec.animationCurve,
              indentation: styleSpec.submenuIndentation,
              onDestinationSelected: _onDestinationTapped,
              selectedIndex: widget.selectedIndex,
            ),
          );
        }

        Widget wrapSlot(Widget slotChild) {
          final double slotMaxWidth = math.max(
            effectiveWidth,
            math.max(
              styleSpec.expandedWidth,
              styleSpec.collapsedWidth,
            ),
          );
          return ClipRect(
            clipBehavior: Clip.hardEdge,
            child: OverflowBox(
              alignment: AlignmentDirectional.centerStart,
              minWidth: 0.0,
              maxWidth: slotMaxWidth,
              fit: OverflowBoxFit.deferToChild,
              child: slotChild,
            ),
          );
        }

        Widget sidebarContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.header != null) wrapSlot(widget.header!),
            if (widget.leading != null) wrapSlot(widget.leading!),
            Expanded(
              child: SingleChildScrollView(
                padding: styleSpec.padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...renderedTiles,
                    if (widget.trailing != null) wrapSlot(widget.trailing!),
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
            if (widget.footer != null) wrapSlot(widget.footer!),
          ],
        );

        Widget surface = AnimatedContainer(
          key: const Key('adaptive_sidebar_container'),
          duration: duration,
          curve: styleSpec.animationCurve,
          width: effectiveWidth,
          decoration: BoxDecoration(
            color: styleSpec.backgroundColor,
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

        // Frosted Glass Backdrop Filter (if configured)
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

        final Widget sidebarWidget = Material(
          color: Colors.transparent,
          elevation: 0.0,
          child: surface,
        );

        if (bodyWidget != null) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              sidebarWidget,
              Expanded(child: bodyWidget),
            ],
          );
        } else {
          return sidebarWidget;
        }
      },
    );
  }
}
