import 'package:flutter/material.dart';

import '../../theme/adaptive_colors.dart';
import '../../theme/adaptive_motion.dart';
import '../../theme/adaptive_theme.dart';
import '../../theme/adaptive_theme_data.dart';
import 'adaptive_sidebar_models.dart';

/// Resolved visual specification for [AdaptiveSidebar] rendering.
///
/// Encapsulates all resolved geometry, surfaces, typography colors, indicators,
/// and item layout metrics determined from the 4-tier style precedence:
/// 1. Widget-level explicit override
/// 2. Widget-level [AdaptiveSidebarStyleData]
/// 3. Application-level [AdaptiveSidebarThemeData]
/// 4. Built-in defaults for [AdaptiveSidebarModel] and [AdaptiveFloatingSidebarMode].
@immutable
class AdaptiveSidebarStyleSpec {
  const AdaptiveSidebarStyleSpec({
    required this.backgroundColor,
    required this.outerMargin,
    required this.sidebarBorderRadius,
    required this.border,
    required this.elevation,
    required this.shadowColor,
    required this.itemBorderRadius,
    required this.useBackdropFilter,
    required this.blurSigma,
    required this.activeBackgroundBuilder,
    required this.activeTextColor,
    required this.inactiveTextColor,
    required this.showActiveIndicatorBar,
    required this.indicatorBarColor,
    required this.indicatorBarWidth,
    required this.padding,
    required this.itemPadding,
    required this.itemSpacing,
    required this.activeIconColor,
    required this.inactiveIconColor,
    required this.expandedWidth,
    required this.collapsedWidth,
    required this.submenuIndentation,
    required this.animationDuration,
    required this.animationCurve,
  });

  /// Sidebar surface background color.
  final Color backgroundColor;

  /// Outer margin surrounding the entire sidebar container.
  final EdgeInsetsGeometry outerMargin;

  /// Border radius applied to the outer sidebar frame.
  final BorderRadiusGeometry sidebarBorderRadius;

  /// Exterior border.
  final Border? border;

  /// Surface elevation depth.
  final double elevation;

  /// Elevation shadow color.
  final Color shadowColor;

  /// Border radius applied to active/hover navigation item pills.
  final BorderRadius itemBorderRadius;

  /// Whether to render a backdrop Gaussian blur.
  final bool useBackdropFilter;

  /// Blur intensity for glassmorphic styles.
  final double blurSigma;

  /// Builder for the active item container decoration (fills, borders, shapes).
  final BoxDecoration Function(bool isSelected, bool isHovered)
      activeBackgroundBuilder;

  /// Text color for the selected item.
  final Color activeTextColor;

  /// Text color for inactive items.
  final Color inactiveTextColor;

  /// Whether to render a vertical indicator bar on the item's leading edge.
  final bool showActiveIndicatorBar;

  /// Color of the active indicator bar.
  final Color indicatorBarColor;

  /// Width of the active indicator bar.
  final double indicatorBarWidth;

  /// Padding applied around the scrollable navigation item list.
  final EdgeInsetsGeometry padding;

  /// Internal padding for each individual navigation item tile.
  final EdgeInsetsGeometry itemPadding;

  /// Vertical spacing between consecutive navigation items.
  final double itemSpacing;

  /// Icon color for the active item.
  final Color activeIconColor;

  /// Icon color for inactive items.
  final Color inactiveIconColor;

  /// Width in logical pixels when expanded.
  final double expandedWidth;

  /// Width in logical pixels when collapsed into rail mode.
  final double collapsedWidth;

  /// Indentation step applied to hierarchical nested submenu children.
  final double submenuIndentation;

  /// Duration for expand/collapse and selection transitions.
  final Duration animationDuration;

  /// Easing curve applied to expand/collapse transitions.
  final Curve animationCurve;

  /// Resolves the concrete [AdaptiveSidebarStyleSpec] following 4-tier precedence:
  /// 1. Widget direct parameters
  /// 2. [styleData] ([AdaptiveSidebarStyleData])
  /// 3. Theme defaults ([AdaptiveSidebarThemeData])
  /// 4. Built-in defaults for [model] and [floatingMode].
  static AdaptiveSidebarStyleSpec resolve({
    required BuildContext context,
    AdaptiveSidebarModel model = AdaptiveSidebarModel.classic,
    AdaptiveFloatingSidebarMode floatingMode =
        AdaptiveFloatingSidebarMode.elevated,
    AdaptiveSidebarStyleData? styleData,
    @Deprecated('Use model and floatingMode instead')
    AdaptiveSidebarStyle? style,
    Color? customBackgroundColor,
    Color? customSelectedColor,
    Color? customIndicatorColor,
    Border? customBorder,
    double? customElevation,
    EdgeInsetsGeometry? customOuterMargin,
    BorderRadiusGeometry? customBorderRadius,
    EdgeInsetsGeometry? customPadding,
    EdgeInsetsGeometry? customItemPadding,
    double? customItemSpacing,
    BorderRadius? customItemBorderRadius,
    double? customExpandedWidth,
    double? customCollapsedWidth,
    double? customSubmenuIndentation,
    Duration? customAnimationDuration,
    Curve? customAnimationCurve,
  }) {
    final AdaptiveThemeData adaptiveTheme = AdaptiveTheme.of(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isDark = adaptiveTheme.isDark;
    final AdaptiveColors colors = adaptiveTheme.colors;
    final Color primary = colors.primary;

    final themeSidebar = adaptiveTheme.sidebarTheme;
    final themeStyleData = themeSidebar.style;

    // Handle deprecated AdaptiveSidebarStyle migration mapping
    AdaptiveSidebarModel effectiveModel = model;
    AdaptiveFloatingSidebarMode effectiveFloatingMode = floatingMode;

    if (style != null) {
      switch (style) {
        case AdaptiveSidebarStyle.classicModern:
        case AdaptiveSidebarStyle.pillNavigation:
        case AdaptiveSidebarStyle.railExpandable:
        case AdaptiveSidebarStyle.darkPro:
          effectiveModel = AdaptiveSidebarModel.classic;
          break;
        case AdaptiveSidebarStyle.minimal:
          effectiveModel = AdaptiveSidebarModel.floating;
          effectiveFloatingMode = AdaptiveFloatingSidebarMode.minimal;
          break;
        case AdaptiveSidebarStyle.floating:
        case AdaptiveSidebarStyle.gradientAccent:
        case AdaptiveSidebarStyle.materialExpressive:
          effectiveModel = AdaptiveSidebarModel.floating;
          effectiveFloatingMode = AdaptiveFloatingSidebarMode.elevated;
          break;
        case AdaptiveSidebarStyle.glass:
          effectiveModel = AdaptiveSidebarModel.floating;
          effectiveFloatingMode = AdaptiveFloatingSidebarMode.inset;
          break;
      }
    } else {
      effectiveModel = themeSidebar.model ?? model;
      effectiveFloatingMode = themeSidebar.floatingMode ?? floatingMode;
    }

    // 4-Tier Precedence Resolutions
    final Color? resolvedBg = customBackgroundColor ??
        styleData?.backgroundColor ??
        themeStyleData?.backgroundColor ??
        themeSidebar.backgroundColor;

    final Color? resolvedSelectedColor = customSelectedColor ??
        styleData?.selectedColor ??
        themeStyleData?.selectedColor ??
        themeSidebar.selectedColor;

    final Color? resolvedIndicatorColor = customIndicatorColor ??
        styleData?.indicatorColor ??
        themeStyleData?.indicatorColor ??
        themeSidebar.indicatorColor;

    final Border? resolvedBorder = customBorder ??
        styleData?.border ??
        themeStyleData?.border ??
        themeSidebar.border;

    final double? resolvedElevation = customElevation ??
        styleData?.elevation ??
        themeStyleData?.elevation ??
        themeSidebar.elevation;

    final BorderRadiusGeometry? resolvedBorderRadius = customBorderRadius ??
        styleData?.borderRadius ??
        themeStyleData?.borderRadius;

    final EdgeInsetsGeometry? resolvedOuterMargin = customOuterMargin ??
        styleData?.outerMargin ??
        themeStyleData?.outerMargin;

    final EdgeInsetsGeometry? resolvedPadding =
        customPadding ?? styleData?.padding ?? themeStyleData?.padding;

    final EdgeInsetsGeometry? resolvedItemPadding = customItemPadding ??
        styleData?.itemPadding ??
        themeStyleData?.itemPadding;

    final double? resolvedItemSpacing = customItemSpacing ??
        styleData?.itemSpacing ??
        themeStyleData?.itemSpacing;

    final BorderRadius? resolvedItemBorderRadius = customItemBorderRadius ??
        styleData?.itemBorderRadius ??
        themeStyleData?.itemBorderRadius;

    final Color? resolvedShadowColor =
        styleData?.shadowColor ?? themeStyleData?.shadowColor;

    final double effectiveExpandedWidth = customExpandedWidth ??
        styleData?.width ??
        themeStyleData?.width ??
        themeSidebar.width ??
        240.0;

    final double effectiveCollapsedWidth = customCollapsedWidth ??
        styleData?.collapsedWidth ??
        themeStyleData?.collapsedWidth ??
        themeSidebar.collapsedWidth ??
        72.0;

    final double effectiveSubmenuIndentation = customSubmenuIndentation ??
        styleData?.submenuIndentation ??
        themeStyleData?.submenuIndentation ??
        16.0;

    final Duration effectiveAnimationDuration = customAnimationDuration ??
        styleData?.animationDuration ??
        themeStyleData?.animationDuration ??
        AdaptiveMotion.standard;

    final Curve effectiveAnimationCurve = customAnimationCurve ??
        styleData?.animationCurve ??
        themeStyleData?.animationCurve ??
        AdaptiveMotion.emphasizedCurve;

    // --- Model A: Classic Defaults ---
    if (effectiveModel == AdaptiveSidebarModel.classic) {
      final Color bg = resolvedBg ??
          (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F9FB));
      final Color activeText = resolvedSelectedColor ?? primary;
      final Color inactiveText =
          isDark ? const Color(0xFF8E8E93) : const Color(0xFF6C6C70);
      final Color indicatorColor = resolvedIndicatorColor ?? activeText;
      final BorderRadius itemRadius =
          resolvedItemBorderRadius ?? BorderRadius.circular(8.0);

      return AdaptiveSidebarStyleSpec(
        backgroundColor: bg,
        outerMargin: resolvedOuterMargin ?? EdgeInsets.zero,
        sidebarBorderRadius: resolvedBorderRadius ?? BorderRadius.zero,
        border: resolvedBorder ??
            Border(
              right: BorderSide(
                color: isDark
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFE5E7EB),
                width: 1.0,
              ),
            ),
        elevation: resolvedElevation ?? 0.0,
        shadowColor:
            resolvedShadowColor ?? Colors.black.withValues(alpha: 0.06),
        itemBorderRadius: itemRadius,
        useBackdropFilter: false,
        blurSigma: 0.0,
        activeBackgroundBuilder: (bool isSelected, bool isHovered) {
          if (isSelected) {
            return BoxDecoration(
              color: resolvedIndicatorColor?.withValues(alpha: 0.12) ??
                  (isDark
                      ? primary.withValues(alpha: 0.18)
                      : primary.withValues(alpha: 0.09)),
              borderRadius: itemRadius,
            );
          }
          if (isHovered) {
            return BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: itemRadius,
            );
          }
          return const BoxDecoration();
        },
        activeTextColor: activeText,
        inactiveTextColor: inactiveText,
        showActiveIndicatorBar: true,
        indicatorBarColor: indicatorColor,
        indicatorBarWidth: 3.0,
        padding: resolvedPadding ??
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        itemPadding: resolvedItemPadding ??
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        itemSpacing: resolvedItemSpacing ?? 4.0,
        activeIconColor: activeText,
        inactiveIconColor: inactiveText,
        expandedWidth: effectiveExpandedWidth,
        collapsedWidth: effectiveCollapsedWidth,
        submenuIndentation: effectiveSubmenuIndentation,
        animationDuration: effectiveAnimationDuration,
        animationCurve: effectiveAnimationCurve,
      );
    }

    // --- Model B: Floating (Elevated, Inset, Minimal) ---
    switch (effectiveFloatingMode) {
      // Mode 1: Elevated (Default floating mode)
      case AdaptiveFloatingSidebarMode.elevated:
        final Color bg = resolvedBg ??
            (isDark ? const Color(0xFF1E212B) : Colors.white);
        final Color activeText = resolvedSelectedColor ?? primary;
        final Color inactiveText =
            isDark ? const Color(0xFF9E9EA7) : const Color(0xFF64748B);
        final BorderRadius itemRadius =
            resolvedItemBorderRadius ?? BorderRadius.circular(12.0);

        return AdaptiveSidebarStyleSpec(
          backgroundColor: bg,
          outerMargin:
              resolvedOuterMargin ?? const EdgeInsets.all(12.0),
          sidebarBorderRadius:
              resolvedBorderRadius ?? BorderRadius.circular(16.0),
          border: resolvedBorder ??
              Border.all(
                color: scheme.outlineVariant
                    .withValues(alpha: isDark ? 0.3 : 0.2),
                width: 1.0,
              ),
          elevation: resolvedElevation ?? 3.0,
          shadowColor: resolvedShadowColor ??
              (isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.08)),
          itemBorderRadius: itemRadius,
          useBackdropFilter: false,
          blurSigma: 0.0,
          activeBackgroundBuilder: (bool isSelected, bool isHovered) {
            if (isSelected) {
              return BoxDecoration(
                color: resolvedIndicatorColor ??
                    (isDark
                        ? primary.withValues(alpha: 0.22)
                        : primary.withValues(alpha: 0.12)),
                borderRadius: itemRadius,
              );
            }
            if (isHovered) {
              return BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: itemRadius,
              );
            }
            return const BoxDecoration();
          },
          activeTextColor: activeText,
          inactiveTextColor: inactiveText,
          showActiveIndicatorBar: false,
          indicatorBarColor: activeText,
          indicatorBarWidth: 0.0,
          padding: resolvedPadding ??
              const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
          itemPadding: resolvedItemPadding ??
              const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
          itemSpacing: resolvedItemSpacing ?? 6.0,
          activeIconColor: activeText,
          inactiveIconColor: inactiveText,
          expandedWidth: effectiveExpandedWidth,
          collapsedWidth: effectiveCollapsedWidth,
          submenuIndentation: effectiveSubmenuIndentation,
          animationDuration: effectiveAnimationDuration,
          animationCurve: effectiveAnimationCurve,
        );

      // Mode 2: Inset
      case AdaptiveFloatingSidebarMode.inset:
        final Color bg = resolvedBg ??
            (isDark
                ? const Color(0xFF171A21)
                : Color.alphaBlend(
                    scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    scheme.surface,
                  ));
        final Color activeText = resolvedSelectedColor ?? primary;
        final Color inactiveText =
            isDark ? const Color(0xFF8B949E) : const Color(0xFF57606A);
        final BorderRadius itemRadius =
            resolvedItemBorderRadius ?? BorderRadius.circular(8.0);

        return AdaptiveSidebarStyleSpec(
          backgroundColor: bg,
          outerMargin:
              resolvedOuterMargin ?? const EdgeInsets.all(10.0),
          sidebarBorderRadius:
              resolvedBorderRadius ?? BorderRadius.circular(12.0),
          border: resolvedBorder ??
              Border.all(
                color: scheme.outlineVariant
                    .withValues(alpha: isDark ? 0.45 : 0.35),
                width: 1.0,
              ),
          elevation: resolvedElevation ?? 0.0,
          shadowColor: resolvedShadowColor ?? Colors.transparent,
          itemBorderRadius: itemRadius,
          useBackdropFilter: false,
          blurSigma: 0.0,
          activeBackgroundBuilder: (bool isSelected, bool isHovered) {
            if (isSelected) {
              return BoxDecoration(
                color: resolvedIndicatorColor ??
                    (isDark
                        ? primary.withValues(alpha: 0.18)
                        : primary.withValues(alpha: 0.09)),
                borderRadius: itemRadius,
                border: Border.all(
                  color: primary.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              );
            }
            if (isHovered) {
              return BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: itemRadius,
              );
            }
            return const BoxDecoration();
          },
          activeTextColor: activeText,
          inactiveTextColor: inactiveText,
          showActiveIndicatorBar: false,
          indicatorBarColor: activeText,
          indicatorBarWidth: 0.0,
          padding: resolvedPadding ??
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          itemPadding: resolvedItemPadding ??
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          itemSpacing: resolvedItemSpacing ?? 4.0,
          activeIconColor: activeText,
          inactiveIconColor: inactiveText,
          expandedWidth: effectiveExpandedWidth,
          collapsedWidth: effectiveCollapsedWidth,
          submenuIndentation: effectiveSubmenuIndentation,
          animationDuration: effectiveAnimationDuration,
          animationCurve: effectiveAnimationCurve,
        );

      // Mode 3: Minimal
      case AdaptiveFloatingSidebarMode.minimal:
        final Color bg = resolvedBg ??
            (isDark
                ? const Color(0xFF14161C)
                : scheme.surface.withValues(alpha: 0.95));
        final Color activeText = resolvedSelectedColor ??
            (isDark ? Colors.white : const Color(0xFF111827));
        final Color inactiveText =
            isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);
        final BorderRadius itemRadius =
            resolvedItemBorderRadius ?? BorderRadius.circular(6.0);

        return AdaptiveSidebarStyleSpec(
          backgroundColor: bg,
          outerMargin: resolvedOuterMargin ?? const EdgeInsets.all(8.0),
          sidebarBorderRadius:
              resolvedBorderRadius ?? BorderRadius.circular(8.0),
          border: resolvedBorder ??
              Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.15),
                width: 1.0,
              ),
          elevation: resolvedElevation ?? 0.0,
          shadowColor: resolvedShadowColor ?? Colors.transparent,
          itemBorderRadius: itemRadius,
          useBackdropFilter: false,
          blurSigma: 0.0,
          activeBackgroundBuilder: (bool isSelected, bool isHovered) {
            if (isSelected) {
              return BoxDecoration(
                color: resolvedIndicatorColor ??
                    (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06)),
                borderRadius: itemRadius,
              );
            }
            if (isHovered) {
              return BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: itemRadius,
              );
            }
            return const BoxDecoration();
          },
          activeTextColor: activeText,
          inactiveTextColor: inactiveText,
          showActiveIndicatorBar: false,
          indicatorBarColor: activeText,
          indicatorBarWidth: 0.0,
          padding: resolvedPadding ??
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
          itemPadding: resolvedItemPadding ??
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          itemSpacing: resolvedItemSpacing ?? 2.0,
          activeIconColor: activeText,
          inactiveIconColor: inactiveText,
          expandedWidth: effectiveExpandedWidth,
          collapsedWidth: effectiveCollapsedWidth,
          submenuIndentation: effectiveSubmenuIndentation,
          animationDuration: effectiveAnimationDuration,
          animationCurve: effectiveAnimationCurve,
        );
    }
  }
}
