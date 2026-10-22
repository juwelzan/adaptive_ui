import 'package:flutter/widgets.dart';

/// The two primary visual architecture models for [AdaptiveSidebar].
enum AdaptiveSidebarModel {
  /// A clean, structured, conventional full-height sidebar.
  ///
  /// Designed for standard application layouts, Scaffolds, and split shells.
  /// Features zero outer margin, squared corners, crisp vertical boundary,
  /// and subtle active-item indicators.
  classic,

  /// A modern floating sidebar island with configurable outer spacing,
  /// surface shape, elevation, and distinct interaction modes.
  floating,
}

/// The three visual presentation modes available when using [AdaptiveSidebarModel.floating].
enum AdaptiveFloatingSidebarMode {
  /// The default floating mode.
  ///
  /// Features rounded corners, subtle elevation and shadow, comfortable
  /// padding, and balanced visual separation from the background.
  elevated,

  /// A floating sidebar that visually sits inset within the surrounding layout.
  ///
  /// Features soft rounded corners, restrained hairline borders, zero/minimal shadow,
  /// and crisp internal grouping.
  inset,

  /// A lightweight, distraction-free floating presentation.
  ///
  /// Features very subtle surface separation, compact spacing, clean typography,
  /// and minimal decoration.
  minimal,
}

/// Centralized, immutable styling and dimension configuration for [AdaptiveSidebar].
///
/// Allows developers to customize visual properties without cluttering the
/// widget constructor. When properties are omitted, they resolve according
/// to the 4-tier precedence:
/// 1. Widget-level override (e.g. `AdaptiveSidebar.backgroundColor`)
/// 2. Style configuration ([AdaptiveSidebarStyleData])
/// 3. Theme default ([AdaptiveSidebarThemeData])
/// 4. Built-in defaults for the active [AdaptiveSidebarModel] and [AdaptiveFloatingSidebarMode].
@immutable
class AdaptiveSidebarStyleData {
  const AdaptiveSidebarStyleData({
    this.width,
    this.collapsedWidth,
    this.borderRadius,
    this.elevation,
    this.shadowColor,
    this.border,
    this.backgroundColor,
    this.selectedColor,
    this.indicatorColor,
    this.outerMargin,
    this.padding,
    this.itemPadding,
    this.itemSpacing,
    this.itemBorderRadius,
    this.submenuIndentation,
    this.animationDuration,
    this.animationCurve,
  });

  /// Width in logical pixels when the sidebar is expanded.
  final double? width;

  /// Width in logical pixels when the sidebar is collapsed (rail mode).
  final double? collapsedWidth;

  /// Border radius applied to the outer sidebar surface container.
  final BorderRadiusGeometry? borderRadius;

  /// Surface elevation depth and shadow casting.
  final double? elevation;

  /// Shadow color cast when [elevation] is greater than zero.
  final Color? shadowColor;

  /// Exterior border drawn around the sidebar surface.
  final Border? border;

  /// Primary background color of the sidebar surface.
  final Color? backgroundColor;

  /// Text and icon accent color for selected navigation items.
  final Color? selectedColor;

  /// Background fill or indicator bar color for the selected item pill.
  final Color? indicatorColor;

  /// Outer spacing surrounding the floating sidebar container.
  final EdgeInsetsGeometry? outerMargin;

  /// Internal padding enclosing the scrollable list of navigation items.
  final EdgeInsetsGeometry? padding;

  /// Padding inside each individual navigation item row.
  final EdgeInsetsGeometry? itemPadding;

  /// Vertical spacing between consecutive navigation items.
  final double? itemSpacing;

  /// Border radius applied to individual navigation item hover/active pills.
  final BorderRadius? itemBorderRadius;

  /// Horizontal indentation step applied per depth level for nested submenus.
  final double? submenuIndentation;

  /// Duration for expand/collapse and selection transitions.
  final Duration? animationDuration;

  /// Easing curve applied to expand/collapse and selection transitions.
  final Curve? animationCurve;

  /// Creates a copy of this style configuration with specified properties replaced.
  AdaptiveSidebarStyleData copyWith({
    double? width,
    double? collapsedWidth,
    BorderRadiusGeometry? borderRadius,
    double? elevation,
    Color? shadowColor,
    Border? border,
    Color? backgroundColor,
    Color? selectedColor,
    Color? indicatorColor,
    EdgeInsetsGeometry? outerMargin,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? itemPadding,
    double? itemSpacing,
    BorderRadius? itemBorderRadius,
    double? submenuIndentation,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return AdaptiveSidebarStyleData(
      width: width ?? this.width,
      collapsedWidth: collapsedWidth ?? this.collapsedWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      border: border ?? this.border,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedColor: selectedColor ?? this.selectedColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      outerMargin: outerMargin ?? this.outerMargin,
      padding: padding ?? this.padding,
      itemPadding: itemPadding ?? this.itemPadding,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      itemBorderRadius: itemBorderRadius ?? this.itemBorderRadius,
      submenuIndentation: submenuIndentation ?? this.submenuIndentation,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }

  /// Linearly interpolates between two [AdaptiveSidebarStyleData] configurations.
  static AdaptiveSidebarStyleData? lerp(
    AdaptiveSidebarStyleData? a,
    AdaptiveSidebarStyleData? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    return AdaptiveSidebarStyleData(
      width: a?.width != null && b?.width != null
          ? a!.width! + (b!.width! - a.width!) * t
          : (t < 0.5 ? a?.width : b?.width),
      collapsedWidth: a?.collapsedWidth != null && b?.collapsedWidth != null
          ? a!.collapsedWidth! + (b!.collapsedWidth! - a.collapsedWidth!) * t
          : (t < 0.5 ? a?.collapsedWidth : b?.collapsedWidth),
      borderRadius:
          BorderRadiusGeometry.lerp(a?.borderRadius, b?.borderRadius, t),
      elevation: a?.elevation != null && b?.elevation != null
          ? a!.elevation! + (b!.elevation! - a.elevation!) * t
          : (t < 0.5 ? a?.elevation : b?.elevation),
      shadowColor: Color.lerp(a?.shadowColor, b?.shadowColor, t),
      border: Border.lerp(a?.border, b?.border, t),
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      selectedColor: Color.lerp(a?.selectedColor, b?.selectedColor, t),
      indicatorColor: Color.lerp(a?.indicatorColor, b?.indicatorColor, t),
      outerMargin: EdgeInsetsGeometry.lerp(a?.outerMargin, b?.outerMargin, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      itemPadding: EdgeInsetsGeometry.lerp(a?.itemPadding, b?.itemPadding, t),
      itemSpacing: a?.itemSpacing != null && b?.itemSpacing != null
          ? a!.itemSpacing! + (b!.itemSpacing! - a.itemSpacing!) * t
          : (t < 0.5 ? a?.itemSpacing : b?.itemSpacing),
      itemBorderRadius:
          BorderRadius.lerp(a?.itemBorderRadius, b?.itemBorderRadius, t),
      submenuIndentation:
          a?.submenuIndentation != null && b?.submenuIndentation != null
              ? a!.submenuIndentation! +
                  (b!.submenuIndentation! - a.submenuIndentation!) * t
              : (t < 0.5 ? a?.submenuIndentation : b?.submenuIndentation),
      animationDuration: t < 0.5 ? a?.animationDuration : b?.animationDuration,
      animationCurve: t < 0.5 ? a?.animationCurve : b?.animationCurve,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveSidebarStyleData &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          collapsedWidth == other.collapsedWidth &&
          borderRadius == other.borderRadius &&
          elevation == other.elevation &&
          shadowColor == other.shadowColor &&
          border == other.border &&
          backgroundColor == other.backgroundColor &&
          selectedColor == other.selectedColor &&
          indicatorColor == other.indicatorColor &&
          outerMargin == other.outerMargin &&
          padding == other.padding &&
          itemPadding == other.itemPadding &&
          itemSpacing == other.itemSpacing &&
          itemBorderRadius == other.itemBorderRadius &&
          submenuIndentation == other.submenuIndentation &&
          animationDuration == other.animationDuration &&
          animationCurve == other.animationCurve;

  @override
  int get hashCode => Object.hash(
        width,
        collapsedWidth,
        borderRadius,
        elevation,
        shadowColor,
        border,
        backgroundColor,
        selectedColor,
        indicatorColor,
        outerMargin,
        padding,
        itemPadding,
        itemSpacing,
        itemBorderRadius,
        submenuIndentation,
        animationDuration,
        animationCurve,
      );
}

/// Legacy visual design models for [AdaptiveSidebar].
///
/// Deprecated in favor of the two primary models [AdaptiveSidebarModel] (classic and floating)
/// and the three floating modes [AdaptiveFloatingSidebarMode] (elevated, inset, minimal).
@Deprecated(
  'Use AdaptiveSidebarModel and AdaptiveFloatingSidebarMode with AdaptiveSidebarStyleData instead.',
)
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
