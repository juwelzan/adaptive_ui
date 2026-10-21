# Adaptive UI — Authoritative Project Context & Architecture Guide

## 1. Executive Summary

`adaptive_ui` is an **automatic-first**, **developer-configurable**, and **performance-conscious** responsive UI framework and widget system for Flutter applications.

It provides an end-to-end multi-platform layout engine paired with native BLoC/Cubit provider scoping (`setProvider()`) and granular rebuild isolation (`AdaptiveBlocSelector` / `AdaptiveCubitSelector`).

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

### D. Provider Lifecycle & Resource Ownership
- **`create: (context) => MyCubit()` (Framework-Owned)**: The framework automatically calls `cubit.close()` when the adaptive widget is unmounted from the tree.
- **`value: existingCubit` (Externally-Owned)**: The framework **never** calls `close()`, preserving instance lifecycle across unmounts.
- **Repository Support**: `RepositoryProvider` and `RepositoryProvider.value` are fully supported via `typedef AdaptiveProviderItem = SingleChildWidget`.

### E. Granular Rebuild Isolation & Sibling Immunity
- Dynamic state consumers ([AdaptiveBlocSelector](lib/src/widgets/bloc/adaptive_bloc_selector.dart) and [AdaptiveCubitSelector](lib/src/widgets/bloc/adaptive_bloc_selector.dart)) subscribe to targeted state slices.
- Emitting a state change re-evaluates `selector(state)`.
- Uses Dart's standard `==` equality operator. If equal, the builder is **not** called.
- Sibling widgets and static headers are never re-evaluated on state slice emissions.

### F. Flex ParentData Contract Safety
- [AdaptiveExpanded](lib/src/widgets/layout/adaptive_expanded.dart) inspects ambient constraints via [AdaptiveContext.maybeOf(context)](lib/src/core/adaptive_context.dart) instead of inserting an intermediate `LayoutBuilder`.
- Preserves Flutter's strict `ParentDataWidget<FlexParentData>` contract, preventing framework assertion errors inside `Row` and `Column`.

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
│       │   │   ├── adaptive_gap.dart
│       │   │   ├── adaptive_grid.dart
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
├── test/                                      # Automated test suite (66 tests)
├── example/                                   # Real-world 4-tab studio showcase with tests (5 tests)
├── doc/                                       # Technical architectural specifications
├── pubspec.yaml
└── README.md
```

---

## 4. Feature-Gap Audit (12 Areas)

| Area | Status | Evidence / Implementation Notes |
| :--- | :--- | :--- |
| **1. Constraint-Aware Layout Engine** | Complete & Verified | `LayoutBuilder` constraint extraction in `AdaptiveLayoutData`; tested across 320–1440dp viewports. |
| **2. Breakpoints & Configuration** | Complete & Verified | Material 3 aligned 5-tier breakpoints (`compact`, `medium`, `expanded`, `large`, `extraLarge`) in `AdaptiveBreakpoints`. |
| **3. Tokens, Typography & Spacing** | Complete & Verified | `AdaptiveThemeData`, `AdaptiveTokens`, `AdaptiveTypography`, `AdaptiveSpacing` with dark/light mode overrides. |
| **4. BLoC/Cubit Scoping & Lifecycle** | Complete & Verified | `setProvider()` hook with cached provider instances, framework vs external ownership disposal semantics. |
| **5. Selective Rebuild Optimization** | Complete & Verified | `AdaptiveBlocSelector` / `AdaptiveCubitSelector` with `==` short-circuiting; verified 0 sibling rebuilds in unit & example tests. |
| **6. Loading, Skeleton, Empty, Error** | Complete & Verified | `AdaptiveLoading`, `AdaptiveErrorView`, `AdaptiveEmptyState`, and newly added `AdaptiveSkeleton` (shimmer pulse box, circle, text). |
| **7. A11y, Text Scaling, Safe Areas** | Complete & Verified | System `TextScaler` clamped scaling, minimum 48dp touch targets on compact screens, `AdaptiveSafeArea`. |
| **8. Navigation, Scaffold & Dialogs** | Complete & Verified | Newly added `AdaptiveScaffold` (M3 bottom `NavigationBar` on compact vs side `NavigationRail` / extended rail on wide screens). |
| **9. Diagnostics & Debugging Tools** | Complete & Verified | `AdaptiveDebugOverlay` and `AdaptiveDiagnostics` HUD; top-docked with zero tap interference. |
| **10. Tests & Benchmarks** | Complete & Verified | 66 package tests + 5 example application widget tests (71 total tests passing). |
| **11. Example App & Documentation** | Complete & Verified | Full-featured 4-tab showcase studio in `example/`, comprehensive README and architecture specs. |
| **12. Package Metadata & Release** | Complete & Verified | Clean `pubspec.yaml`, valid license, 0 analyzer issues, sound null safety, and zero third-party layout dependencies. |

---

## 5. Current Progress & Verification Matrix

- **Static Analysis**: `flutter analyze .` passing with 0 issues.
- **Example Analysis**: `flutter analyze example` passing with 0 issues.
- **Code Formatting**: `dart format .` passing 100% cleanly.
- **Automated Tests**: **71 tests passing** across package and example suites:
  - Breakpoint classification & tier comparison: 4 tests
  - Pure computation engine & column math: 4 tests
  - AdaptiveValue resolution (fixed, breakpoint, builder, auto): 6 tests
  - Accessibility & 2.0x TextScaler resilience: 2 tests
  - Multi-viewport layout adaptation (320px to 1440px, portrait/landscape, keyboard insets): 7 tests
  - BLoC provider lifecycle, caching, and disposal: 4 tests
  - Granular selective rebuild isolation & equality short-circuiting: 2 tests
  - Layout widgets (Containers, Row collapse, Grid, AutoSizeText): 17 tests
  - Navigation chrome (`AdaptiveScaffold` bottom nav vs rail vs extended rail): 6 tests
  - Shimmer placeholder loader (`AdaptiveSkeleton` box, text, circle, a11y): 5 tests
  - Theme & Design token propagation: 3 tests
  - Feedback views, ConstrainedBox, and Debug Overlay: 8 tests
  - Example application automated integration/widget tests: 5 tests

---

## 6. Conventions & Rules of Engagement

1. **Keep Public APIs Deliberate**: All exports are declared in `lib/adaptive_ui.dart`. Internal implementation details reside in `lib/src/`.
2. **Never Break Flutter Lifecycle**: Base widgets preserve `initState`, `didUpdateWidget`, `dispose`, and `setState`.
3. **No Unbounded Viewports Without Guard**: In collapsed `AdaptiveRow`, `Expanded` children are automatically unwrapped to prevent vertical flex errors in scrollables.
4. **No Third-Party Responsive Dependencies**: Rely purely on native Flutter layout primitives (`LayoutBuilder`, `MediaQueryData`, `CustomPaint`, `TextPainter`).
5. **Deterministic Testing**: Rebuild counters, controlled Cubits, and multi-viewport pumps must be verified via `flutter test`.

---

## 7. Known Limitations & Edge Cases

1. **Navigator Push Route Scoping**: Providers injected via `setProvider()` are scoped to that widget's subtree. Modal dialogs or pushed routes via `Navigator.push` require passing the BLoC explicitly via `BlocProvider.value` or registering the BLoC at the root `AdaptiveApp`.
2. **Deep Collection Equalities in Selectors**: `AdaptiveBlocSelector` relies on Dart `==`. For mutable collections (`List`, `Map`), wrap them in an immutable value object or use `package:collection` equality helpers.
