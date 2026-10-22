import 'package:flutter/material.dart';

import 'adaptive_sidebar_models.dart';

/// Resolved visual specification for an [AdaptiveSidebarStyle].
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
    required this.itemPadding,
    required this.activeIconColor,
    required this.inactiveIconColor,
  });

  /// Sidebar background color.
  final Color backgroundColor;

  /// Outer margin surrounding the entire sidebar (used for Floating style).
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

  /// Whether to render a backdrop Gaussian blur (used for Glass style).
  final bool useBackdropFilter;

  /// Blur intensity for glassmorphic styles.
  final double blurSigma;

  /// Builder for the active item container decoration (fills, gradients, borders).
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

  /// Internal padding for each item tile.
  final EdgeInsetsGeometry itemPadding;

  /// Icon color for the active item.
  final Color activeIconColor;

  /// Icon color for inactive items.
  final Color inactiveIconColor;

  /// Resolves the concrete [AdaptiveSidebarStyleSpec] for a given [style] and [context].
  static AdaptiveSidebarStyleSpec resolve({
    required BuildContext context,
    required AdaptiveSidebarStyle style,
    Color? customBackgroundColor,
    Color? customSelectedColor,
    Color? customIndicatorColor,
    Border? customBorder,
    double? customElevation,
  }) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final ColorScheme scheme = theme.colorScheme;
    final Color primary = scheme.primary;

    switch (style) {
      // 1. Classic Modern
      case AdaptiveSidebarStyle.classicModern:
        final Color bg = customBackgroundColor ??
            (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F9FB));
        final Color activePill = customIndicatorColor ??
            (isDark
                ? primary.withValues(alpha: 0.22)
                : primary.withValues(alpha: 0.12));
        final Color activeText = customSelectedColor ?? primary;
        final Color inactiveText =
            isDark ? const Color(0xFF8E8E93) : const Color(0xFF6C6C70);

        return AdaptiveSidebarStyleSpec(
          backgroundColor: bg,
          outerMargin: EdgeInsets.zero,
          sidebarBorderRadius: BorderRadius.zero,
          border: customBorder ??
              Border(
                right: BorderSide(
                  color: isDark
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xFFE5E7EB),
                  width: 1.0,
                ),
              ),
          elevation: customElevation ?? 0.0,
          shadowColor: Colors.black.withValues(alpha: 0.06),
          itemBorderRadius: BorderRadius.circular(10.0),
          useBackdropFilter: false,
          blurSigma: 0.0,
          activeBackgroundBuilder: (bool isSelected, bool isHovered) {
            if (isSelected) {
              return BoxDecoration(
                color: activePill,
                borderRadius: BorderRadius.circular(10.0),
              );
            }
            if (isHovered) {
              return BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10.0),
              );
            }
            return const BoxDecoration();
          },
          activeTextColor: activeText,
          inactiveTextColor: inactiveText,
          showActiveIndicatorBar: false,
          indicatorBarColor: activeText,
          indicatorBarWidth: 0.0,
          itemPadding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          activeIconColor: activeText,
          inactiveIconColor: inactiveText,
        );

      // 2. Minimal
      case AdaptiveSidebarStyle.minimal:
        final Color bg = customBackgroundColor ??
            (isDark ? const Color(0xFF121214) : Colors.white);
        final Color activeText = customSelectedColor ??
            (isDark ? Colors.white : const Color(0xFF111827));
        final Color inactiveText =
            isDark ? const Color(0xFF71717A) : const Color(0xFF6B7280);

        return AdaptiveSidebarStyleSpec(
          backgroundColor: bg,
          outerMargin: EdgeInsets.zero,
          sidebarBorderRadius: BorderRadius.zero,
          border: customBorder ??
              Border(
                right: BorderSide(
                  color: isDark
                      ? const Color(0xFF27272A)
                      : const Color(0xFFF3F4F6),
                  width: 1.0,
                ),
              ),
          elevation: customElevation ?? 0.0,
          shadowColor: Colors.transparent,
          itemBorderRadius: BorderRadius.circular(6.0),
          useBackdropFilter: false,
          blurSigma: 0.0,
          activeBackgroundBuilder: (bool isSelected, bool isHovered) {
            if (isSelected) {
              return BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(6.0),
              );
            }
            if (isHovered) {
              return BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(6.0),
              );
            }
            return const BoxDecoration();
          },
          activeTextColor: activeText,
          inactiveTextColor: inactiveText,
          showActiveIndicatorBar: true,
          indicatorBarColor: primary,
          indicatorBarWidth: 3.0,
          itemPadding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
          activeIconColor: activeText,
          inactiveIconColor: inactiveText,
        );

      // 3. Floating
      case AdaptiveSidebarStyle.floating:
        final Color bg = customBackgroundColor ??
            (isDark ? const Color(0xFF1F222A) : Colors.white);
        final Color activePill = customIndicatorColor ??
            (isDark
                ? primary.withValues(alpha: 0.25)
                : primary.withValues(alpha: 0.15));
        final Color activeText = customSelectedColor ?? primary;
        final Color inactiveText =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);

        return AdaptiveSidebarStyleSpec(
          backgroundColor: bg,
          outerMargin: const EdgeInsets.all(12.0),
          sidebarBorderRadius: BorderRadius.circular(20.0),
          border: customBorder ??
              Border.all(
                color:
                    isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                width: 1.0,
              ),
          elevation: customElevation ?? 6.0,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          itemBorderRadius: BorderRadius.circular(12.0),
          useBackdropFilter: false,
          blurSigma: 0.0,
          activeBackgroundBuilder: (bool isSelected, bool isHovered) {
            if (isSelected) {
              return BoxDecoration(
                color: activePill,
                borderRadius: BorderRadius.circular(12.0),
              );
            }
            if (isHovered) {
              return BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.0),
              );
            }
            return const BoxDecoration();
          },
          activeTextColor: activeText,
          inactiveTextColor: inactiveText,
          showActiveIndicatorBar: false,
          indicatorBarColor: activeText,
          indicatorBarWidth: 0.0,
          itemPadding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          activeIconColor: activeText,
          inactiveIconColor: inactiveText,
        );

      // 4. Glass
      case AdaptiveSidebarStyle.glass:
        final Color bg = customBackgroundColor ??
            (isDark ? const Color(0xCC1A1C23) : const Color(0xD8FFFFFF));
        final Color activePill = customIndicatorColor ??
            (isDark
                ? primary.withValues(alpha: 0.28)
                : primary.withValues(alpha: 0.18));
        final Color activeText = customSelectedColor ?? primary;
        final Color inactiveText =
            isDark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B);

        return AdaptiveSidebarStyleSpec(
          backgroundColor: bg,
          outerMargin: EdgeInsets.zero,
          sidebarBorderRadius: BorderRadius.zero,
          border: customBorder ??
              Border(
                right: BorderSide(
                  color: isDark
                      ? const Color(0x33FFFFFF)
                      : const Color(0x40FFFFFF),
                  width: 1.0,
                ),
              ),
          elevation: customElevation ?? 0.0,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          itemBorderRadius: BorderRadius.circular(12.0),
          useBackdropFilter: true,
          blurSigma: 16.0,
          activeBackgroundBuilder: (bool isSelected, bool isHovered) {
            if (isSelected) {
              return BoxDecoration(
                color: activePill,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : primary.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              );
            }
            if (isHovered) {
              return BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12.0),
              );
            }
            return const BoxDecoration();
          },
          activeTextColor: activeText,
          inactiveTextColor: inactiveText,
          showActiveIndicatorBar: false,
          indicatorBarColor: activeText,
          indicatorBarWidth: 0.0,
          itemPadding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          activeIconColor: activeText,
          inactiveIconColor: inactiveText,
        );

      // 5. Pill Navigation
      case AdaptiveSidebarStyle.pillNavigation:
        final Color bg = customBackgroundColor ??
            (isDark ? const Color(0xFF181A20) : const Color(0xFFF4F5F8));
        final Color activePill = customIndicatorColor ?? primary;
        const Color activeText = Colors.white;
        final Color inactiveText =
            isDark ? const Color(0xFF9094A6) : const Color(0xFF5F657B);

        return AdaptiveSidebarStyleSpec(
          backgroundColor: bg,
          outerMargin: EdgeInsets.zero,
          sidebarBorderRadius: BorderRadius.zero,
          border: customBorder,
          elevation: customElevation ?? 0.0,
          shadowColor: Colors.transparent,
          itemBorderRadius: BorderRadius.circular(24.0),
          useBackdropFilter: false,
          blurSigma: 0.0,
          activeBackgroundBuilder: (bool isSelected, bool isHovered) {
            if (isSelected) {
              return BoxDecoration(
                color: activePill,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: activePill.withValues(alpha: 0.35),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              );
            }
            if (isHovered) {
              return BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24.0),
              );
            }
            return const BoxDecoration();
          },
          activeTextColor: activeText,
          inactiveTextColor: inactiveText,
          showActiveIndicatorBar: false,
          indicatorBarColor: activePill,
          indicatorBarWidth: 0.0,
          itemPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          activeIconColor: activeText,
          inactiveIconColor: inactiveText,
        );

      // 6. Rail Expandable
      case AdaptiveSidebarStyle.railExpandable:
        final Color bg = customBackgroundColor ??
            (isDark ? const Color(0xFF14161D) : const Color(0xFFF1F3F7));
        final Color activePill = customIndicatorColor ??
            (isDark
                ? primary.withValues(alpha: 0.22)
                : primary.withValues(alpha: 0.14));
        final Color activeText = customSelectedColor ?? primary;
        final Color inactiveText =
            isDark ? const Color(0xFF868B9E) : const Color(0xFF646A80);

        return AdaptiveSidebarStyleSpec(
          backgroundColor: bg,
          outerMargin: EdgeInsets.zero,
          sidebarBorderRadius: BorderRadius.zero,
          border: customBorder ??
              Border(
                right: BorderSide(
                  color: isDark
                      ? const Color(0xFF232734)
                      : const Color(0xFFDFE3EC),
                  width: 1.0,
                ),
              ),
          elevation: customElevation ?? 0.0,
          shadowColor: Colors.transparent,
          itemBorderRadius: BorderRadius.circular(10.0),
          useBackdropFilter: false,
          blurSigma: 0.0,
          activeBackgroundBuilder: (bool isSelected, bool isHovered) {
            if (isSelected) {
              return BoxDecoration(
                color: activePill,
                borderRadius: BorderRadius.circular(10.0),
              );
            }
            if (isHovered) {
              return BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10.0),
              );
            }
            return const BoxDecoration();
          },
          activeTextColor: activeText,
          inactiveTextColor: inactiveText,
          showActiveIndicatorBar: true,
          indicatorBarColor: primary,
          indicatorBarWidth: 3.5,
          itemPadding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          activeIconColor: activeText,
          inactiveIconColor: inactiveText,
        );

      // 7. Gradient Accent
      case AdaptiveSidebarStyle.gradientAccent:
        final Color bg = customBackgroundColor ??
            (isDark ? const Color(0xFF13151B) : Colors.white);
        final Color gradientEnd = scheme.tertiary;
        final Color activeText = Colors.white;
        final Color inactiveText =
            isDark ? const Color(0xFF8F95A5) : const Color(0xFF5B6275);

        return AdaptiveSidebarStyleSpec(
          backgroundColor: bg,
          outerMargin: EdgeInsets.zero,
          sidebarBorderRadius: BorderRadius.zero,
          border: customBorder ??
              Border(
                right: BorderSide(
                  color: isDark
                      ? const Color(0xFF222632)
                      : const Color(0xFFEAEDF3),
                  width: 1.0,
                ),
              ),
          elevation: customElevation ?? 0.0,
          shadowColor: primary.withValues(alpha: 0.25),
          itemBorderRadius: BorderRadius.circular(12.0),
          useBackdropFilter: false,
          blurSigma: 0.0,
          activeBackgroundBuilder: (bool isSelected, bool isHovered) {
            if (isSelected) {
              return BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
                    blurRadius: 10.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              );
            }
            if (isHovered) {
              return BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12.0),
              );
            }
            return const BoxDecoration();
          },
          activeTextColor: activeText,
          inactiveTextColor: inactiveText,
          showActiveIndicatorBar: false,
          indicatorBarColor: primary,
          indicatorBarWidth: 0.0,
          itemPadding:
              const EdgeInsets.symmetric(horizontal: 14.0, vertical: 9.0),
          activeIconColor: activeText,
          inactiveIconColor: inactiveText,
        );

      // 8. Dark Pro
      case AdaptiveSidebarStyle.darkPro:
        final Color bg = customBackgroundColor ?? const Color(0xFF0C0D11);
        final Color activePill =
            customIndicatorColor ?? const Color(0xFF1D2230);
        const Color activeText = Color(0xFF38BDF8); // Cyan electric accent
        const Color inactiveText = Color(0xFF7E8699);

        return AdaptiveSidebarStyleSpec(
          backgroundColor: bg,
          outerMargin: EdgeInsets.zero,
          sidebarBorderRadius: BorderRadius.zero,
          border: customBorder ??
              const Border(
                right: BorderSide(
                  color: Color(0xFF1C1F2B),
                  width: 1.0,
                ),
              ),
          elevation: customElevation ?? 0.0,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          itemBorderRadius: BorderRadius.circular(10.0),
          useBackdropFilter: false,
          blurSigma: 0.0,
          activeBackgroundBuilder: (bool isSelected, bool isHovered) {
            if (isSelected) {
              return BoxDecoration(
                color: activePill,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: activeText.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              );
            }
            if (isHovered) {
              return BoxDecoration(
                color: const Color(0xFF161A24),
                borderRadius: BorderRadius.circular(10.0),
              );
            }
            return const BoxDecoration();
          },
          activeTextColor: activeText,
          inactiveTextColor: inactiveText,
          showActiveIndicatorBar: true,
          indicatorBarColor: activeText,
          indicatorBarWidth: 3.0,
          itemPadding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          activeIconColor: activeText,
          inactiveIconColor: inactiveText,
        );

      // 9. Material Expressive
      case AdaptiveSidebarStyle.materialExpressive:
        final Color bg = customBackgroundColor ?? scheme.surface;
        final Color activePill =
            customIndicatorColor ?? scheme.secondaryContainer;
        final Color activeText =
            customSelectedColor ?? scheme.onSecondaryContainer;
        final Color inactiveText = scheme.onSurfaceVariant;

        return AdaptiveSidebarStyleSpec(
          backgroundColor: bg,
          outerMargin: EdgeInsets.zero,
          sidebarBorderRadius: BorderRadius.zero,
          border: customBorder,
          elevation: customElevation ?? 1.0,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          itemBorderRadius: const BorderRadius.only(
            topRight: Radius.circular(24.0),
            bottomRight: Radius.circular(24.0),
            topLeft: Radius.circular(4.0),
            bottomLeft: Radius.circular(4.0),
          ),
          useBackdropFilter: false,
          blurSigma: 0.0,
          activeBackgroundBuilder: (bool isSelected, bool isHovered) {
            if (isSelected) {
              return const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24.0),
                  bottomRight: Radius.circular(24.0),
                  topLeft: Radius.circular(4.0),
                  bottomLeft: Radius.circular(4.0),
                ),
              );
            }
            if (isHovered) {
              return BoxDecoration(
                color: scheme.onSurface.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24.0),
                  bottomRight: Radius.circular(24.0),
                  topLeft: Radius.circular(4.0),
                  bottomLeft: Radius.circular(4.0),
                ),
              );
            }
            return const BoxDecoration();
          },
          activeTextColor: activeText,
          inactiveTextColor: inactiveText,
          showActiveIndicatorBar: false,
          indicatorBarColor: activePill,
          indicatorBarWidth: 0.0,
          itemPadding:
              const EdgeInsets.symmetric(horizontal: 14.0, vertical: 9.0),
          activeIconColor: activeText,
          inactiveIconColor: inactiveText,
        );
    }
  }
}
