# Adaptive UI — Authoritative Project Context & Architecture Guide

## 1. Executive Summary

`adaptive_ui` is an **automatic-first**, **developer-configurable**, and **performance-conscious** responsive UI framework and widget system for Flutter applications.

It provides an end-to-end multi-platform layout engine paired with native BLoC/Cubit provider scoping (`setProvider()`), granular selective rebuild isolation (`AdaptiveBlocSelector` / `AdaptiveCubitSelector`), responsive side-effects (`AdaptiveBlocListener.adaptive`), and responsive consumers (`AdaptiveBlocConsumer.adaptive`).

---

## 2. Core Architecture & Design Decisions

### A. Constraint-First vs Window-First Layout Engine
- **Primary Driver**: Component-level layout decisions evaluate `LayoutBuilder` parent constraints, captured in immutable [AdaptiveLayoutData](lib/src/core/adaptive_layout_data.dart).
- **Secondary Driver**: `MediaQuery` is reserved exclusively for window-level environmental properties (accessibility `TextScaler`, software keyboard `viewInsets`, system notches/safe-areas `viewPadding`, orientation, and screen pixel density).
- **Benefit**: Guarantees that responsive components adapt accurately when embedded within navigation split views, modal sheets, drawer sidebars, and desktop multi-window splits.

### B. Standard Breakpoints (Material 3 Aligned)
Thresholds defined in [AdaptiveBreakpoints](lib/src/core/adaptive_breakpoints.dart):
- `compact`: `< 600 dp` (phones in portrait, narrow panes)
- `medium`: `600 - 839 dp` (tablets in portrait, foldables, phones in landscape)
- `expanded`: `840 - 1199 dp` (tablets in landscape, small laptops)
- `large`: `1200 - 1599 dp` (desktop monitors, standard laptops)
- `extraLarge`: `≥ 1600 dp` (ultra-wide monitors, 4K workstations)

All thresholds are immutable, equatable, and customizable per application or subtree.

### C. Native BLoC/Cubit Integration & Scoping
- **`setProvider()` Hook**: Overridable method on [AdaptiveStatelessWidget](lib/src/widgets/adaptive_stateless_widget.dart) and [AdaptiveStatefulWidget](lib/src/widgets/adaptive_stateful_widget.dart). Eliminates repetitive `BlocProvider` / `RepositoryProvider` wrapping.
- **Provider Caching in Stateful Widgets**: Evaluated once during `AdaptiveState.initState()` and cached in `_cachedProviders`. Rebuilding via `setState()` reuses cached providers without re-allocating closures or re-instantiating BLoCs.
- **Controlled Reconfiguration**: `updateShouldNotifyProviders(oldWidget)` defaults to `false`, preventing accidental destruction of active streams during parent rebuilds. Developers can override this or call `reconfigureProviders()` manually.
- **Zero-Wrapper Default**: When `setProvider()` returns empty (`const []`), no `MultiBlocProvider` wrapper is inserted.
- **Explicit Lifecycle Cleanup**: `AdaptiveState.dispose()` explicitly sets `_cachedProviders = null;` before calling `super.dispose()`, freeing provider references immediately.

### D. Provider Lifecycle & Resource Ownership
- **`create: (context) => MyCubit()` (Framework-Owned)**: The framework automatically calls `cubit.close()` when the adaptive widget is unmounted from the tree.
- **`value: existingCubit` (Externally-Owned)**: The framework **never** calls `close()`, preserving instance lifecycle across unmounts.
- **Repository Support**: `RepositoryProvider` and `RepositoryProvider.value` are fully supported via `typedef AdaptiveProviderItem = SingleChildWidget`.

### E. Granular Rebuild Isolation & Sibling Immunity
- Dynamic state consumers ([AdaptiveBlocSelector](lib/src/widgets/bloc/adaptive_bloc_selector.dart) and [AdaptiveCubitSelector](lib/src/widgets/bloc/adaptive_bloc_selector.dart)) subscribe to targeted state slices.
- Emitting a state change re-evaluates `selector(state)`.
- Uses Dart's standard `==` equality operator. If equal, the builder is **not** called.
- Sibling widgets and static headers are never re-evaluated on state slice emissions.

### F. Responsive Side-Effects & Consumers
- **`AdaptiveBlocListener` / `AdaptiveCubitListener`**: Supports `.adaptive` constructor supplying ambient `AdaptiveLayoutData` along with emitted state. Enables responsive side-effects such as presenting mobile bottom sheets vs desktop snackbars or dialogs.
- **`AdaptiveBlocConsumer` / `AdaptiveCubitConsumer`**: Combines listener side-effects with adaptive layout rendering in a single widget. Supports `.adaptive` constructor delivering `AdaptiveLayoutData` to both `adaptiveBuilder` and `adaptiveListener`.

### G. Constraint Resilience & ListTile Layout Safety
- `ListTile` requires at least ~128-180dp to layout its `leading`, `title`, and `trailing` children without throwing assertion errors (`Leading widget consumes the entire tile width`).
- **`AdaptiveCard`**: Includes `minContentWidth` (defaults to 180.0dp) and `horizontalScrollableOnConstrained` (defaults to `true`). If incoming constraints are critically squeezed (< 180dp), it safely wraps the child in a horizontal `SingleChildScrollView` with bounded width, preventing zero-width and sub-pixel tile crashes.
- **`AdaptiveScaffold`**: When window or pane width collapses (< 200dp / 360dp), explicitly forced `rail` or `extendedRail` modes safely fall back to bottom navigation to prevent starving the content body.

### H. Policy-Driven Flex Containers & Enhanced Grids
- **`AdaptiveFlex`**: Reusable policy engine for switching arrangements (`row`, `column`, `wrap`, `rowOrColumn`). Safely unwraps `Expanded` children in unconstrained height environments to prevent `RenderFlex children have non-zero flex but incoming height constraints are unbounded` assertions.
- **`AdaptiveGrid`**: Enhanced with `maxItemWidth` (ensures cells don't overstretch on wide displays), `maxContentWidth` (centers content on desktop), and `mainAxisExtent` (fixed vertical cell heights).

---

## 3. Package Structure

```text
adaptive_ui/
├── lib/
│   ├── adaptive_ui.dart                       # Primary public export barrel
│   └── src/
│       ├── core/                              # Resolution engine & breakpoints
│       │   ├── adaptive_breakpoints.dart
│       │   ├── adaptive_config.dart
│       │   ├── adaptive_constraints.dart
│       │   ├── adaptive_context.dart
│       │   ├── adaptive_engine.dart
│       │   ├── adaptive_layout_data.dart
│       │   ├── adaptive_scope.dart
│       │   └── adaptive_value.dart
│       ├── widgets/
│       │   ├── adaptive_app.dart
│       │   ├── adaptive_builder.dart
│       │   ├── adaptive_stateful_widget.dart
│       │   ├── adaptive_stateless_widget.dart
│       │   ├── bloc/                          # BLoC/Cubit reactive selectors & builders
│       │   │   ├── adaptive_bloc_builder.dart
│       │   │   ├── adaptive_bloc_consumer.dart
│       │   │   ├── adaptive_bloc_listener.dart
│       │   │   ├── adaptive_bloc_selector.dart
│       │   │   └── adaptive_bloc_types.dart
│       │   ├── layout/                        # Auto-collapsing & constraint-aware containers
│       │   │   ├── adaptive_center.dart
│       │   │   ├── adaptive_column.dart
│       │   │   ├── adaptive_constrained_box.dart
│       │   │   ├── adaptive_container.dart
│       │   │   ├── adaptive_expanded.dart
│       │   │   ├── adaptive_flex.dart             # Policy-driven flex container (Row/Col/Wrap switching)
│       │   │   ├── adaptive_gap.dart
│       │   │   ├── adaptive_grid.dart             # Dynamic grid with maxItemWidth, maxContentWidth & extent
│       │   │   ├── adaptive_layout_builder.dart   # Slot-based builder (compact, medium, expanded, large, xl)
│       │   │   ├── adaptive_padding.dart
│       │   │   ├── adaptive_row.dart
│       │   │   ├── adaptive_safe_area.dart
│       │   │   ├── adaptive_scaffold.dart         # Responsive navigation chrome (Nav bar vs Rail)
│       │   │   ├── adaptive_scroll_view.dart
│       │   │   ├── adaptive_sized_box.dart
│       │   │   ├── adaptive_visibility.dart
│       │   │   └── adaptive_wrap.dart
│       │   ├── typography/                    # Proportional font scaling & auto-size
│       │   │   ├── adaptive_auto_size_text.dart
│       │   │   ├── adaptive_rich_text.dart
│       │   │   ├── adaptive_text.dart
│       │   │   └── adaptive_text_style.dart
│       │   ├── controls/                      # Accessible touch targets (>= 48dp)
│       │   │   ├── adaptive_button.dart
│       │   │   ├── adaptive_checkbox.dart
│       │   │   ├── adaptive_icon_button.dart
│       │   │   ├── adaptive_slider.dart
│       │   │   ├── adaptive_switch.dart
│       │   │   └── adaptive_text_field.dart
│       │   ├── surfaces/                      # Cards, surfaces, readable text clamps
│       │   │   ├── adaptive_card.dart
│       │   │   ├── adaptive_surface.dart
│       │   │   └── adaptive_text_container.dart
│       │   └── feedback/                      # Empty, loading, skeleton, error views
│       │       ├── adaptive_empty_state.dart
│       │       ├── adaptive_error_view.dart
│       │       ├── adaptive_loading.dart
│       │       └── adaptive_skeleton.dart     # Shimmer pulse placeholder loader
│       ├── theme/                             # Design tokens & theme overrides
│       │   ├── adaptive_colors.dart
│       │   ├── adaptive_radii.dart
│       │   ├── adaptive_sizing.dart
│       │   ├── adaptive_spacing.dart
│       │   ├── adaptive_theme.dart
│       │   ├── adaptive_theme_data.dart
│       │   ├── adaptive_tokens.dart
│       │   └── adaptive_typography.dart
│       ├── utilities/                         # Font calculation & text measurement
│       │   ├── adaptive_math.dart
│       │   ├── adaptive_overflow_policy.dart
│       │   └── adaptive_text_measurement.dart
│       ├── extensions/                        # Context & num syntactic sugar
│       │   ├── adaptive_context_extensions.dart
│       │   └── adaptive_num_extensions.dart
│       └── diagnostics/                       # Live telemetry & debug banner
│           ├── adaptive_debug_overlay.dart
│           └── adaptive_diagnostics.dart
├── test/                                      # Automated test suite (106 tests)
├── example/                                   # Real-world 4-tab studio showcase with tests (8 tests)
├── doc/                                       # Technical architectural specifications
├── pubspec.yaml
└── README.md
```

---

## 4. Phase 3 Test Matrix (11 Required Scenarios Covered)

| Scenario | Test File | Status | Description / Coverage |
| :--- | :--- | :--- | :--- |
| **1. Adaptive stateless widget rendering** | `adaptive_stateless_widget_test.dart` | Pass | Renders layout metrics snapshot to `buildAdaptive`. |
| **2. Adaptive stateful widget init & disposal** | `adaptive_stateful_widget_test.dart` | Pass | Verifies `initState`, `dispose`, and provider caching sequence. |
| **3. Provider creation & lifecycle ownership** | `adaptive_bloc_lifecycle_test.dart` | Pass | Framework-owned `create` instances are closed on unmount; cached on rebuilds. |
| **4. Externally owned provider disposal** | `adaptive_bloc_lifecycle_test.dart` | Pass | Instances provided via `.value` are never closed on unmount. |
| **5. State changes trigger expected rebuild** | `adaptive_selective_rebuild_test.dart` | Pass | Selector rebuilds when target field emits mutated state. |
| **6. Unrelated changes do NOT trigger rebuild** | `adaptive_selective_rebuild_test.dart` | Pass | Siblings and other selectors have 0 rebuilds on unrelated field emissions. |
| **7. Provider replacement & widget updates** | `adaptive_stateful_widget_test.dart` | Pass | `updateShouldNotifyProviders` and `reconfigureProviders()` re-evaluates providers. |
| **8. Breakpoint change while state active** | `adaptive_state_responsive_integration_test.dart` | Pass | Compact to expanded resize retains active Cubit state without reset. |
| **9. Widget removal & listener cleanup** | `adaptive_bloc_listener_consumer_test.dart` | Pass | Cancels stream subscriptions; no callbacks or leaks post unmount. |
| **10. Nested responsive & constrained scenarios** | `adaptive_state_responsive_integration_test.dart` | Pass | State selectors nested inside Row, Column, Expanded, and narrow cards (w=150dp). |
| **11. Regression coverage for bugs** | `adaptive_card_test.dart`, `adaptive_scaffold_test.dart` | Pass | `ListTile` w=0.6dp and extreme window resize regression tests. |

---

## 5. Current Progress & Verification Matrix

- **Static Analysis**: `flutter analyze .` (package) passing with **0 issues**.
- **Example Analysis**: `flutter analyze .` (example) passing with **0 issues**.
- **Code Formatting**: `dart format .` passing 100% cleanly across all 97 Dart files.
- **Automated Tests**: **114 tests passing** across package and example suites:
  - Package Tests: **106 tests passing**.
  - Example App Tests: **8 tests passing**.

---

## 6. Conventions & Rules of Engagement

1. **Keep Public APIs Deliberate**: All exports are declared in `lib/adaptive_ui.dart`. Internal implementation details reside in `lib/src/`.
2. **Never Break Flutter Lifecycle**: Base widgets preserve `initState`, `didUpdateWidget`, `dispose`, and `setState`.
3. **No Unbounded Viewports Without Guard**: In collapsed `AdaptiveRow`, `Expanded` children are automatically unwrapped to prevent vertical flex errors in scrollables.
4. **Adaptive Controls & Surfaces Must Never Overflow**: `AdaptiveButton` wraps content in `FittedBox` + `ClipRect`; `AdaptiveCard` provides horizontal scrolling fallback for constrained widths (< 180dp); `AdaptiveGrid` dynamically adjusts aspect ratio on narrow viewports; `AdaptiveScaffold` guards against starving body width.
5. **No Third-Party Responsive Dependencies**: Rely purely on native Flutter layout primitives (`LayoutBuilder`, `MediaQueryData`, `CustomPaint`, `TextPainter`) and existing `flutter_bloc` / `nested`.
6. **Deterministic Testing**: Rebuild counters, controlled Cubits, and multi-viewport pumps must be verified via `flutter test`.

---

## 7. Known Limitations & Edge Cases

1. **Navigator Push Route Scoping**: Providers injected via `setProvider()` are scoped to that widget's subtree. Modal dialogs or pushed routes via `Navigator.push` require passing the BLoC explicitly via `BlocProvider.value` or registering the BLoC at the root `AdaptiveApp`.
2. **Deep Collection Equalities in Selectors**: `AdaptiveBlocSelector` relies on Dart `==`. For mutable collections (`List`, `Map`), wrap them in an immutable value object or use `package:collection` equality helpers.
