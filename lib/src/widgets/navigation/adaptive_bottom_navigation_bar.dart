import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../theme/adaptive_motion.dart';
import '../../theme/adaptive_theme.dart';
import '../../theme/adaptive_theme_data.dart';
import 'adaptive_sidebar_models.dart';

export 'adaptive_sidebar_models.dart'
    show
        AdaptiveBottomNavLabelBehavior,
        AdaptiveBottomNavOverflowPolicy,
        AdaptiveBottomNavigationConfig,
        AdaptiveBottomNavigationStyle;

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

/// A responsive, multi-style bottom navigation bar with 12 distinct design presentations,
/// custom painter acceleration for low-RAM devices, smooth motion indicators,
/// safe area handling, configurable overflow policies (scroll, menu, auto), and
/// constraint-safe layout across 1 to 10+ destinations.
class AdaptiveBottomNavigationBar extends StatefulWidget {
  const AdaptiveBottomNavigationBar({
    super.key,
    this.destinations,
    this.items,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.onItemSelected,
    this.style,
    this.config,
    this.customPainter,
    this.labelBehavior,
    this.height,
    this.elevation,
    this.margin,
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

  /// The visual design style for this bottom navigation bar.
  /// If null, resolves from [config.style] or defaults to [AdaptiveBottomNavigationStyle.materialExpressive].
  final AdaptiveBottomNavigationStyle? style;

  /// Dedicated configuration object for bottom navigation styling and policies.
  final AdaptiveBottomNavigationConfig? config;

  /// Optional custom painter hook for background decoration or custom active indicators.
  final CustomPainter? customPainter;

  /// Label visibility behavior. Overrides [config] if provided.
  final AdaptiveBottomNavLabelBehavior? labelBehavior;

  /// Total height of the navigation bar excluding safe-area bottom insets.
  final double? height;

  /// Surface elevation depth.
  final double? elevation;

  /// Outer margin surrounding the navigation bar.
  final EdgeInsetsGeometry? margin;

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

  @override
  State<AdaptiveBottomNavigationBar> createState() =>
      _AdaptiveBottomNavigationBarState();
}

class _AdaptiveBottomNavigationBarState extends State<AdaptiveBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;
  int _previousIndex = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _previousIndex = widget.selectedIndex;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration ??
          widget.config?.animationDuration ??
          AdaptiveMotion.standard,
    );
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve ??
          widget.config?.animationCurve ??
          AdaptiveMotion.emphasizedCurve,
    );
    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant AdaptiveBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final Duration effectiveDuration = widget.animationDuration ??
        widget.config?.animationDuration ??
        AdaptiveMotion.standard;
    if (_controller.duration != effectiveDuration) {
      _controller.duration = effectiveDuration;
    }

    final Curve effectiveCurve = widget.animationCurve ??
        widget.config?.animationCurve ??
        AdaptiveMotion.emphasizedCurve;
    if (_curvedAnimation.curve != effectiveCurve) {
      _curvedAnimation.curve = effectiveCurve;
    }

    if (widget.selectedIndex != _currentIndex) {
      _previousIndex = _currentIndex;
      _currentIndex = widget.selectedIndex;

      final bool reducedMotion = AdaptiveMotion.isReducedMotion(context);
      if (reducedMotion || effectiveDuration == Duration.zero) {
        _controller.value = 1.0;
      } else {
        _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleSelected(int index) {
    widget.onDestinationSelected?.call(index);
    widget.onItemSelected?.call(index);
  }

  List<AdaptiveBottomNavigationDestination> _resolveDestinations() {
    if (widget.items != null) {
      return widget.items!
          .where((AdaptiveSidebarItem item) => item.visibleOnMobile)
          .map(AdaptiveBottomNavigationDestination.fromSidebarItem)
          .toList();
    }
    return widget.destinations ?? const <AdaptiveBottomNavigationDestination>[];
  }

  static bool _isCustomPainterStyle(AdaptiveBottomNavigationStyle s) {
    return switch (s) {
      AdaptiveBottomNavigationStyle.classicCurve ||
      AdaptiveBottomNavigationStyle.floatingIsland ||
      AdaptiveBottomNavigationStyle.wave ||
      AdaptiveBottomNavigationStyle.pillMotion ||
      AdaptiveBottomNavigationStyle.dock ||
      AdaptiveBottomNavigationStyle.minimalLine => true,
      _ => false,
    };
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
        : (widget.animationDuration ??
            widget.config?.animationDuration ??
            AdaptiveMotion.standard);

    final Curve effectiveCurve = widget.animationCurve ??
        widget.config?.animationCurve ??
        AdaptiveMotion.emphasizedCurve;

    final AdaptiveBottomNavigationStyle effectiveStyle = widget.style ??
        widget.config?.style ??
        AdaptiveBottomNavigationStyle.materialExpressive;

    final bool isCustomPainter = _isCustomPainterStyle(effectiveStyle) ||
        widget.customPainter != null ||
        widget.config?.customPainter != null;

    final double effectiveHeight = widget.height ??
        widget.config?.height ??
        adaptiveTheme.bottomNavTheme.height ??
        switch (effectiveStyle) {
          AdaptiveBottomNavigationStyle.classic => 64.0,
          AdaptiveBottomNavigationStyle.classicCurve => 66.0,
          AdaptiveBottomNavigationStyle.floating => 68.0,
          AdaptiveBottomNavigationStyle.floatingIsland => 68.0,
          AdaptiveBottomNavigationStyle.wave => 64.0,
          AdaptiveBottomNavigationStyle.pill => 64.0,
          AdaptiveBottomNavigationStyle.pillMotion => 66.0,
          AdaptiveBottomNavigationStyle.dock => 68.0,
          AdaptiveBottomNavigationStyle.minimal => 58.0,
          AdaptiveBottomNavigationStyle.minimalLine => 58.0,
          AdaptiveBottomNavigationStyle.glass => 68.0,
          AdaptiveBottomNavigationStyle.materialExpressive => 80.0,
        };

    final double effectiveElevation = widget.elevation ??
        widget.config?.elevation ??
        adaptiveTheme.bottomNavTheme.elevation ??
        switch (effectiveStyle) {
          AdaptiveBottomNavigationStyle.classic => 8.0,
          AdaptiveBottomNavigationStyle.classicCurve => 8.0,
          AdaptiveBottomNavigationStyle.floating => 6.0,
          AdaptiveBottomNavigationStyle.floatingIsland => 6.0,
          AdaptiveBottomNavigationStyle.wave => 6.0,
          AdaptiveBottomNavigationStyle.pill => 4.0,
          AdaptiveBottomNavigationStyle.pillMotion => 4.0,
          AdaptiveBottomNavigationStyle.dock => 6.0,
          AdaptiveBottomNavigationStyle.minimal => 0.0,
          AdaptiveBottomNavigationStyle.minimalLine => 0.0,
          AdaptiveBottomNavigationStyle.glass => 0.0,
          AdaptiveBottomNavigationStyle.materialExpressive => 3.0,
        };

    final BorderRadiusGeometry? effectiveBorderRadius = widget.borderRadius ??
        widget.config?.borderRadius ??
        switch (effectiveStyle) {
          AdaptiveBottomNavigationStyle.classic => null,
          AdaptiveBottomNavigationStyle.classicCurve => null,
          AdaptiveBottomNavigationStyle.floating => BorderRadius.circular(28.0),
          AdaptiveBottomNavigationStyle.floatingIsland =>
            BorderRadius.circular(28.0),
          AdaptiveBottomNavigationStyle.wave => null,
          AdaptiveBottomNavigationStyle.pill => BorderRadius.circular(32.0),
          AdaptiveBottomNavigationStyle.pillMotion =>
            BorderRadius.circular(32.0),
          AdaptiveBottomNavigationStyle.dock => BorderRadius.circular(24.0),
          AdaptiveBottomNavigationStyle.minimal => null,
          AdaptiveBottomNavigationStyle.minimalLine => null,
          AdaptiveBottomNavigationStyle.glass => BorderRadius.circular(24.0),
          AdaptiveBottomNavigationStyle.materialExpressive => null,
        };

    final EdgeInsetsGeometry? effectiveMargin = widget.margin ??
        widget.config?.margin ??
        switch (effectiveStyle) {
          AdaptiveBottomNavigationStyle.classic => null,
          AdaptiveBottomNavigationStyle.classicCurve => null,
          AdaptiveBottomNavigationStyle.floating =>
            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
          AdaptiveBottomNavigationStyle.floatingIsland =>
            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
          AdaptiveBottomNavigationStyle.wave => null,
          AdaptiveBottomNavigationStyle.pill =>
            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
          AdaptiveBottomNavigationStyle.pillMotion =>
            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
          AdaptiveBottomNavigationStyle.dock =>
            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
          AdaptiveBottomNavigationStyle.minimal => null,
          AdaptiveBottomNavigationStyle.minimalLine => null,
          AdaptiveBottomNavigationStyle.glass =>
            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
          AdaptiveBottomNavigationStyle.materialExpressive => null,
        };

    final Border? effectiveBorder = widget.border ??
        widget.config?.border ??
        switch (effectiveStyle) {
          AdaptiveBottomNavigationStyle.classic => Border(
              top: BorderSide(
                color:
                    isDark ? const Color(0xFF2E323D) : const Color(0xFFE5E7EB),
                width: 1.0,
              ),
            ),
          AdaptiveBottomNavigationStyle.classicCurve => Border(
              top: BorderSide(
                color:
                    isDark ? const Color(0xFF2E323D) : const Color(0xFFE5E7EB),
                width: 1.0,
              ),
            ),
          AdaptiveBottomNavigationStyle.floating => Border.all(
              color: isDark ? const Color(0xFF383C4A) : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
          AdaptiveBottomNavigationStyle.floatingIsland => Border.all(
              color: isDark ? const Color(0xFF383C4A) : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
          AdaptiveBottomNavigationStyle.wave => Border(
              top: BorderSide(
                color:
                    isDark ? const Color(0xFF2E323D) : const Color(0xFFE5E7EB),
                width: 1.0,
              ),
            ),
          AdaptiveBottomNavigationStyle.pill => Border.all(
              color: isDark ? const Color(0xFF323644) : const Color(0xFFE5E7EB),
              width: 1.0,
            ),
          AdaptiveBottomNavigationStyle.pillMotion => Border.all(
              color: isDark ? const Color(0xFF323644) : const Color(0xFFE5E7EB),
              width: 1.0,
            ),
          AdaptiveBottomNavigationStyle.dock => Border.all(
              color: isDark ? const Color(0xFF383C4A) : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
          AdaptiveBottomNavigationStyle.minimal => Border(
              top: BorderSide(
                color:
                    isDark ? const Color(0xFF2A2D37) : const Color(0xFFEEEEEE),
                width: 1.0,
              ),
            ),
          AdaptiveBottomNavigationStyle.minimalLine => Border(
              top: BorderSide(
                color:
                    isDark ? const Color(0xFF2A2D37) : const Color(0xFFEEEEEE),
                width: 1.0,
              ),
            ),
          AdaptiveBottomNavigationStyle.glass => Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: 0.08),
              width: 1.0,
            ),
          AdaptiveBottomNavigationStyle.materialExpressive => null,
        };

    final Color effectiveBg = widget.backgroundColor ??
        widget.config?.backgroundColor ??
        adaptiveTheme.bottomNavTheme.backgroundColor ??
        (effectiveStyle == AdaptiveBottomNavigationStyle.glass
            ? (isDark ? const Color(0x99181A20) : const Color(0xB3FFFFFF))
            : adaptiveTheme.colors.surface);

    final AdaptiveBottomNavLabelBehavior effectiveLabelBehavior =
        widget.labelBehavior ??
            widget.config?.labelBehavior ??
            adaptiveTheme.bottomNavTheme.labelBehavior ??
            AdaptiveBottomNavLabelBehavior.alwaysShow;

    final Color effectiveIndicator = widget.indicatorColor ??
        widget.config?.indicatorColor ??
        adaptiveTheme.bottomNavTheme.indicatorColor ??
        (isDark
            ? adaptiveTheme.colors.primary.withValues(alpha: 0.24)
            : adaptiveTheme.colors.primary.withValues(alpha: 0.14));

    final Color effectiveSelected = widget.selectedColor ??
        widget.config?.selectedColor ??
        adaptiveTheme.bottomNavTheme.selectedColor ??
        adaptiveTheme.colors.primary;

    final Color effectiveUnselected = widget.unselectedColor ??
        widget.config?.unselectedColor ??
        adaptiveTheme.bottomNavTheme.unselectedColor ??
        adaptiveTheme.colors.onSurfaceVariant;

    final bool effectiveUseSafeArea =
        widget.useSafeArea ?? widget.config?.useSafeArea ?? true;

    final AdaptiveBottomNavOverflowPolicy effectivePolicy =
        widget.overflowPolicy ??
            widget.config?.overflowPolicy ??
            AdaptiveBottomNavOverflowPolicy.auto;

    final int effectiveMaxVisible =
        widget.maxVisibleItems ?? widget.config?.maxVisibleItems ?? 5;

    final Widget effectiveMoreIcon =
        widget.moreIcon ?? widget.config?.moreIcon ?? const Icon(Icons.more_horiz);

    final String effectiveMoreLabel =
        widget.moreLabel ?? widget.config?.moreLabel ?? 'More';

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
        int visibleCount = count;
        int effectiveIndex = widget.selectedIndex;
        int effectivePrev = _previousIndex;

        if (count == 1) {
          // Exactly one item: render centered with comfortable width
          visibleCount = 1;
          effectiveIndex = 0;
          effectivePrev = 0;
          barItems = Center(
            child: SizedBox(
              width: availableWidth.clamp(72.0, 160.0),
              child: _AdaptiveBottomNavItem(
                destination: resolvedDestinations[0],
                isSelected: widget.selectedIndex == 0,
                labelBehavior: effectiveLabelBehavior,
                style: effectiveStyle,
                onTap: resolvedDestinations[0].enabled
                    ? () => _handleSelected(0)
                    : null,
                duration: duration,
                curve: effectiveCurve,
                indicatorColor: effectiveIndicator,
                selectedColor: effectiveSelected,
                unselectedColor: effectiveUnselected,
                config: widget.config,
                isCustomPainter: isCustomPainter,
              ),
            ),
          );
        } else if (shouldScroll) {
          // Scroll policy: horizontally scrollable row of items
          visibleCount = count;
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
                      isSelected: widget.selectedIndex == i,
                      labelBehavior: effectiveLabelBehavior,
                      style: effectiveStyle,
                      onTap: resolvedDestinations[i].enabled
                          ? () => _handleSelected(i)
                          : null,
                      duration: duration,
                      curve: effectiveCurve,
                      indicatorColor: effectiveIndicator,
                      selectedColor: effectiveSelected,
                      unselectedColor: effectiveUnselected,
                      config: widget.config,
                      isCustomPainter: isCustomPainter,
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

          final bool isMoreSelected = widget.selectedIndex >= primaryCount;
          visibleCount = primaryCount + 1;
          effectiveIndex = isMoreSelected ? primaryCount : widget.selectedIndex;
          effectivePrev = _previousIndex >= primaryCount ? primaryCount : _previousIndex;

          barItems = Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < primaryItems.length; i++)
                Expanded(
                  child: _AdaptiveBottomNavItem(
                    destination: primaryItems[i],
                    isSelected: widget.selectedIndex == i,
                    labelBehavior: effectiveLabelBehavior,
                    style: effectiveStyle,
                    onTap: primaryItems[i].enabled
                        ? () => _handleSelected(i)
                        : null,
                    duration: duration,
                    curve: effectiveCurve,
                    indicatorColor: effectiveIndicator,
                    selectedColor: effectiveSelected,
                    unselectedColor: effectiveUnselected,
                    config: widget.config,
                    isCustomPainter: isCustomPainter,
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
                  style: effectiveStyle,
                  onTap: () {
                    _showMoreMenu(
                      ctx,
                      overflowItems: overflowItems,
                      primaryCount: primaryCount,
                      selectedIndex: widget.selectedIndex,
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
                  config: widget.config,
                  isCustomPainter: isCustomPainter,
                ),
              ),
            ],
          );
        } else {
          // Standard evenly-distributed row
          visibleCount = count;
          effectiveIndex = widget.selectedIndex.clamp(0, count - 1);
          effectivePrev = _previousIndex.clamp(0, count - 1);
          barItems = Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < count; i++)
                Expanded(
                  child: _AdaptiveBottomNavItem(
                    destination: resolvedDestinations[i],
                    isSelected: widget.selectedIndex == i,
                    labelBehavior: effectiveLabelBehavior,
                    style: effectiveStyle,
                    onTap: resolvedDestinations[i].enabled
                        ? () => _handleSelected(i)
                        : null,
                    duration: duration,
                    curve: effectiveCurve,
                    indicatorColor: effectiveIndicator,
                    selectedColor: effectiveSelected,
                    unselectedColor: effectiveUnselected,
                    config: widget.config,
                    isCustomPainter: isCustomPainter,
                  ),
                ),
            ],
          );
        }

        final double textScale = MediaQuery.textScalerOf(ctx).scale(1.0);
        final double scaledHeight = textScale > 1.0
            ? effectiveHeight + (textScale - 1.0) * 24.0
            : effectiveHeight;

        Widget content;
        if (isCustomPainter && !shouldScroll) {
          content = SizedBox(
            height: scaledHeight,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: AdaptiveBottomNavPainter(
                        repaint: _curvedAnimation,
                        style: effectiveStyle,
                        progress: _curvedAnimation.value,
                        previousIndex: effectivePrev,
                        currentIndex: effectiveIndex,
                        itemCount: visibleCount,
                        indicatorColor: effectiveIndicator,
                        selectedColor: effectiveSelected,
                        unselectedColor: effectiveUnselected,
                        backgroundColor: effectiveBg,
                        textDirection: Directionality.of(ctx),
                        customPainter: widget.customPainter ??
                            widget.config?.customPainter,
                      ),
                    ),
                  ),
                ),
                barItems,
              ],
            ),
          );
        } else {
          content = SizedBox(
            height: scaledHeight,
            child: barItems,
          );
        }

        if (effectiveUseSafeArea) {
          content = SafeArea(top: false, child: content);
        }

        Widget barSurface = Container(
          decoration: BoxDecoration(
            color: effectiveStyle == AdaptiveBottomNavigationStyle.glass
                ? effectiveBg
                : null,
            border: effectiveBorder,
            borderRadius: effectiveBorderRadius,
          ),
          child: content,
        );

        if (effectiveStyle == AdaptiveBottomNavigationStyle.glass) {
          barSurface = ClipRRect(
            borderRadius: (effectiveBorderRadius as BorderRadius?) ??
                BorderRadius.circular(24.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.config?.blurSigma ?? 12.0,
                sigmaY: widget.config?.blurSigma ?? 12.0,
              ),
              child: barSurface,
            ),
          );
        }

        Widget result = Material(
          elevation: effectiveElevation,
          color: effectiveStyle == AdaptiveBottomNavigationStyle.glass
              ? Colors.transparent
              : effectiveBg,
          shape: effectiveBorderRadius != null
              ? RoundedRectangleBorder(
                  borderRadius: effectiveBorderRadius,
                  side: effectiveBorder?.top ?? BorderSide.none,
                )
              : null,
          shadowColor: widget.config?.shadowColor,
          child: barSurface,
        );

        if (effectiveMargin != null) {
          result = Padding(
            padding: effectiveMargin,
            child: result,
          );
        }

        return result;
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

/// High-performance [CustomPainter] powering distinctive bottom navigation indicators.
///
/// Designed specifically for lower-end Android devices (500 MB–1 GB RAM):
/// - Reuses static `Paint` and `Path` instances without per-frame heap allocations.
/// - Connects to the repaint listenable directly without rebuilding child widgets.
/// - Avoids `saveLayer`, blur, or shader-heavy operations.
/// - Accurately reports [shouldRepaint] based on visual property equality.
class AdaptiveBottomNavPainter extends CustomPainter {
  AdaptiveBottomNavPainter({
    required Listenable repaint,
    required this.style,
    required this.progress,
    required this.previousIndex,
    required this.currentIndex,
    required this.itemCount,
    required this.indicatorColor,
    required this.selectedColor,
    required this.unselectedColor,
    required this.backgroundColor,
    required this.textDirection,
    this.customPainter,
  }) : super(repaint: repaint);

  final AdaptiveBottomNavigationStyle style;
  final double progress;
  final int previousIndex;
  final int currentIndex;
  final int itemCount;
  final Color indicatorColor;
  final Color selectedColor;
  final Color unselectedColor;
  final Color backgroundColor;
  final TextDirection textDirection;
  final CustomPainter? customPainter;

  // Zero-allocation pre-allocated static Paint and Path instances
  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _strokePaint = Paint()..style = PaintingStyle.stroke;
  static final Path _path = Path();

  double _getCenterX(double width, int index, int count) {
    if (count <= 0) return width / 2.0;
    final double slotWidth = width / count;
    if (textDirection == TextDirection.rtl) {
      return width - (index + 0.5) * slotWidth;
    }
    return (index + 0.5) * slotWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (customPainter != null) {
      customPainter!.paint(canvas, size);
      return;
    }

    if (itemCount <= 0 || size.width <= 0 || size.height <= 0) {
      return;
    }

    final int fromIdx = previousIndex.clamp(0, itemCount - 1);
    final int toIdx = currentIndex.clamp(0, itemCount - 1);
    final double fromX = _getCenterX(size.width, fromIdx, itemCount);
    final double toX = _getCenterX(size.width, toIdx, itemCount);
    final double centerX = lerpDouble(fromX, toX, progress) ?? toX;

    switch (style) {
      case AdaptiveBottomNavigationStyle.classicCurve:
        _paintClassicCurve(canvas, size, centerX);
      case AdaptiveBottomNavigationStyle.floatingIsland:
        _paintFloatingIsland(canvas, size, centerX);
      case AdaptiveBottomNavigationStyle.wave:
        _paintWave(canvas, size, centerX);
      case AdaptiveBottomNavigationStyle.pillMotion:
        _paintPillMotion(canvas, size, centerX);
      case AdaptiveBottomNavigationStyle.dock:
        _paintDock(canvas, size, centerX);
      case AdaptiveBottomNavigationStyle.minimalLine:
        _paintMinimalLine(canvas, size, centerX);
      default:
        break;
    }
  }

  void _paintClassicCurve(Canvas canvas, Size size, double centerX) {
    final double slotWidth = size.width / (itemCount > 0 ? itemCount : 1);
    final double curveWidth = slotWidth.clamp(52.0, 92.0);
    const double dipDepth = 8.0;
    final double halfW = curveWidth / 2.0;
    final double left = (centerX - halfW).clamp(0.0, size.width);
    final double right = (centerX + halfW).clamp(0.0, size.width);

    _path.reset();
    _path.moveTo(left, 0.0);
    _path.cubicTo(
      left + curveWidth * 0.28,
      0.0,
      centerX - curveWidth * 0.22,
      dipDepth,
      centerX,
      dipDepth,
    );
    _path.cubicTo(
      centerX + curveWidth * 0.22,
      dipDepth,
      right - curveWidth * 0.28,
      0.0,
      right,
      0.0,
    );

    _strokePaint
      ..color = selectedColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(_path, _strokePaint);

    _path.lineTo(right, 0.0);
    _path.lineTo(left, 0.0);
    _path.close();
    _fillPaint.color = indicatorColor.withValues(alpha: 0.20);
    canvas.drawPath(_path, _fillPaint);
  }

  void _paintFloatingIsland(Canvas canvas, Size size, double centerX) {
    const double islandW = 64.0;
    const double islandH = 38.0;
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, size.height * 0.44),
        width: islandW,
        height: islandH,
      ),
      const Radius.circular(19.0),
    );

    _fillPaint.color = indicatorColor;
    canvas.drawRRect(rrect, _fillPaint);

    _strokePaint
      ..color = selectedColor.withValues(alpha: 0.28)
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, _strokePaint);
  }

  void _paintWave(Canvas canvas, Size size, double centerX) {
    const double waveW = 56.0;
    final double left = centerX - waveW / 2.0;
    final double right = centerX + waveW / 2.0;

    _path.reset();
    _path.moveTo(left, 0.0);
    _path.cubicTo(
      centerX - 14.0,
      5.0,
      centerX - 8.0,
      6.0,
      centerX,
      6.0,
    );
    _path.cubicTo(
      centerX + 8.0,
      6.0,
      centerX + 14.0,
      5.0,
      right,
      0.0,
    );

    _strokePaint
      ..color = selectedColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(_path, _strokePaint);

    _path.lineTo(right, 0.0);
    _path.lineTo(left, 0.0);
    _path.close();
    _fillPaint.color = indicatorColor.withValues(alpha: 0.22);
    canvas.drawPath(_path, _fillPaint);
  }

  void _paintPillMotion(Canvas canvas, Size size, double centerX) {
    // Dynamic organic breathing during motion using sin(pi * progress)
    final double stretch =
        1.0 + 0.16 * math.sin(math.pi * progress.clamp(0.0, 1.0));
    final double pillW = 60.0 * stretch;
    const double pillH = 34.0;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, size.height * 0.42),
        width: pillW,
        height: pillH,
      ),
      const Radius.circular(17.0),
    );

    _fillPaint.color = indicatorColor;
    canvas.drawRRect(rrect, _fillPaint);
  }

  void _paintDock(Canvas canvas, Size size, double centerX) {
    // Dock reflective shelf line
    _strokePaint
      ..color = unselectedColor.withValues(alpha: 0.20)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(16.0, size.height - 7.0),
      Offset(size.width - 16.0, size.height - 7.0),
      _strokePaint,
    );

    // Active item cushion halo
    final RRect cushion = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, size.height * 0.42),
        width: 52.0,
        height: 34.0,
      ),
      const Radius.circular(12.0),
    );
    _fillPaint.color = indicatorColor.withValues(alpha: 0.24);
    canvas.drawRRect(cushion, _fillPaint);

    // Active dock dot indicator
    _fillPaint.color = selectedColor;
    canvas.drawCircle(Offset(centerX, size.height - 4.5), 2.5, _fillPaint);
  }

  void _paintMinimalLine(Canvas canvas, Size size, double centerX) {
    // Top-edge active indicator line
    _strokePaint
      ..color = selectedColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX - 16.0, 2.0),
      Offset(centerX + 16.0, 2.0),
      _strokePaint,
    );

    // Subtle soft accent glow pill
    final RRect accentPill = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, 3.5),
        width: 36.0,
        height: 6.0,
      ),
      const Radius.circular(3.0),
    );
    _fillPaint.color = indicatorColor.withValues(alpha: 0.16);
    canvas.drawRRect(accentPill, _fillPaint);
  }

  @override
  bool shouldRepaint(covariant AdaptiveBottomNavPainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.progress != progress ||
        oldDelegate.previousIndex != previousIndex ||
        oldDelegate.currentIndex != currentIndex ||
        oldDelegate.itemCount != itemCount ||
        oldDelegate.indicatorColor != indicatorColor ||
        oldDelegate.selectedColor != selectedColor ||
        oldDelegate.unselectedColor != unselectedColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.customPainter != customPainter;
  }
}

class _AdaptiveBottomNavItem extends StatelessWidget {
  const _AdaptiveBottomNavItem({
    required this.destination,
    required this.isSelected,
    required this.labelBehavior,
    required this.style,
    required this.onTap,
    required this.duration,
    required this.curve,
    required this.indicatorColor,
    required this.selectedColor,
    required this.unselectedColor,
    required this.isCustomPainter,
    this.config,
  });

  final AdaptiveBottomNavigationDestination destination;
  final bool isSelected;
  final AdaptiveBottomNavLabelBehavior labelBehavior;
  final AdaptiveBottomNavigationStyle style;
  final VoidCallback? onTap;
  final Duration duration;
  final Curve curve;
  final Color indicatorColor;
  final Color selectedColor;
  final Color unselectedColor;
  final bool isCustomPainter;
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

    final TextStyle effectiveLabelTextStyle = isSelected
        ? (config?.selectedLabelStyle ?? defaultLabelStyle)
        : (config?.unselectedLabelStyle ?? defaultLabelStyle);

    final Widget labelWidget = AnimatedDefaultTextStyle(
      duration: duration,
      curve: curve,
      style: effectiveLabelTextStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: destination.labelWidget ??
          Text(destination.label, style: effectiveLabelTextStyle),
    );

    final Widget badgedIcon = IconTheme(
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
    );

    final Widget itemContent;

    if (isCustomPainter) {
      itemContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          badgedIcon,
          if (showLabel) ...[
            const SizedBox(height: 4.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: labelWidget,
            ),
          ],
        ],
      );
    } else {
      switch (style) {
        case AdaptiveBottomNavigationStyle.pill:
          // Pill style: when selected, displays a horizontal capsule with icon + label.
          itemContent = AnimatedContainer(
            duration: duration,
            curve: curve,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 14.0 : 8.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: isSelected ? indicatorColor : Colors.transparent,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                badgedIcon,
                if (isSelected && showLabel) ...[
                  const SizedBox(width: 8.0),
                  Flexible(
                    child: AnimatedOpacity(
                      duration: duration,
                      opacity: isSelected ? 1.0 : 0.0,
                      child: labelWidget,
                    ),
                  ),
                ],
              ],
            ),
          );

        case AdaptiveBottomNavigationStyle.minimal:
          // Minimal style: flat, clean, understated with a subtle animated underline indicator.
          itemContent = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              badgedIcon,
              if (showLabel) ...[
                const SizedBox(height: 3.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: labelWidget,
                ),
              ],
              const SizedBox(height: 3.0),
              AnimatedContainer(
                duration: duration,
                curve: curve,
                width: isSelected ? 16.0 : 0.0,
                height: 2.5,
                decoration: BoxDecoration(
                  color: isSelected ? selectedColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ],
          );

        case AdaptiveBottomNavigationStyle.classic:
          // Classic style: traditional icon + label without container pill.
          itemContent = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              badgedIcon,
              if (showLabel) ...[
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: labelWidget,
                ),
              ],
            ],
          );

        case AdaptiveBottomNavigationStyle.floating:
          // Floating style: rounded indicator capsule behind icon, label below.
          final Size pillSize =
              config?.indicatorSize ?? Size(isSelected ? 56.0 : 40.0, 32.0);
          itemContent = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: duration,
                curve: curve,
                width: pillSize.width,
                height: pillSize.height,
                decoration: BoxDecoration(
                  color: isSelected ? indicatorColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Center(child: badgedIcon),
              ),
              if (showLabel) ...[
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: labelWidget,
                ),
              ],
            ],
          );

        case AdaptiveBottomNavigationStyle.glass:
          // Glass style: translucent frosted indicator container with soft border.
          final Size pillSize =
              config?.indicatorSize ?? Size(isSelected ? 56.0 : 40.0, 32.0);
          itemContent = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: duration,
                curve: curve,
                width: pillSize.width,
                height: pillSize.height,
                decoration: BoxDecoration(
                  color: isSelected
                      ? indicatorColor.withValues(alpha: 0.35)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.0),
                  border: isSelected
                      ? Border.all(
                          color: indicatorColor.withValues(alpha: 0.45),
                          width: 1.0,
                        )
                      : null,
                ),
                child: Center(child: badgedIcon),
              ),
              if (showLabel) ...[
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: labelWidget,
                ),
              ],
            ],
          );

        case AdaptiveBottomNavigationStyle.materialExpressive:
          // Material Expressive: M3 stadium pill container behind icon, label below.
          final Size pillSize =
              config?.indicatorSize ?? Size(isSelected ? 64.0 : 44.0, 32.0);
          itemContent = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: duration,
                curve: curve,
                width: pillSize.width,
                height: pillSize.height,
                decoration: BoxDecoration(
                  color: isSelected ? indicatorColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(pillSize.height / 2.0),
                ),
                child: Center(child: badgedIcon),
              ),
              if (showLabel) ...[
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: labelWidget,
                ),
              ],
            ],
          );

        case AdaptiveBottomNavigationStyle.classicCurve:
        case AdaptiveBottomNavigationStyle.floatingIsland:
        case AdaptiveBottomNavigationStyle.wave:
        case AdaptiveBottomNavigationStyle.pillMotion:
        case AdaptiveBottomNavigationStyle.dock:
        case AdaptiveBottomNavigationStyle.minimalLine:
          itemContent = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              badgedIcon,
              if (showLabel) ...[
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: labelWidget,
                ),
              ],
            ],
          );
      }
    }

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
