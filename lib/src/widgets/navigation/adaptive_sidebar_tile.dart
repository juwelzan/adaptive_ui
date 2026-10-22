import 'package:flutter/material.dart';

import 'adaptive_dropdown.dart';
import 'adaptive_sidebar_models.dart';
import 'adaptive_sidebar_styles.dart';

/// Interactive item tile for [AdaptiveSidebar] supporting styling, hover feedback,
/// animated nested submenus, and popup dropdown triggers.
class AdaptiveSidebarTile extends StatefulWidget {
  const AdaptiveSidebarTile({
    super.key,
    required this.item,
    required this.depth,
    required this.isSelected,
    required this.isAncestorOfSelected,
    required this.isExpandedSidebar,
    required this.isSubmenuExpanded,
    required this.onTap,
    required this.onSubmenuToggle,
    required this.styleSpec,
    required this.submenuAnimation,
    required this.duration,
    required this.curve,
    this.indentation = 16.0,
    this.onDestinationSelected,
    this.selectedIndex,
    this.itemIndex = 0,
  });

  final AdaptiveSidebarItem item;
  final int depth;
  final bool isSelected;
  final bool isAncestorOfSelected;
  final bool isExpandedSidebar;
  final bool isSubmenuExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onSubmenuToggle;
  final AdaptiveSidebarStyleSpec styleSpec;
  final AdaptiveSubmenuAnimation submenuAnimation;
  final Duration duration;
  final Curve curve;
  final double indentation;
  final ValueChanged<int>? onDestinationSelected;
  final int? selectedIndex;
  final int itemIndex;

  @override
  State<AdaptiveSidebarTile> createState() => _AdaptiveSidebarTileState();
}

class _AdaptiveSidebarTileState extends State<AdaptiveSidebarTile>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late bool _internalSubmenuExpanded;
  late final AnimationController _submenuController;
  late final Animation<double> _submenuAnimation;
  final GlobalKey<AdaptiveDropdownState> _dropdownKey =
      GlobalKey<AdaptiveDropdownState>();

  @override
  void initState() {
    super.initState();
    _internalSubmenuExpanded =
        widget.isSubmenuExpanded || widget.item.initiallyExpanded;
    _submenuController = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: _internalSubmenuExpanded ? 1.0 : 0.0,
    );

    _submenuAnimation = CurvedAnimation(
      parent: _submenuController,
      curve: widget.curve,
    );
  }

  @override
  void didUpdateWidget(covariant AdaptiveSidebarTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _submenuController.duration = widget.duration;
    }
    if (widget.onSubmenuToggle != null) {
      if (widget.isSubmenuExpanded != oldWidget.isSubmenuExpanded) {
        _internalSubmenuExpanded = widget.isSubmenuExpanded;
        if (widget.isSubmenuExpanded) {
          _submenuController.forward();
        } else {
          _submenuController.reverse();
        }
      }
    }
  }

  @override
  void dispose() {
    _submenuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = widget.isSelected || widget.isAncestorOfSelected;

    final Color iconColor = isHighlighted
        ? widget.styleSpec.activeIconColor
        : widget.styleSpec.inactiveIconColor;

    final Color textColor = isHighlighted
        ? widget.styleSpec.activeTextColor
        : widget.styleSpec.inactiveTextColor;

    final Widget iconWidget = widget.isSelected
        ? (widget.item.selectedIcon ?? widget.item.icon)
        : widget.item.icon;

    final IconThemeData iconTheme = IconThemeData(
      color: iconColor,
      size: 20.0,
    );

    final String? tooltipText = widget.item.tooltip ??
        (!widget.isExpandedSidebar && widget.item.label is Text
            ? (widget.item.label as Text).data
            : null);

    final bool hasOverlay = Overlay.maybeOf(context) != null;

    final double indentPadding =
        widget.isExpandedSidebar ? widget.depth * widget.indentation : 0.0;

    final BoxDecoration itemDecoration =
        widget.styleSpec.activeBackgroundBuilder(
      widget.isSelected,
      _isHovered,
    );

    Widget tile = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Semantics(
        button: true,
        selected: widget.isSelected,
        expanded: widget.item.hasChildren ? _internalSubmenuExpanded : null,
        enabled: widget.item.enabled,
        child: InkWell(
          onTap: widget.item.enabled ? _handleTap : null,
          borderRadius: widget.styleSpec.itemBorderRadius,
          child: AnimatedContainer(
            duration: widget.duration,
            curve: widget.curve,
            constraints: const BoxConstraints(minHeight: 44.0),
            padding: widget.styleSpec.itemPadding,
            decoration: itemDecoration,
            child: LayoutBuilder(
              builder: (BuildContext ctx, BoxConstraints tileConstraints) {
                final bool canFitExpanded = widget.isExpandedSidebar &&
                    tileConstraints.maxWidth >= 80.0;

                if (canFitExpanded) {
                  return Padding(
                    padding: EdgeInsets.only(left: indentPadding),
                    child: ClipRect(
                      child: Row(
                        children: [
                          if (widget.styleSpec.showActiveIndicatorBar &&
                              widget.isSelected)
                            Container(
                              width: widget.styleSpec.indicatorBarWidth,
                              height: 18.0,
                              margin: const EdgeInsets.only(right: 8.0),
                              decoration: BoxDecoration(
                                color: widget.styleSpec.indicatorBarColor,
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                            ),
                          IconTheme(data: iconTheme, child: iconWidget),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: DefaultTextStyle(
                              style: TextStyle(
                                color: textColor,
                                fontWeight: isHighlighted
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 13.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              child: widget.item.label,
                            ),
                          ),
                          if (widget.item.badge != null) ...[
                            const SizedBox(width: 6.0),
                            widget.item.badge!,
                          ],
                          if (widget.item.hasDropdown) ...[
                            const SizedBox(width: 4.0),
                            Icon(
                              Icons.arrow_drop_down,
                              size: 18.0,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                          ] else if (widget.item.hasChildren) ...[
                            const SizedBox(width: 4.0),
                            AnimatedRotation(
                              turns: _internalSubmenuExpanded ? 0.25 : 0.0,
                              duration: widget.duration,
                              curve: widget.curve,
                              child: Icon(
                                Icons.chevron_right,
                                size: 18.0,
                                color: textColor.withValues(alpha: 0.6),
                              ),
                            ),
                          ] else if (widget.item.trailing != null) ...[
                            const SizedBox(width: 6.0),
                            widget.item.trailing!,
                          ],
                        ],
                      ),
                    ),
                  );
                }

                // Compact Rail Mode (icon-only centered)
                return Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      IconTheme(data: iconTheme, child: iconWidget),
                      if (widget.item.badge != null)
                        Positioned(
                          top: -4.0,
                          right: -6.0,
                          child: widget.item.badge!,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    // If item defines dropdown popup menu, wrap with AdaptiveDropdown
    if (widget.item.hasDropdown) {
      tile = AdaptiveDropdown<dynamic>(
        key: _dropdownKey,
        trigger: tile,
        items: widget.item.dropdownItems!,
        onSelected: widget.item.onDropdownSelected,
      );
    }

    if (hasOverlay && tooltipText != null && tooltipText.isNotEmpty) {
      tile = Tooltip(
        message: tooltipText,
        waitDuration: const Duration(milliseconds: 600),
        child: tile,
      );
    }

    // If no nested children or sidebar is collapsed, return tile directly
    if (!widget.item.hasChildren || !widget.isExpandedSidebar) {
      return tile;
    }

    int childRunningIndex = widget.itemIndex + 1;
    final List<Widget> childWidgets = [];
    for (int i = 0; i < widget.item.children.length; i++) {
      final AdaptiveSidebarItem childItem = widget.item.children[i];
      final int thisChildIndex = childRunningIndex;
      final int childSubtreeCount = _countSubtreeItems(childItem);
      childRunningIndex += childSubtreeCount;

      final bool isChildSelected = widget.selectedIndex == thisChildIndex;
      final bool isChildAncestor = widget.selectedIndex != null &&
          widget.selectedIndex! > thisChildIndex &&
          widget.selectedIndex! < thisChildIndex + childSubtreeCount;

      childWidgets.add(
        AdaptiveSidebarTile(
          key: ValueKey('${widget.item.id ?? widget.item.label}_child_$i'),
          item: childItem,
          depth: widget.depth + 1,
          itemIndex: thisChildIndex,
          isSelected: isChildSelected,
          isAncestorOfSelected: isChildAncestor,
          isExpandedSidebar: widget.isExpandedSidebar,
          isSubmenuExpanded: false,
          onTap: childItem.enabled
              ? () => widget.onDestinationSelected?.call(thisChildIndex)
              : null,
          onSubmenuToggle: null,
          styleSpec: widget.styleSpec,
          submenuAnimation: widget.submenuAnimation,
          duration: widget.duration,
          curve: widget.curve,
          indentation: widget.indentation,
          onDestinationSelected: widget.onDestinationSelected,
          selectedIndex: widget.selectedIndex,
        ),
      );
    }

    // Build nested submenu with configured expansion animation
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tile,
        _buildSubmenuTransition(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: childWidgets,
          ),
        ),
      ],
    );
  }

  static int _countSubtreeItems(AdaptiveSidebarItem item) {
    int count = 1;
    for (final child in item.children) {
      count += _countSubtreeItems(child);
    }
    return count;
  }

  void _handleTap() {
    if (widget.item.hasDropdown) {
      _dropdownKey.currentState?.toggle();
    } else if (widget.item.hasChildren) {
      if (widget.onSubmenuToggle != null) {
        widget.onSubmenuToggle!.call();
      } else {
        setState(() {
          _internalSubmenuExpanded = !_internalSubmenuExpanded;
          if (_internalSubmenuExpanded) {
            _submenuController.forward();
          } else {
            _submenuController.reverse();
          }
        });
      }
    } else {
      widget.onTap?.call();
    }
  }

  Widget _buildSubmenuTransition({required Widget child}) {
    return AnimatedBuilder(
      animation: _submenuAnimation,
      builder: (BuildContext context, _) {
        final bool isOffstage = _submenuAnimation.value == 0.0;
        final Widget transitionChild;

        switch (widget.submenuAnimation) {
          case AdaptiveSubmenuAnimation.expand:
          case AdaptiveSubmenuAnimation.sizeTransition:
            transitionChild = SizeTransition(
              sizeFactor: _submenuAnimation,
              alignment: Alignment.topCenter,
              child: child,
            );
            break;

          case AdaptiveSubmenuAnimation.fade:
            transitionChild = SizeTransition(
              sizeFactor: _submenuAnimation,
              alignment: Alignment.topCenter,
              child: FadeTransition(
                opacity: _submenuAnimation,
                child: child,
              ),
            );
            break;

          case AdaptiveSubmenuAnimation.slide:
            transitionChild = SizeTransition(
              sizeFactor: _submenuAnimation,
              alignment: Alignment.topCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, -0.15),
                  end: Offset.zero,
                ).animate(_submenuAnimation),
                child: child,
              ),
            );
            break;

          case AdaptiveSubmenuAnimation.fadeSlide:
            transitionChild = SizeTransition(
              sizeFactor: _submenuAnimation,
              alignment: Alignment.topCenter,
              child: FadeTransition(
                opacity: _submenuAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, -0.1),
                    end: Offset.zero,
                  ).animate(_submenuAnimation),
                  child: child,
                ),
              ),
            );
            break;
        }

        return Offstage(
          offstage: isOffstage,
          child: TickerMode(
            enabled: !isOffstage,
            child: transitionChild,
          ),
        );
      },
    );
  }
}
