import 'package:flutter/widgets.dart';

/// Distinct visual design models for [AdaptiveSidebar].
enum AdaptiveSidebarStyle {
  /// Clean navigation rows, balanced spacing, and subtle active background.
  classicModern,

  /// Restrained hairline borders, minimal decoration, and crisp typography.
  minimal,

  /// Rounded floating sidebar island with controlled outer margins and soft elevation.
  floating,

  /// Frosted glass appearance with backdrop filter blur and translucent borders.
  glass,

  /// Pill-shaped active indicator capsules with smooth selection motion.
  pillNavigation,

  /// Compact icon rail optimized with an integrated collapse toggle and quick indicators.
  railExpandable,

  /// Selective gradient accent highlights for selected items and active states.
  gradientAccent,

  /// Premium high-contrast dark theme with glowing accents and deep slate surfaces.
  darkPro,

  /// Material 3 Expressive shapes, tonal color schemes, and prominent active shapes.
  materialExpressive,
}

/// Supported transition animation styles for submenu expansion and collapse.
enum AdaptiveSubmenuAnimation {
  /// Smooth size/height expansion.
  expand,

  /// Height expansion coordinated with opacity fade-in.
  fade,

  /// Height expansion coordinated with vertical slide motion.
  slide,

  /// Combined fade-in and slide-down with size expansion.
  fadeSlide,

  /// Standard curved size transition.
  sizeTransition,
}

/// Submenu expansion coordination mode.
enum AdaptiveSubmenuExpansionMode {
  /// Multiple submenus can be open simultaneously.
  independent,

  /// Opening a submenu automatically closes other submenus at the same hierarchy level.
  accordion,
}

/// Specification for a single item within an [AdaptiveDropdownMenu].
@immutable
class AdaptiveDropdownItem<T> {
  const AdaptiveDropdownItem({
    this.value,
    required this.label,
    this.icon,
    this.trailing,
    this.description,
    this.badge,
    this.enabled = true,
    this.isDivider = false,
    this.onTap,
  });

  /// The data value associated with this item when selected.
  final T? value;

  /// The primary label text or widget.
  final Widget label;

  /// Optional leading icon.
  final Widget? icon;

  /// Optional trailing widget (e.g. shortcut text or chevron).
  final Widget? trailing;

  /// Optional secondary descriptive text.
  final String? description;

  /// Optional badge widget.
  final Widget? badge;

  /// Whether this dropdown item is clickable. Defaults to `true`.
  final bool enabled;

  /// Whether this item renders as a visual separator divider.
  final bool isDivider;

  /// Optional direct tap callback.
  final VoidCallback? onTap;

  /// Creates a visual separator item for dropdown menus.
  const AdaptiveDropdownItem.divider()
      : value = null,
        label = const SizedBox.shrink(),
        icon = null,
        trailing = null,
        description = null,
        badge = null,
        enabled = false,
        isDivider = true,
        onTap = null;
}

/// Specification for a navigation item in [AdaptiveSidebar].
///
/// Supports nested submenus via [children] and contextual dropdown menus
/// via [dropdownItems].
@immutable
class AdaptiveSidebarItem {
  const AdaptiveSidebarItem({
    required this.icon,
    required this.label,
    this.id,
    this.selectedIcon,
    this.badge,
    this.tooltip,
    this.enabled = true,
    this.trailing,
    this.children = const <AdaptiveSidebarItem>[],
    this.initiallyExpanded = false,
    this.dropdownItems,
    this.onDropdownSelected,
  });

  /// Unique identifier for this item, used for hierarchy tracking and selection.
  /// If null, the item's position index or label is used.
  final String? id;

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

  /// Optional custom trailing widget (e.g. status indicator or custom chevron).
  final Widget? trailing;

  /// Nested child navigation items for hierarchical submenus.
  final List<AdaptiveSidebarItem> children;

  /// Whether this item's submenu starts expanded on first render.
  final bool initiallyExpanded;

  /// Optional dropdown popup items displayed when clicking this item's dropdown action.
  final List<AdaptiveDropdownItem<dynamic>>? dropdownItems;

  /// Callback invoked when an item from [dropdownItems] is selected.
  final ValueChanged<dynamic>? onDropdownSelected;

  /// Whether this navigation item has nested child items.
  bool get hasChildren => children.isNotEmpty;

  /// Whether this navigation item has dropdown items.
  bool get hasDropdown => dropdownItems != null && dropdownItems!.isNotEmpty;
}
