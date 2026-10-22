# Adaptive UI

[![pub package](https://img.shields.io/badge/pub-v0.2.0-blue.svg)](https://pub.dev/packages/adaptive_ui)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/adaptive_ui/adaptive_ui/actions/workflows/ci.yml/badge.svg)](.github/workflows/ci.yml)

An **automatic-first**, **fully customizable** responsive UI framework and widget system for Flutter applications, featuring **native BLoC/Cubit integration** and **granular rebuild optimization**.

Designed for modern multi-platform Flutter apps running on mobile phones, foldables, tablets, laptops, desktops, and web browsers.

---

## Why Adaptive UI?

Most responsive approaches in Flutter make a critical mistake: **they rely entirely on `MediaQuery.sizeOf(context)`**, assuming the widget has the entire screen's width available.

In modern Flutter applications, components are frequently rendered inside:
- Navigation split-views and sidebars
- Modal dialogs and bottom sheets
- Resizable desktop and web windows
- Foldable multi-window apps

`adaptive_ui` uses **`LayoutBuilder` parent constraints as the primary driver for component layout decisions**, and reserves `MediaQuery` for window-level environmental properties (accessibility text scaling, safe areas, keyboard view insets, and orientation).

---

## Key Features

- **Native BLoC/Cubit Integration**: Declare providers directly at the screen level with `setProvider()`. Eliminate boilerplate nested provider wrappers.
- **Granular Selective Rebuilds**: Isolate state emissions using `AdaptiveBlocSelector`. Prevent full-screen redraws and layout recalculations on state changes.
- **Predictable Lifecycle & Ownership**: Framework-owned providers instantiated via `create` are automatically closed on unmount; externally owned instances passed via `.value` remain preserved.
- **Automatic-First Layouts**: Widgets intelligently adapt by default—calculating responsive padding, typography scales, grid columns, and row wrapping.
- **Full Developer Control**: Every automatic behavior can be overridden locally with `AdaptiveValue` or globally via `AdaptiveConfig` and `AdaptiveTheme`.
- **Accessibility Compliant**: Fully honors system `TextScaler` without silently shrinking text below legible thresholds. Guarantees WCAG touch targets ($\ge 48 \times 48\text{dp}$) on touch devices.

---

## Getting Started

Add `adaptive_ui` to your `pubspec.yaml`:

```yaml
dependencies:
  adaptive_ui: ^0.2.0
```

Import the package:

```dart
import 'package:adaptive_ui/adaptive_ui.dart';
```

---

## BLoC & Cubit Integration with `setProvider()`

Declare your state providers directly in your screen class:

### Stateful Screen
```dart
class StudentDashboard extends AdaptiveStatefulWidget {
  const StudentDashboard({super.key});

  @override
  List<AdaptiveProviderItem> setProvider() => [
    BlocProvider<StudentCubit>(
      create: (context) => StudentCubit(),
    ),
  ];

  @override
  State<StudentDashboard> createAdaptiveState() => _StudentDashboardState();
}

class _StudentDashboardState extends AdaptiveState<StudentDashboard> {
  @override
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout) {
    return AdaptiveColumn(
      children: [
        // Static header: Never rebuilds when Cubit updates!
        const DashboardHeader(),

        // Granular selective rebuild: Rebuilds ONLY when name changes
        AdaptiveBlocSelector<StudentCubit, StudentState, String>(
          selector: (state) => state.studentName,
          builder: (context, name) => AdaptiveText('Student: $name'),
        ),

        // Granular selective rebuild: Rebuilds ONLY when totalStudents changes
        AdaptiveBlocSelector<StudentCubit, StudentState, int>(
          selector: (state) => state.totalStudents,
          builder: (context, total) => StudentCountCard(total: total),
        ),
      ],
    );
  }
}
```

### Stateless Screen
```dart
class StudentSummary extends AdaptiveStatelessWidget {
  const StudentSummary({super.key});

  @override
  List<AdaptiveProviderItem> setProvider() => [
    BlocProvider<SummaryCubit>(
      create: (context) => SummaryCubit(),
    ),
  ];

  @override
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout) {
    return const SummaryContent();
  }
}
```

---

## Core Components

### 1. Granular Reactive Widgets
- **`AdaptiveBlocSelector<B, S, T>` / `AdaptiveCubitSelector<C, S, T>`**: Subscribes to a slice of state and rebuilds strictly when that slice changes (verified by `==` equality). Supports `.adaptive` constructor delivering ambient `AdaptiveLayoutData`.
- **`AdaptiveBlocBuilder<B, S>` / `AdaptiveCubitBuilder<C, S>`**: Rebuilds widget on state changes with optional `buildWhen` and access to ambient `AdaptiveLayoutData` via `.adaptive`.
- **`AdaptiveBlocConsumer<B, S>` / `AdaptiveCubitConsumer<C, S>`**: Combines reactive listener and builder. Supports `.adaptive` delivering `AdaptiveLayoutData` to both `adaptiveBuilder` and `adaptiveListener`.
- **`AdaptiveBlocListener<B, S>` / `AdaptiveCubitListener<C, S>`**: Executes side effects without triggering UI rebuilds. Supports `.adaptive` delivering `AdaptiveLayoutData` for responsive side-effects (e.g. mobile bottom sheet vs desktop dialog).

```dart
// Responsive side-effects with AdaptiveBlocListener.adaptive
AdaptiveBlocListener<OrderCubit, OrderState>.adaptive(
  adaptiveListener: (context, state, layout) {
    if (layout.isCompact) {
      showModalBottomSheet(context: context, builder: (_) => OrderSheet(state));
    } else {
      showDialog(context: context, builder: (_) => OrderDialog(state));
    }
  },
  child: const OrderView(),
)
```

### 2. Adaptive Typography
Responsive font scaling that strictly respects system accessibility settings:

```dart
AdaptiveText(
  'Student Dashboard',
  size: AdaptiveValue.auto(),
  minFontSize: 16.0,
  maxFontSize: 28.0,
  maxLines: 2,
  overflowPolicy: AdaptiveOverflowPolicy.ellipsis,
)
```

For tight constraint boxes (e.g. badges or metric cards):

```dart
AdaptiveAutoSizeText(
  '\$182,400.00',
  minFontSize: 14.0,
  maxFontSize: 32.0,
  maxLines: 1,
)
```

### 3. Declarative Slot-Based Layouts with `AdaptiveLayoutBuilder`
Select layouts explicitly per breakpoint tier with automatic graceful downward fallback and static child subtree reuse:

```dart
AdaptiveLayoutBuilder(
  compact: (context, layout) => const MobileLayout(),
  medium: (context, layout) => const TabletLayout(),
  large: (context, layout) => const DesktopLayout(),
  // Optional static child passed to builder avoiding expensive rebuilds
  child: const ExpensiveChartSubtree(),
  builder: (context, layout, child) => CustomSlot(child: child),
)
```

### 4. Policy-Driven Flex Containers with `AdaptiveFlex`
Switch arrangements seamlessly between `Row`, `Column`, and `Wrap`. Enforce maximum content widths and prevent RenderFlex assertion errors by safely unwrapping flex children when vertical height is unbounded:

```dart
AdaptiveFlex(
  arrangement: AdaptiveFlexArrangement.rowOrColumn,
  minRowWidth: 500.0, // switches from Row to Column below 500dp
  maxContentWidth: 1200.0, // clamps and centers on ultra-wide screens
  scrollableFallback: true, // wraps in SingleChildScrollView on tight viewports
  spacing: 16.0,
  children: [
    Expanded(child: MainContentCard()),
    Expanded(child: SideDetailsCard()),
  ],
)
```

### 5. Auto-Collapsing Row
Renders side-by-side on wide screens, and automatically collapses to a vertical column on compact viewports:

```dart
AdaptiveRow(
  autoCollapse: true,
  collapseBelowBreakpoint: Breakpoint.medium,
  spacing: const AdaptiveValue.fixed(12.0),
  children: [
    AdaptiveButton(onPressed: () {}, child: const Text('Confirm')),
    OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
  ],
)
```

### 6. Dynamic Responsive Grid
Automatically calculates the optimal number of columns based on available parent space, cell constraints, and maximum bounds:

```dart
AdaptiveGrid.builder(
  minItemWidth: 240.0,
  maxItemWidth: 360.0,      // increases column count so cells don't overstretch
  maxContentWidth: 1200.0,  // centers and limits content width on desktop
  mainAxisExtent: 180.0,    // fixed item height in logical pixels
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(items[index]),
)
```

### 7. Adaptive Container & Surfaces
Responsive padding, rounded corners, and elevation:

```dart
AdaptiveContainer(
  padding: const AdaptiveInsets.auto(), // 16dp compact, 24dp medium, 32dp expanded, 40dp large
  maxWidth: 1200.0,
  child: const MyContent(),
)

AdaptiveCard(
  elevation: 2.0,
  child: const Text('Card with responsive padding and elevation'),
)
```

### 8. Interactive Controls
Guarantees minimum 48x48dp accessible touch targets on mobile touchscreens while providing compact ergonomics on desktop mouse environments:

```dart
AdaptiveButton(
  onPressed: () {},
  child: const Text('Accessible Button'),
)

AdaptiveTextField(
  decoration: const InputDecoration(labelText: 'Email Address'),
)

AdaptiveSwitch(
  value: isEnabled,
  onChanged: (val) => setState(() => isEnabled = val),
)
```

### 9. Diagnostics & Debug Overlay
Inspect parent constraints, active breakpoints, and text scale factors live:

```dart
AdaptiveDebugOverlay(
  enabled: kDebugMode,
  child: const DashboardPage(),
)
```

---

## Centralized Breakpoint System

`adaptive_ui` uses mathematically defined half-open intervals `[min, max)` where lower bounds are inclusive and upper bounds are exclusive:

| Breakpoint | Interval | Representative Viewports |
| :--- | :--- | :--- |
| `compact` | `[0.0, 600.0)` | Handheld phones in portrait, narrow split views |
| `medium` | `[600.0, 840.0)` | Tablets in portrait, foldables, phones in landscape |
| `expanded`| `[840.0, 1200.0)` | Tablets in landscape, small laptop windows |
| `large` | `[1200.0, 1600.0)`| Standard desktop monitors, large laptops |
| `extraLarge`| `[1600.0, ∞)` | Ultra-wide displays, 4K multi-window monitors |

### Pattern-Matching & Operators
Breakpoints support type-safe pattern matching with downward cascading fallbacks:

```dart
final String label = layout.containerBreakpoint.when(
  compact: () => 'Phone View',
  medium: () => 'Tablet View',
  large: () => 'Desktop View',
);

// Or direct operator comparisons:
if (layout.containerBreakpoint >= Breakpoint.medium) {
  // Show side rail
}
```

---

## Motion, Navigation & Skeleton System (Phase 4)

`adaptive_ui` includes a production-grade motion and loading system engineered with accessibility, restrained animations, and responsive navigation at its core.

### 1. AdaptiveText with Restrained Motion & Auto-Scroll
`AdaptiveText` automatically measures parent constraints using `TextPainter`. If long text overflows available width, horizontal marquee scrolling activates smoothly. Short text remains static.

```dart
// Auto-scrolling marquee when text overflows available width
AdaptiveText(
  'Department of Advanced Artificial Intelligence & Robotics Laboratory',
  animation: AdaptiveTextAnimation.marquee,
  scrollSpeed: 40.0,
  pauseDuration: const Duration(milliseconds: 1200),
  marqueeSpacing: 32.0,
)

// Restrained typewriter or entrance effect
AdaptiveText(
  'Building responsive Flutter user interfaces automatically.',
  animation: AdaptiveTextAnimation.typewriter,
)
```

Supported animations:
- `AdaptiveTextAnimation.none` (default, zero ticker overhead)
- `AdaptiveTextAnimation.marquee` (or `autoScroll: true`)
- `AdaptiveTextAnimation.fadeIn`
- `AdaptiveTextAnimation.slideIn`
- `AdaptiveTextAnimation.typewriter`

*All animations automatically collapse to static text when `MediaQuery.disableAnimations` or reduced-motion accessibility preference is active.*

### 2. AdaptiveSidebar Unified Responsive Navigation System
A unified, responsive navigation architecture that **automatically switches between a mobile bottom navigation bar on compact screens and a desktop/tablet sidebar on wider layouts** from a single navigation definition.

#### Core Architectural Philosophy: One Navigation Definition
Define destinations once using `AdaptiveSidebarItem`. The same destination list, selection state, and callbacks drive both:
- **Compact Viewports (`< mobileBreakpoint`, default 600dp)**: Rendered as a constraint-resilient `AdaptiveBottomNavigationBar`.
- **Wider Viewports (`>= mobileBreakpoint`)**: Rendered as a full-featured `AdaptiveSidebar` (Classic or Floating) with child content alongside it.

```dart
AdaptiveSidebar(
  items: navigationItems,
  selectedIndex: _selectedIndex,
  onItemSelected: (index) => setState(() => _selectedIndex = index),
  model: AdaptiveSidebarModel.floating,
  floatingMode: AdaptiveFloatingSidebarMode.elevated,
  mobileBreakpoint: 600.0,
  bottomNavigation: const AdaptiveBottomNavigationConfig(
    overflowPolicy: AdaptiveBottomNavOverflowPolicy.auto,
    labelBehavior: AdaptiveBottomNavLabelBehavior.alwaysShow,
    height: 70.0,
  ),
  child: PageView(
    controller: _pageController,
    children: _pages,
  ),
)
```

#### Primary Architecture Models (`AdaptiveSidebarModel`)
- **`classic`**: Conventional, full-height navigation surface within its parent layout. Squared corners, zero outer margins, crisp right vertical boundary divider, and subtle active-item indicators. Ideal for Scaffolds, split views, and standard enterprise applications.
- **`floating`**: Modern floating sidebar island with configurable outer spacing, surface shape, elevation shadow, and interaction styling.

#### Floating Presentation Modes (`AdaptiveFloatingSidebarMode`)
When using `AdaptiveSidebarModel.floating`:
- **`elevated`** *(Default)*: Rounded outer container (16dp radius), soft elevation shadow (3dp), comfortable internal padding, and smooth active indicator pill.
- **`inset`**: Soft rounded corners (12dp radius), restrained hairline border, zero elevation shadow, and inset surface tint for seamless surrounding layout framing.
- **`minimal`**: Lightweight presentation with very subtle surface separation, minimal/zero shadow, compact padding, and crisp typography.

#### Variable Destination Density & Overflow Policies
Resilient layout across 1, 2, 5, 10, or more destinations with **zero `RenderFlex` overflow** under any screen constraint:
- **`auto`**: Dynamically chooses fixed-width items when available space permits, or converts to a horizontally scrollable strip on narrow screens.
- **`menu`**: Shows primary visible destinations within available space and places remaining destinations into an accessible "More" bottom sheet.
- **`scroll`**: Horizontally scrollable destination bar preserving minimum touch targets ($\ge 48 \times 48\text{dp}$).

#### PageView & State Preservation
- **State Preservation**: Page bodies preserve internal scroll positions, text inputs, and component state when crossing breakpoints between `Column` (bottom bar) and `Row` (sidebar) via keyed subtrees.
- **PageView Synchronization**: Direct integration with `PageController`, `pages`, or `pageBuilder` with bidirectional synchronization and recursion guards.

#### Developer Customization (`AdaptiveSidebarStyleData`)
Centralized, immutable style configuration supporting complete developer customization without parameter clutter:

```dart
AdaptiveSidebar(
  model: AdaptiveSidebarModel.floating,
  floatingMode: AdaptiveFloatingSidebarMode.inset,
  items: navigationItems,
  selectedIndex: selectedIndex,
  onItemSelected: (index) => setState(() => selectedIndex = index),
  style: const AdaptiveSidebarStyleData(
    width: 264.0,
    collapsedWidth: 76.0,
    borderRadius: BorderRadius.all(Radius.circular(20.0)),
    elevation: 2.0,
    itemSpacing: 8.0,
  ),
  child: MainContentView(selectedIndex: selectedIndex),
)
```

#### 4-Tier Style Precedence
Visual and dimension properties resolve predictably according to:
1. **Widget-level override**: (e.g. `AdaptiveSidebar.backgroundColor`)
2. **Style configuration**: (`AdaptiveSidebar.style` via `AdaptiveSidebarStyleData`)
3. **Theme default**: (`AdaptiveSidebarThemeData` in `AdaptiveThemeData`)
4. **Built-in mode default**: Sensible defaults tailored for Classic and Floating modes.

```dart
AdaptiveSidebar(
  model: AdaptiveSidebarModel.floating,
  floatingMode: AdaptiveFloatingSidebarMode.elevated,
  submenuAnimation: AdaptiveSubmenuAnimation.fadeSlide,
  expansionMode: AdaptiveSubmenuExpansionMode.accordion,
  selectedIndex: _currentIndex,
  isExpanded: _isExpanded,
  enableRailToggle: true,
  onItemSelected: (index) => setState(() => _currentIndex = index),
  header: const SidebarBrandHeader(),
  footer: const UserProfileFooter(),
  items: [
    const AdaptiveSidebarItem(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text('Dashboard'),
    ),
    // Nested Animated Submenu
    const AdaptiveSidebarItem(
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school),
      label: Text('Academics'),
      children: [
        AdaptiveSidebarItem(
          icon: Icon(Icons.class_outlined),
          label: Text('Courses'),
        ),
        AdaptiveSidebarItem(
          icon: Icon(Icons.menu_book_outlined),
          label: Text('Syllabus'),
        ),
      ],
    ),
    // Contextual Dropdown Navigation
    AdaptiveSidebarItem(
      icon: const Icon(Icons.auto_fix_high_rounded),
      label: const Text('Actions'),
      dropdownItems: [
        AdaptiveDropdownItem(
          value: 'create_doc',
          icon: const Icon(Icons.add),
          label: const Text('New Document'),
          onTap: () => handleCreate(),
        ),
        const AdaptiveDropdownItem.divider(),
        AdaptiveDropdownItem(
          value: 'export',
          icon: const Icon(Icons.download),
          label: const Text('Export Data'),
          onTap: () => handleExport(),
        ),
      ],
      onDropdownSelected: (val) => print('Selected: $val'),
    ),
    const AdaptiveSidebarItem(
      icon: Icon(Icons.settings_outlined),
      label: Text('Settings'),
    ),
  ],
  child: pageContent,
)
```

### 3. AdaptiveBottomNavigationBar
Compact bottom navigation system supporting **6 distinct design styles**, animated indicator pills, label visibility policies, safe area padding, overflow management (`auto`, `menu`, `scroll`), and accessible touch targets ($\ge 48\text{dp}$). Accepts either legacy `destinations` or unified `items: List<AdaptiveSidebarItem>`.

**Available Styles (`AdaptiveBottomNavigationStyle`)**:
- `classic`: Traditional bottom navigation with standard icon and label presentation (64dp height, 8dp elevation, crisp boundary border).
- `floating`: Elevated floating surface with rounded corners and outer margins (68dp height, 6dp elevation, 28dp radius).
- `pill`: Animated horizontal capsule (`[icon, label]`) for the selected destination with smooth expansion transitions and icon-only unselected destinations.
- `materialExpressive`: Expressive Material 3 stadium container behind the active icon with label underneath (80dp height, 3dp elevation).
- `minimal`: Restrained, flat visual treatment with no background pill, flat surface, and an animated underline indicator (58dp height, 0 elevation).
- `glass`: Translucent frosted glass aesthetic utilizing GPU-accelerated `BackdropFilter` with configurable `blurSigma` and frosted active highlights.

```dart
AdaptiveBottomNavigationBar(
  selectedIndex: _currentIndex,
  onDestinationSelected: (index) => setState(() => _currentIndex = index),
  style: AdaptiveBottomNavigationStyle.pill, // or classic, floating, materialExpressive, minimal, glass
  labelBehavior: AdaptiveBottomNavLabelBehavior.onlyShowSelected,
  overflowPolicy: AdaptiveBottomNavOverflowPolicy.auto,
  items: sharedNavigationItems,
)
```

### 4. AdaptiveContainer with Implicit Motion
An animated container that smoothly transitions decoration, border radii, padding, margin, constraints, and opacity when properties change without requiring custom animation controllers.

```dart
AdaptiveContainer(
  animateChanges: true,
  animationDuration: const Duration(milliseconds: 350),
  animationCurve: Curves.easeOutCubic,
  width: AdaptiveValue.fixed(_expanded ? 340.0 : 220.0),
  height: AdaptiveValue.fixed(_expanded ? 130.0 : 90.0),
  padding: AdaptiveInsets.all(_expanded ? 20.0 : 12.0),
  decoration: BoxDecoration(
    color: _expanded ? Colors.deepPurple : Colors.indigo,
    borderRadius: BorderRadius.circular(_expanded ? 24.0 : 8.0),
  ),
  hoverDecoration: BoxDecoration(
    color: Colors.teal,
    borderRadius: BorderRadius.circular(16.0),
  ),
  child: const YourContent(),
)
```

### 5. AdaptiveShimmer & Skeleton Loading System
GPU-accelerated linear gradient shimmer mask with cross-fade content switching and composable skeleton primitives.

```dart
// Conditional switcher between placeholder and content
AdaptiveSkeleton(
  loading: _isLoading,
  placeholder: const ProfileCardSkeleton(),
  child: ProfileCard(data: _profileData),
)

// Composable skeleton primitives
AdaptiveSkeleton.circle(size: 48)
AdaptiveSkeleton.box(width: double.infinity, height: 120, borderRadius: BorderRadius.circular(8))
AdaptiveSkeletonText(lines: 3, lineHeight: 14, spacing: 8)
AdaptiveSkeletonList(itemCount: 4, spacing: 12)
```

---

## Centralized Design System & Theme Engine (Phase 5)

`adaptive_ui` provides a unified, production-grade design system and theme engine that integrates natively with Flutter's `ThemeData` and `ColorScheme` while offering granular component-level customization, semantic color roles, density presets, and smooth animated transitions.

### 1. Theme Configuration & Setup

You can define your design system globally via `AdaptiveApp`, at a subtree with `AdaptiveTheme`, or with animated interpolation using `AnimatedAdaptiveTheme`:

```dart
// Automatic Theme Setup
AdaptiveApp(
  theme: AdaptiveThemeData.fromColorScheme(
    ColorScheme.fromSeed(seedColor: const Color(0xFF1E5BB0)),
  ).copyWith(
    density: AdaptiveDensity.comfortable,
    componentThemes: const AdaptiveComponentThemes(
      card: AdaptiveCardThemeData(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        elevation: 2.0,
      ),
      button: AdaptiveButtonThemeData(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
    ),
  ),
  child: MaterialApp(
    home: const HomeScreen(),
  ),
);
```

### 2. Precedence Hierarchy

Component styling strictly follows a 4-tier precedence model:
1. **Explicit widget parameter** (e.g. `AdaptiveCard(color: Colors.red)`) — highest priority.
2. **Component theme in `AdaptiveThemeData`** (e.g. `theme.cardTheme.color`).
3. **Global token in `AdaptiveThemeData`** (e.g. `theme.colors.surface`).
4. **Ambient Flutter `ThemeData`** / `ColorScheme` — fallback.

### 3. Semantic Color System

`AdaptiveColors` eliminates scattered arbitrary hex codes with complete semantic roles:

| Role | Property | Semantic Purpose |
| :--- | :--- | :--- |
| **Primary** | `colors.primary`, `onPrimary` | Key interactive highlights and brand identity. |
| **Secondary** | `colors.secondary`, `onSecondary` | Supporting controls and secondary actions. |
| **Surfaces** | `colors.surface`, `surfaceElevated` | Flat surfaces and elevated cards/sheets. |
| **Typography** | `colors.textPrimary`, `textSecondary` | Main readable text and muted captions. |
| **Status** | `colors.success`, `warning`, `error`, `info` | Feedback, alerts, badges, and validation. |
| **Structure** | `colors.border`, `divider`, `outline` | Card outlines and section dividers. |
| **Interactive** | `colors.disabled`, `hover`, `focus`, `highlight` | Accessible interaction states. |

Construct directly from Flutter: `AdaptiveColors.fromColorScheme(Theme.of(context).colorScheme)`.

### 4. Adaptive Typography & `AdaptiveTextVariant`

Standardized type scale with built-in accessibility text scaling:

```dart
AdaptiveText('Dashboard Overview', variant: AdaptiveTextVariant.titleLarge)
AdaptiveText('Student profile updated.', variant: AdaptiveTextVariant.bodyMedium)
AdaptiveText('Last synchronized 2m ago', variant: AdaptiveTextVariant.caption)
```

Supported variants: `displayLarge`, `displayMedium`, `headlineLarge`, `headlineMedium`, `titleLarge`, `titleMedium`, `bodyLarge`, `bodyMedium`, `bodySmall`, `labelLarge`, `labelMedium`, and `caption`.

### 5. Spacing, Radii, Elevation & Density Tokens

- **Spacing**: `xs` (4dp), `sm` (8dp), `md` (16dp), `lg` (24dp), `xl` (32dp), `xxl` (48dp).
- **Radii**: `none` (0), `xs` (4), `sm` (8), `md` (12), `lg` (16), `xl` (24), `full` (9999).
- **Elevations & Shadows**: `none` (0dp), `low` (1dp), `medium` (3dp), `high` (6dp), `extraHigh` (12dp), and `elevations.shadowOf(elevation)`.
- **Density Presets**: `AdaptiveDensity.compact`, `AdaptiveDensity.comfortable`, and `AdaptiveDensity.spacious`.

### 6. Animated Theme Transitions

Smoothly interpolate tokens between light and dark modes or dynamic seed palettes:

```dart
AnimatedAdaptiveTheme(
  data: isDark ? AdaptiveThemeData.dark() : AdaptiveThemeData.light(),
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOutCubic,
  child: const YourAppContent(),
)
```

Automatically respects accessibility settings (`MediaQuery.disableAnimationsOf(context)`): when reduced motion is preferred, transitions snap instantly without delay.

---

## Interactive Studio Example App

The included example application (`example/lib/main.dart`) demonstrates real-world multi-platform usage with a 7-tab interactive studio:

1. **Responsive Dashboard**: Live metric cards, dynamic adaptive grids, auto-collapsing rows, and device orientation handling across phone, tablet, and desktop widths.
2. **Rebuild Lab**: Visual counter widgets demonstrating that `AdaptiveBlocSelector` triggers leaf-level rebuilds only for targeted fields while sibling widgets and parent containers experience zero rebuilds.
3. **UI State Machine**: Handles `Loading`, `Empty`, `Error` (with retry button), and `Populated` list states using responsive feedback widgets.
4. **Constrained Layouts & Tokens**: Demonstrates fallback layouts under extreme parent constraints (<260dp width) alongside nested `AdaptiveTheme` token overrides.
5. **Theme Studio (Phase 5)**: Live interactive design system inspector with light/dark toggle, seed palette picker (Royal Blue, Emerald, Crimson, Purple, Amber, Deep Teal), density preset selector, component override switcher, elevation previews, and animated transition slider.
6. **Motion & Skeletons**: Interactive showcase demonstrating `AdaptiveText` marquees and typewriters, `AdaptiveContainer` animated property transitions, `AdaptiveBottomNavigationBar`, and `AdaptiveSkeleton` cross-fade switching.
7. **AdaptiveSidebar Studio**: Exploration of Classic and Floating models (Elevated, Inset, Minimal modes), developer style customization sliders, accordion vs independent submenus, action tools, and rail navigation.

Run the example:

```bash
cd example
flutter run
```

---

## Documentation

Detailed architectural notes and best practices are available in `doc/`:

- [Architecture Overview](doc/architecture.md)
- [Responsive Rules & Guidelines](doc/responsive_rules.md)
- [Customization API](doc/customization.md)
- [Typography & Accessibility](doc/typography.md)
- [Testing Multi-Viewport Layouts](doc/testing.md)
- [Performance & Best Practices](doc/performance.md)
- [Implementation Roadmap](doc/roadmap.md)

---

## Contributing

Contributions, issues, and feature requests are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Distributed under the [MIT License](LICENSE).
