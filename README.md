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
- **`AdaptiveBlocSelector<B, S, T>` / `AdaptiveCubitSelector<C, S, T>`**: Subscribes to a slice of state and rebuilds strictly when that slice changes (verified by `==` equality).
- **`AdaptiveBlocBuilder<B, S>` / `AdaptiveCubitBuilder<C, S>`**: Rebuilds widget on state changes with optional `buildWhen` and access to ambient `AdaptiveLayoutData`.
- **`AdaptiveBlocConsumer<B, S>` / `AdaptiveCubitConsumer<C, S>`**: Combines reactive listener and builder.
- **`AdaptiveBlocListener<B, S>` / `AdaptiveCubitListener<C, S>`**: Executes side effects without triggering UI rebuilds.

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

### 3. Auto-Collapsing Row
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

### 4. Dynamic Grid
Automatically calculates the optimal number of columns based on available parent space and target cell width:

```dart
AdaptiveGrid.builder(
  minItemWidth: 240.0,
  childAspectRatio: 1.4,
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(items[index]),
)
```

### 5. Adaptive Container & Surfaces
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

### 6. Interactive Controls
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

### 7. Diagnostics & Debug Overlay
Inspect parent constraints, active breakpoints, and text scale factors live:

```dart
AdaptiveDebugOverlay(
  enabled: kDebugMode,
  child: const DashboardPage(),
)
```

---

## Breakpoints

| Breakpoint | Range | Representative Devices |
| :--- | :--- | :--- |
| `compact` | `< 600dp` | Phones in portrait, narrow split views |
| `medium` | `600dp – 839dp` | Tablets in portrait, foldables, phones in landscape |
| `expanded`| `840dp – 1199dp` | Tablets in landscape, small laptops |
| `large` | `1200dp – 1599dp`| Typical desktop monitors, large laptops |
| `extraLarge`| $\ge$ 1600dp | Ultra-wide monitors, 4K workstations |

---

## Interactive Studio Example App

The included example application (`example/lib/main.dart`) demonstrates real-world multi-platform usage with a 4-tab interactive studio:

1. **Responsive Dashboard**: Live metric cards, dynamic adaptive grids, auto-collapsing rows, and device orientation handling across phone, tablet, and desktop widths.
2. **Rebuild Lab**: Visual counter widgets demonstrating that `AdaptiveBlocSelector` triggers leaf-level rebuilds only for targeted fields while sibling widgets and parent containers experience zero rebuilds.
3. **UI State Machine**: Handles `Loading`, `Empty`, `Error` (with retry button), and `Populated` list states using responsive feedback widgets.
4. **Constrained Layouts & Theming**: Demonstrates fallback layouts under extreme parent constraints (<260dp width) alongside nested, localized `AdaptiveTheme` token overrides.

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
