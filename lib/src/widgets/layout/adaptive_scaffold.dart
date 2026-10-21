import 'package:flutter/material.dart';

import '../../core/adaptive_breakpoints.dart';
import '../../core/adaptive_layout_data.dart';
import '../adaptive_builder.dart';

/// Navigation mode for [AdaptiveScaffold].
enum AdaptiveNavigationType {
  /// Automatically selects navigation presentation based on container width breakpoints:
  /// - Compact (<600dp): Bottom [NavigationBar]
  /// - Medium (600–839dp): Collapsed side [NavigationRail]
  /// - Expanded, Large, ExtraLarge (≥840dp): Extended side [NavigationRail]
  auto,

  /// Forces bottom [NavigationBar].
  bottom,

  /// Forces collapsed [NavigationRail].
  rail,

  /// Forces extended [NavigationRail].
  extendedRail,

  /// Forces side [Drawer].
  drawer,

  /// Suppresses all navigation chrome.
  none,
}

/// A destination item for [AdaptiveScaffold].
class AdaptiveNavigationDestination {
  const AdaptiveNavigationDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.tooltip,
  });

  /// The icon representing this destination.
  final Widget icon;

  /// An optional alternate icon displayed when this destination is active.
  final Widget? selectedIcon;

  /// The text label displayed for this destination.
  final String label;

  /// An optional tooltip displayed on hover or long-press.
  final String? tooltip;
}

/// A responsive [Scaffold] that dynamically presents a bottom [NavigationBar]
/// on compact mobile viewports, and switches to a side [NavigationRail] on tablets
/// and desktop screens.
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.destinations = const <AdaptiveNavigationDestination>[],
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.navigationType = AdaptiveNavigationType.auto,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.railHeader,
    this.railTrailing,
    this.includeRailDivider = true,
    this.railBreakpoint = Breakpoint.medium,
    this.extendedBreakpoint = Breakpoint.expanded,
  });

  /// An optional app bar displayed at the top of the scaffold.
  final PreferredSizeWidget? appBar;

  /// The primary content widget displayed in the scaffold.
  final Widget body;

  /// The list of navigation destinations.
  final List<AdaptiveNavigationDestination> destinations;

  /// The index of the currently active destination.
  final int selectedIndex;

  /// Callback invoked when a navigation destination is tapped.
  final ValueChanged<int>? onDestinationSelected;

  /// Explicit navigation presentation mode. Defaults to [AdaptiveNavigationType.auto].
  final AdaptiveNavigationType navigationType;

  /// An optional floating action button.
  final Widget? floatingActionButton;

  /// The location of the [floatingActionButton].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// A drawer widget displayed when swiped from the leading edge or via hamburger icon.
  final Widget? drawer;

  /// A drawer widget displayed when swiped from the trailing edge.
  final Widget? endDrawer;

  /// A persistent bottom sheet widget.
  final Widget? bottomSheet;

  /// Background color of the underlying [Scaffold].
  final Color? backgroundColor;

  /// Whether the body should resize when the keyboard appears.
  final bool? resizeToAvoidBottomInset;

  /// Optional leading widget placed at the top of the [NavigationRail].
  final Widget? railHeader;

  /// Optional trailing widget placed at the bottom of the [NavigationRail].
  final Widget? railTrailing;

  /// Whether to render a 1dp vertical divider between the navigation rail and the body.
  final bool includeRailDivider;

  /// The breakpoint at which navigation switches from bottom bar to side rail.
  /// Defaults to [Breakpoint.medium] (600dp).
  final Breakpoint railBreakpoint;

  /// The breakpoint at which the navigation rail expands to show text labels.
  /// Defaults to [Breakpoint.expanded] (840dp).
  final Breakpoint extendedBreakpoint;

  AdaptiveNavigationType _resolveType(AdaptiveLayoutData layout) {
    if (navigationType != AdaptiveNavigationType.auto) {
      return navigationType;
    }
    if (destinations.isEmpty) {
      return AdaptiveNavigationType.none;
    }
    // Prevent starving body width when window is small or during resize
    if (layout.availableWidth >= 840.0 &&
        layout.containerBreakpoint.index >= extendedBreakpoint.index) {
      return AdaptiveNavigationType.extendedRail;
    }
    if (layout.availableWidth >= 500.0 &&
        layout.containerBreakpoint.index >= railBreakpoint.index) {
      return AdaptiveNavigationType.rail;
    }
    return AdaptiveNavigationType.bottom;
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext context, AdaptiveLayoutData layout) {
        final AdaptiveNavigationType resolvedType = _resolveType(layout);

        switch (resolvedType) {
          case AdaptiveNavigationType.auto:
          case AdaptiveNavigationType.bottom:
            return Scaffold(
              appBar: appBar,
              body: body,
              bottomNavigationBar: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                destinations:
                    destinations.map((AdaptiveNavigationDestination d) {
                  return NavigationDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: d.label,
                    tooltip: d.tooltip,
                  );
                }).toList(),
              ),
              floatingActionButton: floatingActionButton,
              floatingActionButtonLocation: floatingActionButtonLocation,
              drawer: drawer,
              endDrawer: endDrawer,
              bottomSheet: bottomSheet,
              backgroundColor: backgroundColor,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            );

          case AdaptiveNavigationType.rail:
          case AdaptiveNavigationType.extendedRail:
            final bool isExtended =
                resolvedType == AdaptiveNavigationType.extendedRail;

            return Scaffold(
              appBar: appBar,
              body: Row(
                children: <Widget>[
                  NavigationRail(
                    extended: isExtended,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                    leading: railHeader,
                    trailing: railTrailing,
                    destinations: destinations.map(
                      (AdaptiveNavigationDestination d) {
                        return NavigationRailDestination(
                          icon: d.icon,
                          selectedIcon: d.selectedIcon,
                          label: Text(d.label),
                        );
                      },
                    ).toList(),
                  ),
                  if (includeRailDivider)
                    const VerticalDivider(width: 1, thickness: 1),
                  Expanded(
                    child: AdaptiveBuilder(
                      builder:
                          (BuildContext ctx, AdaptiveLayoutData bodyLayout) {
                        return body;
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton: floatingActionButton,
              floatingActionButtonLocation: floatingActionButtonLocation,
              drawer: drawer,
              endDrawer: endDrawer,
              bottomSheet: bottomSheet,
              backgroundColor: backgroundColor,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            );

          case AdaptiveNavigationType.drawer:
            return Scaffold(
              appBar: appBar,
              body: body,
              drawer: drawer ??
                  Drawer(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        if (railHeader != null) railHeader!,
                        ...destinations.asMap().entries.map(
                          (MapEntry<int, AdaptiveNavigationDestination> entry) {
                            final int index = entry.key;
                            final AdaptiveNavigationDestination d = entry.value;
                            return ListTile(
                              leading: index == selectedIndex
                                  ? (d.selectedIcon ?? d.icon)
                                  : d.icon,
                              title: Text(d.label),
                              selected: index == selectedIndex,
                              onTap: () {
                                Navigator.of(context).maybePop();
                                onDestinationSelected?.call(index);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              endDrawer: endDrawer,
              floatingActionButton: floatingActionButton,
              floatingActionButtonLocation: floatingActionButtonLocation,
              bottomSheet: bottomSheet,
              backgroundColor: backgroundColor,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            );

          case AdaptiveNavigationType.none:
            return Scaffold(
              appBar: appBar,
              body: body,
              drawer: drawer,
              endDrawer: endDrawer,
              floatingActionButton: floatingActionButton,
              floatingActionButtonLocation: floatingActionButtonLocation,
              bottomSheet: bottomSheet,
              backgroundColor: backgroundColor,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            );
        }
      },
    );
  }
}
