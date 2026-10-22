import 'package:flutter/material.dart';

import '../../theme/adaptive_motion.dart';
import '../../theme/adaptive_theme.dart';
import '../../theme/adaptive_theme_data.dart';
import 'adaptive_sidebar_models.dart';

export 'adaptive_sidebar_models.dart'
    show
        AdaptiveBottomNavLabelBehavior,
        AdaptiveBottomNavOverflowPolicy,
        AdaptiveBottomNavigationConfig;

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
    this.labelWidget,
    this.customBuilder,
  });

  /// Factory creating an [AdaptiveBottomNavigationDestination] from an [AdaptiveSidebarItem].
  factory AdaptiveBottomNavigationDestination.fromSidebarItem(
    AdaptiveSidebarItem item,
  ) {
    return AdaptiveBottomNavigationDestination(
      icon: item.icon,
      selectedIcon: item.selectedIcon,
      label: item.labelText,
      labelWidget: item.label,
      badge: item.badge,
      tooltip: item.tooltip,
      enabled: item.enabled,
      customBuilder: item.customBuilder,
    );
  }

  /// The icon widget displayed for this destination.
  final Widget icon;

  /// Optional icon displayed when this destination is selected.
  final Widget? selectedIcon;

  /// The text label describing this destination.
  final String label;

  /// Optional custom label widget (e.g. rich text or styled text).
  final Widget? labelWidget;

  /// Optional badge widget displayed adjacent to the icon.
  final Widget? badge;

  /// Tooltip text shown on hover or long-press.
  final String? tooltip;

  /// Whether this destination is interactive. Defaults to `true`.
  final bool enabled;

  /// Optional custom widget builder for this destination.
  final Widget Function(BuildContext context, bool isSelected)? customBuilder;
}

/// A responsive, Material 3-aligned bottom navigation bar with animated indicators,
/// safe area handling, configurable overflow policies (scroll, menu, auto), and
/// constraint-safe layout across 1 to 10+ destinations.
class AdaptiveBottomNavigationBar extends StatelessWidget {
  const AdaptiveBottomNavigationBar({
    super.key,
    this.destinations,
    this.items,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.onItemSelected,
    this.config,
    this.labelBehavior,
    this.height,
    this.elevation,
    this.backgroundColor,
    this.indicatorColor,
    this.selectedColor,
    this.unselectedColor,
    this.border,
    this.borderRadius,
    this.useSafeArea,
    this.animationDuration,
    this.animationCurve,
    this.overflowPolicy,
    this.maxVisibleItems,
    this.moreIcon,
    this.moreLabel,
  }) : assert(
          destinations != null || items != null,
          'AdaptiveBottomNavigationBar requires either destinations or items.',
        );

  /// Explicit list of destinations displayed in the bar.
  final List<AdaptiveBottomNavigationDestination>? destinations;

  /// Unified navigation items shared with [AdaptiveSidebar].
  ///
  /// Only destinations where [AdaptiveSidebarItem.visibleOnMobile] is `true`
  /// will be displayed.
  final List<AdaptiveSidebarItem>? items;

  /// Index of the currently selected destination.
  final int selectedIndex;

  /// Callback invoked when a destination is selected.
  final ValueChanged<int>? onDestinationSelected;

  /// Callback invoked when a destination is selected (unified API).
  final ValueChanged<int>? onItemSelected;

  /// Dedicated configuration object for bottom navigation styling and policies.
  final AdaptiveBottomNavigationConfig? config;

  /// Label visibility behavior. Overrides [config] if provided.
  final AdaptiveBottomNavLabelBehavior? labelBehavior;

  /// Total height of the navigation bar excluding safe-area bottom insets.
  final double? height;

  /// Surface elevation depth.
  final double? elevation;

  /// Background color of the bar.
  final Color? backgroundColor;

  /// Background color of the animated indicator pill behind the selected icon.
  final Color? indicatorColor;

  /// Text and icon color for the selected destination.
  final Color? selectedColor;

  /// Text and icon color for unselected destinations.
  final Color? unselectedColor;

  /// Top or surrounding border.
  final Border? border;

  /// Border radius applied to the bar surface.
  final BorderRadiusGeometry? borderRadius;

  /// Whether to automatically pad for system home-indicator / safe-area insets.
  final bool? useSafeArea;

  /// Duration for indicator and label transition animations.
  final Duration? animationDuration;

  /// Easing curve for indicator animations.
  final Curve? animationCurve;

  /// Policy for handling navigation items that exceed available width.
  final AdaptiveBottomNavOverflowPolicy? overflowPolicy;

  /// Maximum number of primary items visible before overflow occurs.
  final int? maxVisibleItems;

  /// Icon representing the 'More' destination when overflow occurs.
  final Widget? moreIcon;

  /// Text label for the 'More' destination.
  final String? moreLabel;

  void _handleSelected(int index) {
    onDestinationSelected?.call(index);
    onItemSelected?.call(index);
  }

  List<AdaptiveBottomNavigationDestination> _resolveDestinations() {
    if (items != null) {
      return items!
          .where((AdaptiveSidebarItem item) => item.visibleOnMobile)
          .map(AdaptiveBottomNavigationDestination.fromSidebarItem)
          .toList();
    }
    return destinations ?? const <AdaptiveBottomNavigationDestination>[];
  }

  @override
  Widget build(BuildContext context) {
    final List<AdaptiveBottomNavigationDestination> resolvedDestinations =
        _resolveDestinations();

    if (resolvedDestinations.isEmpty) {
      return const SizedBox.shrink();
    }

    final AdaptiveThemeData adaptiveTheme = AdaptiveTheme.of(context);
    final bool isDark = adaptiveTheme.isDark;
    final bool reducedMotion = AdaptiveMotion.isReducedMotion(context);

    // 4-tier precedence: direct parameter > config > theme > built-in defaults
    final Duration duration = reducedMotion
        ? Duration.zero
        : (animationDuration ??
            config?.animationDuration ??
            AdaptiveMotion.standard);

    final Curve effectiveCurve = animationCurve ??
        config?.animationCurve ??
        AdaptiveMotion.emphasizedCurve;

    final double effectiveHeight =
        height ?? config?.height ?? adaptiveTheme.bottomNavTheme.height ?? 80.0;

    final double effectiveElevation = elevation ??
        config?.elevation ??
        adaptiveTheme.bottomNavTheme.elevation ??
        3.0;

    final AdaptiveBottomNavLabelBehavior effectiveLabelBehavior =
        labelBehavior ??
            config?.labelBehavior ??
            adaptiveTheme.bottomNavTheme.labelBehavior ??
            AdaptiveBottomNavLabelBehavior.alwaysShow;

    final Color effectiveBg = backgroundColor ??
        config?.backgroundColor ??
        adaptiveTheme.bottomNavTheme.backgroundColor ??
        adaptiveTheme.colors.surface;

    final Color effectiveIndicator = indicatorColor ??
        config?.indicatorColor ??
        adaptiveTheme.bottomNavTheme.indicatorColor ??
        (isDark
            ? adaptiveTheme.colors.primary.withValues(alpha: 0.24)
            : adaptiveTheme.colors.primary.withValues(alpha: 0.14));

    final Color effectiveSelected = selectedColor ??
        config?.selectedColor ??
        adaptiveTheme.bottomNavTheme.selectedColor ??
        adaptiveTheme.colors.primary;

    final Color effectiveUnselected = unselectedColor ??
        config?.unselectedColor ??
        adaptiveTheme.bottomNavTheme.unselectedColor ??
        adaptiveTheme.colors.onSurfaceVariant;

    final Border? effectiveBorder = border ?? config?.border;
    final BorderRadiusGeometry? effectiveBorderRadius =
        borderRadius ?? config?.borderRadius;

    final bool effectiveUseSafeArea =
        useSafeArea ?? config?.useSafeArea ?? true;

    final AdaptiveBottomNavOverflowPolicy effectivePolicy = overflowPolicy ??
        config?.overflowPolicy ??
        AdaptiveBottomNavOverflowPolicy.auto;

    final int effectiveMaxVisible =
        maxVisibleItems ?? config?.maxVisibleItems ?? 5;

    final Widget effectiveMoreIcon =
        moreIcon ?? config?.moreIcon ?? const Icon(Icons.more_horiz);

    final String effectiveMoreLabel = moreLabel ?? config?.moreLabel ?? 'More';

    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) {
        final double availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(ctx).width;

        final int count = resolvedDestinations.length;

        // Determine presentation mode based on overflow policy and constraint capacity
        final bool shouldScroll =
            effectivePolicy == AdaptiveBottomNavOverflowPolicy.scroll;

        final bool shouldShowMenu =
            (effectivePolicy == AdaptiveBottomNavOverflowPolicy.menu &&
                    count > effectiveMaxVisible) ||
                (effectivePolicy == AdaptiveBottomNavOverflowPolicy.auto &&
                    (count > effectiveMaxVisible ||
                        (availableWidth > 0 &&
                            availableWidth < count * 64.0 &&
                            count > 2)));

        Widget barItems;

        if (count == 1) {
          // Exactly one item: render centered with comfortable width
          barItems = Center(
            child: SizedBox(
              width: availableWidth.clamp(72.0, 160.0),
              child: _AdaptiveBottomNavItem(
                destination: resolvedDestinations[0],
                isSelected: selectedIndex == 0,
                labelBehavior: effectiveLabelBehavior,
                onTap: resolvedDestinations[0].enabled
                    ? () => _handleSelected(0)
                    : null,
                duration: duration,
                curve: effectiveCurve,
                indicatorColor: effectiveIndicator,
                selectedColor: effectiveSelected,
                unselectedColor: effectiveUnselected,
                config: config,
              ),
            ),
          );
        } else if (shouldScroll) {
          // Scroll policy: horizontally scrollable row of items
          final double itemWidth = (availableWidth / count).clamp(68.0, 120.0);
          barItems = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < count; i++)
                  SizedBox(
                    width: itemWidth,
                    child: _AdaptiveBottomNavItem(
                      destination: resolvedDestinations[i],
                      isSelected: selectedIndex == i,
                      labelBehavior: effectiveLabelBehavior,
                      onTap: resolvedDestinations[i].enabled
                          ? () => _handleSelected(i)
                          : null,
                      duration: duration,
                      curve: effectiveCurve,
                      indicatorColor: effectiveIndicator,
                      selectedColor: effectiveSelected,
                      unselectedColor: effectiveUnselected,
                      config: config,
                    ),
                  ),
              ],
            ),
          );
        } else if (shouldShowMenu) {
          // Menu policy: primary items + "More" overflow item
          final int primaryCount =
              (effectiveMaxVisible - 1).clamp(1, count - 1);
          final List<AdaptiveBottomNavigationDestination> primaryItems =
              resolvedDestinations.sublist(0, primaryCount);
          final List<AdaptiveBottomNavigationDestination> overflowItems =
              resolvedDestinations.sublist(primaryCount);

          final bool isMoreSelected = selectedIndex >= primaryCount;

          barItems = Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < primaryItems.length; i++)
                Expanded(
                  child: _AdaptiveBottomNavItem(
                    destination: primaryItems[i],
                    isSelected: selectedIndex == i,
                    labelBehavior: effectiveLabelBehavior,
                    onTap: primaryItems[i].enabled
                        ? () => _handleSelected(i)
                        : null,
                    duration: duration,
                    curve: effectiveCurve,
                    indicatorColor: effectiveIndicator,
                    selectedColor: effectiveSelected,
                    unselectedColor: effectiveUnselected,
                    config: config,
                  ),
                ),
              Expanded(
                child: _AdaptiveBottomNavItem(
                  destination: AdaptiveBottomNavigationDestination(
                    icon: effectiveMoreIcon,
                    selectedIcon: effectiveMoreIcon,
                    label: effectiveMoreLabel,
                    tooltip: effectiveMoreLabel,
                  ),
                  isSelected: isMoreSelected,
                  labelBehavior: effectiveLabelBehavior,
                  onTap: () {
                    _showMoreMenu(
                      ctx,
                      overflowItems: overflowItems,
                      primaryCount: primaryCount,
                      selectedIndex: selectedIndex,
                      moreLabel: effectiveMoreLabel,
                      selectedColor: effectiveSelected,
                      onSelect: _handleSelected,
                    );
                  },
                  duration: duration,
                  curve: effectiveCurve,
                  indicatorColor: effectiveIndicator,
                  selectedColor: effectiveSelected,
                  unselectedColor: effectiveUnselected,
                  config: config,
                ),
              ),
            ],
          );
        } else {
          // Standard evenly-distributed row
          barItems = Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < count; i++)
                Expanded(
                  child: _AdaptiveBottomNavItem(
                    destination: resolvedDestinations[i],
                    isSelected: selectedIndex == i,
                    labelBehavior: effectiveLabelBehavior,
                    onTap: resolvedDestinations[i].enabled
                        ? () => _handleSelected(i)
                        : null,
                    duration: duration,
                    curve: effectiveCurve,
                    indicatorColor: effectiveIndicator,
                    selectedColor: effectiveSelected,
                    unselectedColor: effectiveUnselected,
                    config: config,
                  ),
                ),
            ],
          );
        }

        Widget content = SizedBox(
          height: effectiveHeight,
          child: barItems,
        );

        if (effectiveUseSafeArea) {
          content = SafeArea(top: false, child: content);
        }

        return Material(
          elevation: effectiveElevation,
          color: effectiveBg,
          shape: effectiveBorderRadius != null
              ? RoundedRectangleBorder(
                  borderRadius: effectiveBorderRadius,
                  side: effectiveBorder?.top ?? BorderSide.none,
                )
              : null,
          shadowColor: config?.shadowColor,
          child: Container(
            decoration: BoxDecoration(
              border: effectiveBorder,
              borderRadius: effectiveBorderRadius,
            ),
            child: content,
          ),
        );
      },
    );
  }

  void _showMoreMenu(
    BuildContext context, {
    required List<AdaptiveBottomNavigationDestination> overflowItems,
    required int primaryCount,
    required int selectedIndex,
    required String moreLabel,
    required Color selectedColor,
    required ValueChanged<int> onSelect,
  }) {
    if (Navigator.maybeOf(context) == null) {
      if (overflowItems.isNotEmpty) {
        onSelect(primaryCount);
      }
      return;
    }

    Widget buildSheetContent(BuildContext sheetCtx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Text(
                    moreLabel,
                    style: Theme.of(sheetCtx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: overflowItems.length,
                itemBuilder: (BuildContext listCtx, int index) {
                  final int originalIndex = primaryCount + index;
                  final AdaptiveBottomNavigationDestination item =
                      overflowItems[index];
                  final bool isSelected = selectedIndex == originalIndex;

                  return ListTile(
                    leading: isSelected
                        ? (item.selectedIcon ?? item.icon)
                        : item.icon,
                    title: item.labelWidget ?? Text(item.label),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.badge != null) item.badge!,
                        if (isSelected) ...[
                          const SizedBox(width: 8.0),
                          Icon(Icons.check, color: selectedColor),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    enabled: item.enabled,
                    onTap: () {
                      Navigator.of(sheetCtx).pop();
                      onSelect(originalIndex);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    if (Localizations.of<MaterialLocalizations>(
            context, MaterialLocalizations) ==
        null) {
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'More Navigation Menu',
        pageBuilder: (BuildContext dialogCtx, _, __) {
          return Localizations(
            locale: const Locale('en', 'US'),
            delegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            child: Material(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: buildSheetContent(dialogCtx),
                ),
              ),
            ),
          );
        },
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: buildSheetContent,
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
    this.config,
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
  final AdaptiveBottomNavigationConfig? config;

  @override
  Widget build(BuildContext context) {
    if (destination.customBuilder != null) {
      return destination.customBuilder!(context, isSelected);
    }

    final Color effectiveIconColor = isSelected
        ? (config?.selectedIconColor ?? selectedColor)
        : (config?.unselectedIconColor ?? unselectedColor);

    final Widget iconWidget = isSelected
        ? (destination.selectedIcon ?? destination.icon)
        : destination.icon;

    final double iconSize = config?.iconSize ?? 24.0;
    final Size pillSize =
        config?.indicatorSize ?? Size(isSelected ? 64.0 : 44.0, 32.0);

    final Widget pill = AnimatedContainer(
      duration: duration,
      curve: curve,
      width: pillSize.width,
      height: pillSize.height,
      decoration: BoxDecoration(
        color: isSelected ? indicatorColor : Colors.transparent,
        borderRadius: BorderRadius.circular(pillSize.height / 2.0),
      ),
      child: Center(
        child: IconTheme(
          data: IconThemeData(
            color: effectiveIconColor,
            size: iconSize,
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

    final TextStyle defaultLabelStyle = TextStyle(
      fontSize: 12.0,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      color: isSelected ? selectedColor : unselectedColor,
    );

    final TextStyle effectiveStyle = isSelected
        ? (config?.selectedLabelStyle ?? defaultLabelStyle)
        : (config?.unselectedLabelStyle ?? defaultLabelStyle);

    final Widget labelWidget = AnimatedDefaultTextStyle(
      duration: duration,
      curve: curve,
      style: effectiveStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: destination.labelWidget ?? Text(destination.label),
    );

    final Widget itemContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        pill,
        if (showLabel) ...[
          const SizedBox(height: 4.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: labelWidget,
          ),
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
          child: Center(child: itemContent),
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
