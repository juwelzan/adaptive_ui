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
class AdaptiveScaffold extends StatefulWidget {
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

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  final GlobalKey _bodyKey =
      GlobalKey(debugLabel: 'adaptive_scaffold_body_key');

  AdaptiveNavigationType _resolveType(AdaptiveLayoutData layout) {
    if (widget.navigationType != AdaptiveNavigationType.auto) {
      if ((widget.navigationType == AdaptiveNavigationType.extendedRail ||
              widget.navigationType == AdaptiveNavigationType.rail) &&
          layout.availableWidth > 0 &&
          layout.availableWidth <
              (widget.navigationType == AdaptiveNavigationType.extendedRail
                  ? 360.0
                  : 200.0)) {
        return AdaptiveNavigationType.bottom;
      }
      return widget.navigationType;
    }
    if (widget.destinations.isEmpty) {
      return AdaptiveNavigationType.none;
    }
    // Prevent starving body width when window is small or during resize
    if (layout.availableWidth >= 840.0 &&
        layout.containerBreakpoint.index >= widget.extendedBreakpoint.index) {
      return AdaptiveNavigationType.extendedRail;
    }
    if (layout.availableWidth >= 500.0 &&
        layout.containerBreakpoint.index >= widget.railBreakpoint.index) {
      return AdaptiveNavigationType.rail;
    }
    return AdaptiveNavigationType.bottom;
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (BuildContext context, AdaptiveLayoutData layout) {
        final AdaptiveNavigationType resolvedType = _resolveType(layout);
        final Widget bodyWidget =
            KeyedSubtree(key: _bodyKey, child: widget.body);

        switch (resolvedType) {
          case AdaptiveNavigationType.auto:
          case AdaptiveNavigationType.bottom:
            return Scaffold(
              appBar: widget.appBar,
              body: bodyWidget,
              bottomNavigationBar: NavigationBar(
                selectedIndex: widget.selectedIndex,
                onDestinationSelected: widget.onDestinationSelected,
                destinations:
                    widget.destinations.map((AdaptiveNavigationDestination d) {
                  return NavigationDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: d.label,
                    tooltip: d.tooltip,
                  );
                }).toList(),
              ),
              floatingActionButton: widget.floatingActionButton,
              floatingActionButtonLocation: widget.floatingActionButtonLocation,
              drawer: widget.drawer,
              endDrawer: widget.endDrawer,
              bottomSheet: widget.bottomSheet,
              backgroundColor: widget.backgroundColor,
              resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
            );

          case AdaptiveNavigationType.rail:
          case AdaptiveNavigationType.extendedRail:
            final bool isExtended =
                resolvedType == AdaptiveNavigationType.extendedRail;

            return Scaffold(
              appBar: widget.appBar,
              body: Row(
                children: <Widget>[
                  NavigationRail(
                    extended: isExtended,
                    selectedIndex: widget.selectedIndex,
                    onDestinationSelected: widget.onDestinationSelected,
                    leading: widget.railHeader,
                    trailing: widget.railTrailing,
                    destinations: widget.destinations.map(
                      (AdaptiveNavigationDestination d) {
                        return NavigationRailDestination(
                          icon: d.icon,
                          selectedIcon: d.selectedIcon,
                          label: Text(d.label),
                        );
                      },
                    ).toList(),
                  ),
                  if (widget.includeRailDivider)
                    const VerticalDivider(width: 1, thickness: 1),
                  Expanded(
                    child: bodyWidget,
                  ),
                ],
              ),
              floatingActionButton: widget.floatingActionButton,
              floatingActionButtonLocation: widget.floatingActionButtonLocation,
              drawer: widget.drawer,
              endDrawer: widget.endDrawer,
              bottomSheet: widget.bottomSheet,
              backgroundColor: widget.backgroundColor,
              resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
            );

          case AdaptiveNavigationType.drawer:
            return Scaffold(
              appBar: widget.appBar,
              body: bodyWidget,
              drawer: widget.drawer ??
                  Drawer(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        if (widget.railHeader != null) widget.railHeader!,
                        ...widget.destinations.asMap().entries.map(
                          (MapEntry<int, AdaptiveNavigationDestination> entry) {
                            final int index = entry.key;
                            final AdaptiveNavigationDestination d = entry.value;
                            return ListTile(
                              leading: index == widget.selectedIndex
                                  ? (d.selectedIcon ?? d.icon)
                                  : d.icon,
                              title: Text(d.label),
                              selected: index == widget.selectedIndex,
                              onTap: () {
                                Navigator.of(context).maybePop();
                                widget.onDestinationSelected?.call(index);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              endDrawer: widget.endDrawer,
              floatingActionButton: widget.floatingActionButton,
              floatingActionButtonLocation: widget.floatingActionButtonLocation,
              bottomSheet: widget.bottomSheet,
              backgroundColor: widget.backgroundColor,
              resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
            );

          case AdaptiveNavigationType.none:
            return Scaffold(
              appBar: widget.appBar,
              body: bodyWidget,
              drawer: widget.drawer,
              endDrawer: widget.endDrawer,
              floatingActionButton: widget.floatingActionButton,
              floatingActionButtonLocation: widget.floatingActionButtonLocation,
              bottomSheet: widget.bottomSheet,
              backgroundColor: widget.backgroundColor,
              resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
            );
        }
      },
    );
  }
}
