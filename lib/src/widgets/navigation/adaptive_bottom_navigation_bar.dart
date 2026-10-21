import 'package:flutter/material.dart';

import '../../theme/adaptive_motion.dart';

/// Label visibility policy for [AdaptiveBottomNavigationBar].
enum AdaptiveBottomNavLabelBehavior {
  /// Always display labels for all destinations.
  alwaysShow,

  /// Display label only for the currently selected destination.
  onlyShowSelected,

  /// Never display labels visually (labels remain available for accessibility/semantics).
  neverShow,
}

/// Specification for a destination in [AdaptiveBottomNavigationBar].
@immutable
class AdaptiveBottomNavigationDestination {
  const AdaptiveBottomNavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
    this.tooltip,
    this.enabled = true,
  });

  /// The icon widget displayed for this destination.
  final Widget icon;

  /// Optional icon displayed when this destination is selected.
  final Widget? selectedIcon;

  /// The text label describing this destination.
  final String label;

  /// Optional badge widget displayed adjacent to the icon.
  final Widget? badge;

  /// Tooltip text shown on hover or long-press.
  final String? tooltip;

  /// Whether this destination is interactive. Defaults to `true`.
  final bool enabled;
}

/// A responsive, Material 3-aligned bottom navigation bar with animated indicators,
/// safe area handling, and customizable label behaviors.
class AdaptiveBottomNavigationBar extends StatelessWidget {
  const AdaptiveBottomNavigationBar({
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.labelBehavior = AdaptiveBottomNavLabelBehavior.alwaysShow,
    this.height = 80.0,
    this.elevation = 3.0,
    this.backgroundColor,
    this.indicatorColor,
    this.selectedColor,
    this.unselectedColor,
    this.border,
    this.useSafeArea = true,
    this.animationDuration,
    this.animationCurve = AdaptiveMotion.emphasizedCurve,
  }) : assert(destinations.length >= 2,
            'AdaptiveBottomNavigationBar requires at least 2 destinations.');

  /// The navigation destinations displayed in the bar.
  final List<AdaptiveBottomNavigationDestination> destinations;

  /// Index of the currently selected destination.
  final int selectedIndex;

  /// Callback invoked when a destination is selected.
  final ValueChanged<int>? onDestinationSelected;

  /// Label visibility behavior. Defaults to [AdaptiveBottomNavLabelBehavior.alwaysShow].
  final AdaptiveBottomNavLabelBehavior labelBehavior;

  /// Total height of the navigation bar excluding safe-area bottom insets. Defaults to 80.0 dp.
  final double height;

  /// Surface elevation depth.
  final double elevation;

  /// Background color of the bar. If null, resolves from current theme.
  final Color? backgroundColor;

  /// Background color of the animated pill indicator behind the selected icon.
  final Color? indicatorColor;

  /// Text and icon color for the selected destination.
  final Color? selectedColor;

  /// Text and icon color for unselected destinations.
  final Color? unselectedColor;

  /// Optional top border.
  final Border? border;

  /// Whether to automatically pad for system home-indicator / safe-area insets. Defaults to `true`.
  final bool useSafeArea;

  /// Duration for indicator and label transition animations.
  final Duration? animationDuration;

  /// Easing curve for indicator animations.
  final Curve animationCurve;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool reducedMotion = AdaptiveMotion.isReducedMotion(context);

    final Duration duration = reducedMotion
        ? Duration.zero
        : (animationDuration ?? AdaptiveMotion.standard);

    final Color effectiveBg = backgroundColor ??
        (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F9FB));

    final Color effectiveIndicator = indicatorColor ??
        (isDark
            ? theme.colorScheme.primary.withValues(alpha: 0.24)
            : theme.colorScheme.primary.withValues(alpha: 0.14));

    final Color effectiveSelected =
        selectedColor ?? theme.colorScheme.primary;

    final Color effectiveUnselected = unselectedColor ??
        (isDark ? const Color(0xFF8E8E93) : const Color(0xFF6C6C70));

    Widget content = SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < destinations.length; i++)
            Expanded(
              child: _AdaptiveBottomNavItem(
                destination: destinations[i],
                isSelected: selectedIndex == i,
                labelBehavior: labelBehavior,
                onTap: destinations[i].enabled
                    ? () => onDestinationSelected?.call(i)
                    : null,
                duration: duration,
                curve: animationCurve,
                indicatorColor: effectiveIndicator,
                selectedColor: effectiveSelected,
                unselectedColor: effectiveUnselected,
              ),
            ),
        ],
      ),
    );

    if (useSafeArea) {
      content = SafeArea(top: false, child: content);
    }

    return Material(
      elevation: elevation,
      color: effectiveBg,
      child: Container(
        decoration: BoxDecoration(border: border),
        child: content,
      ),
    );
  }
}

class _AdaptiveBottomNavItem extends StatelessWidget {
  const _AdaptiveBottomNavItem({
    required this.destination,
    required this.isSelected,
    required this.labelBehavior,
    required this.onTap,
    required this.duration,
    required this.curve,
    required this.indicatorColor,
    required this.selectedColor,
    required this.unselectedColor,
  });

  final AdaptiveBottomNavigationDestination destination;
  final bool isSelected;
  final AdaptiveBottomNavLabelBehavior labelBehavior;
  final VoidCallback? onTap;
  final Duration duration;
  final Curve curve;
  final Color indicatorColor;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    final Color itemColor = isSelected ? selectedColor : unselectedColor;
    final Widget iconWidget = isSelected
        ? (destination.selectedIcon ?? destination.icon)
        : destination.icon;

    final Widget pill = AnimatedContainer(
      duration: duration,
      curve: curve,
      width: isSelected ? 64.0 : 44.0,
      height: 32.0,
      decoration: BoxDecoration(
        color: isSelected ? indicatorColor : Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Center(
        child: IconTheme(
          data: IconThemeData(
            color: itemColor,
            size: 24.0,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              iconWidget,
              if (destination.badge != null)
                Positioned(
                  top: -4.0,
                  right: -6.0,
                  child: destination.badge!,
                ),
            ],
          ),
        ),
      ),
    );

    final bool showLabel = switch (labelBehavior) {
      AdaptiveBottomNavLabelBehavior.alwaysShow => true,
      AdaptiveBottomNavLabelBehavior.onlyShowSelected => isSelected,
      AdaptiveBottomNavLabelBehavior.neverShow => false,
    };

    final Widget labelWidget = AnimatedDefaultTextStyle(
      duration: duration,
      curve: curve,
      style: TextStyle(
        fontSize: 12.0,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: itemColor,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: Text(destination.label),
    );

    final Widget itemContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        pill,
        if (showLabel) ...[
          const SizedBox(height: 4.0),
          labelWidget,
        ],
      ],
    );

    final bool hasOverlay = Overlay.maybeOf(context) != null;

    final Widget tile = Semantics(
      button: true,
      selected: isSelected,
      label: destination.label,
      enabled: destination.enabled,
      child: InkResponse(
        onTap: onTap,
        highlightShape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16.0),
        containedInkWell: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48.0, minWidth: 48.0),
          child: itemContent,
        ),
      ),
    );

    if (hasOverlay &&
        destination.tooltip != null &&
        destination.tooltip!.isNotEmpty) {
      return Tooltip(
        message: destination.tooltip!,
        child: tile,
      );
    }

    return tile;
  }
}
