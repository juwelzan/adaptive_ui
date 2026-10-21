# Adaptive UI — Authoritative Project Context & Architecture Guide

## 1. Executive Summary

`adaptive_ui` is an **automatic-first**, **developer-configurable**, and **performance-conscious** responsive UI framework, state management bridge, motion engine, and widget system for Flutter applications.

It provides an end-to-end multi-platform layout engine paired with:
1. Native BLoC/Cubit provider scoping (`setProvider()`) and granular selective rebuild isolation (`AdaptiveBlocSelector` / `AdaptiveCubitSelector`).
2. Centralized, accessibility-first Motion System (`AdaptiveMotion`) with automatic reduced-motion detection.
3. Restrained, constraint-aware text motion (`AdaptiveText` with genuine overflow detection, marquee, fade-in, slide-in, and typewriter effects).
4. Responsive navigation suite (`AdaptiveSidebar` expanded/collapsed modes and `AdaptiveBottomNavigationBar` Material 3 indicator).
5. Composable implicit animation container (`AdaptiveContainer` with hover, press, decoration, and constraint animations).
6. GPU-accelerated Shimmer & Skeleton Loading suite (`AdaptiveShimmer`, `AdaptiveSkeleton`, `AdaptiveSkeletonText`, `AdaptiveSkeletonContainer`, and `AdaptiveSkeletonList`).

---

## 2. Core Architecture & Design Decisions

### A. Constraint-First vs Window-First Layout Engine
- **Primary Driver**: Component-level layout decisions evaluate `LayoutBuilder` parent constraints, captured in immutable [AdaptiveLayoutData](lib/src/core/adaptive_layout_data.dart).
- **Secondary Driver**: `MediaQuery` is reserved exclusively for window-level environmental properties (accessibility `TextScaler`, software keyboard `viewInsets`, system notches/safe-areas `viewPadding`, orientation, pixel density, and accessibility `disableAnimations`).
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

### F. Shared Motion System (`AdaptiveMotion`)
- Standardized duration tokens: `immediate` (0ms), `fast` (150ms), `standard` (250ms), `medium` (350ms), `slow` (500ms), `marqueeSpeed` (40.0 dp/s), `shimmerDuration` (1500ms).
- Standardized easing curves: `standardCurve` (`Curves.easeInOutCubic`), `emphasizedDecelerate` (`Curves.easeOutCubic`), `emphasizedAccelerate` (`Curves.easeInCubic`).
- **Reduced-Motion Resolution**: `AdaptiveMotion.isReducedMotion(context)` inspects `MediaQuery.disableAnimationsOf(context)` and `AdaptiveConfig`. `resolveDuration()` collapses animation durations to `Duration.zero` when reduced-motion accessibility preference is active.

### G. Feature A — `AdaptiveText` Motion Engine
- **Non-Forced Animation**: Static by default (`AdaptiveTextAnimation.none`). Only animates when explicitly enabled.
- **Genuine Overflow Detection**: In marquee mode (`AdaptiveTextAnimation.marquee` or `autoScroll: true`), `TextPainter` measures the unconstrained text width against available parent constraints (`constraints.maxWidth`). If text fits within bounds, auto-scroll is skipped and text renders statically.
- **Unbounded Constraint Safety**: The marquee translates inside an `OverflowBox` bounded vertically by a measured `SizedBox(height: painter.height)`, preventing infinite height layout exceptions inside scroll views.
- **Entrance Motions**: Supports `fadeIn`, `slideIn` (from subtle vertical offset), and `typewriter` (progressive character emission) with lifecycle-safe animation controllers.
- **Accessibility & Semantics**: Preserves full screen-reader announcements via `Semantics(label: ...)` and collapses immediately to static text under reduced-motion mode.

### H. Feature B — `AdaptiveSidebar` Navigation
- **Responsive Modes**: Adapts between expanded mode (240dp default) and compact rail mode (72dp default) based on `isExpanded` or `autoExpandBreakpoint` (`Breakpoint.expanded`).
- **Animated Width Transition**: Uses `AnimatedContainer` with `AdaptiveMotion.medium` duration and `AdaptiveMotion.standardCurve` for smooth drawer/rail toggles.
- **Animated Selection Pill**: Item tiles feature Material 3 animated selection background pill with theme-derived active indicator color.
- **Overflow & Overlay Safety**: Item list is wrapped in `SingleChildScrollView` to prevent vertical height overflows. Tooltips verify ambient `Overlay.maybeOf(context)` presence to allow safe rendering in isolated unit tests.
- **Item Badges & Tooltips**: Supports custom item badges (e.g., notification counts) and automatic icon tooltips in collapsed mode.

### I. Feature C — `AdaptiveBottomNavigationBar`
- **Material 3 Alignment**: Compact horizontal bar with centered animated indicator pill (`AnimatedContainer`), badge placement, and label visibility policies (`alwaysShow`, `onlyShowSelected`, `neverShow`).
- **Touch Target Accessibility**: Enforces interactive hit targets $\ge 48\text{dp} \times 48\text{dp}$ adhering strictly to WCAG touch target guidelines.
- **Safe Area Insets**: Wraps content in `SafeArea(top: false, ...)` ensuring native gesture bar avoidance on edge-to-edge iOS and Android displays.

### J. Feature D — `AdaptiveContainer` Composable Motion
- **Implicit Animations**: When `animateChanges: true`, animates visual property mutations (`decoration`, `borderRadius`, `padding`, `margin`, `constraints`, `opacity`) without requiring developer animation controllers.
- **Static Zero-Overhead Default**: When `animateChanges: false`, renders directly as a static `Container`, avoiding unnecessary animation ticker overhead.
- **Interactive State Styling**: Supports optional `hoverDecoration`, `pressDecoration`, `onTap`, and `onHover` callbacks with internal state tracking.

### K. Feature E — `AdaptiveShimmer` & Skeleton Loading Suite
- **GPU-Accelerated Shimmer**: Uses `ShaderMask` with an animated `LinearGradient` sweep. Avoids expensive pixel-blur or CPU shaders.
- **AdaptiveSkeleton Switcher**: Provides reactive `loading`, `child`, and `placeholder` API using `AnimatedCrossFade`. Disables semantics on placeholder loading trees to prevent misleading screen-reader announcements.
- **Skeleton Primitives**:
  - `AdaptiveSkeleton.box(...)`: Rectangular and rounded card placeholders.
  - `AdaptiveSkeleton.text(...)`: Single-line typography placeholder.
  - `AdaptiveSkeleton.circle(...)`: Circular avatar and icon placeholders.
  - `AdaptiveSkeletonText`: Multi-line realistic paragraph placeholder with randomized or configurable last-line ratio (default 0.65).
  - `AdaptiveSkeletonContainer`: Structured card container placeholder with padding and borders.
  - `AdaptiveSkeletonList`: Pre-composed list item skeletons with avatar and dual-line placeholders.

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
│       │   │   ├── adaptive_container.dart        # Composable implicit animated container
│       │   │   ├── adaptive_expanded.dart
│       │   │   ├── adaptive_flex.dart             # Policy-driven flex container (Row/Col/Wrap switching)
│       │   │   ├── adaptive_gap.dart
│       │   │   ├── adaptive_grid.dart             # Dynamic grid with maxItemWidth & extent
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
│       │   │   ├── adaptive_text.dart             # Marquee, FadeIn, SlideIn, Typewriter text
│       │   │   └── adaptive_text_style.dart
│       │   ├── navigation/                    # Responsive navigation components
│       │   │   ├── adaptive_sidebar.dart          # Expandable desktop/tablet sidebar & rail
│       │   │   └── adaptive_bottom_navigation_bar.dart # Material 3 bottom navigation bar
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
│       │   └── feedback/                      # Empty, loading, skeleton, shimmer views
│       │       ├── adaptive_empty_state.dart
│       │       ├── adaptive_error_view.dart
│       │       ├── adaptive_loading.dart
│       │       ├── adaptive_shimmer.dart          # GPU gradient shimmer mask
│       │       └── adaptive_skeleton.dart         # Skeleton switcher & primitive placeholders
│       ├── theme/                             # Design tokens, motion, theme overrides
│       │   ├── adaptive_colors.dart
│       │   ├── adaptive_motion.dart           # Standard animation durations & curves
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
├── test/                                      # Automated test suite (137 tests)
│   ├── widgets/
│   │   ├── adaptive_text_animation_test.dart
│   │   ├── adaptive_sidebar_test.dart
│   │   ├── adaptive_bottom_navigation_bar_test.dart
│   │   ├── adaptive_container_animation_test.dart
│   │   └── adaptive_shimmer_skeleton_test.dart
├── example/                                   # Real-world 5-tab studio showcase with tests (9 tests)
│   ├── lib/
│   │   ├── main.dart                          # Studio app with BLoC state & tab router
│   │   └── motion_showcase.dart               # Dedicated Phase 4 motion & skeleton showcase
│   └── test/
│       └── widget_test.dart
├── doc/                                       # Technical architectural specifications
├── pubspec.yaml
└── README.md
```

---

## 4. Phase 4 Test Matrix (Focused Suites & Regression Coverage)

| Area | Test Suite File | Test Count | Status | Key Verifications |
| :--- | :--- | :--- | :--- | :--- |
| **Motion Tokens & Helpers** | `adaptive_text_animation_test.dart` | 8 | Pass | Reduced-motion resolution, duration collapsing, standard curves. |
| **AdaptiveText Motion** | `adaptive_text_animation_test.dart` | 8 | Pass | Static short text, true constraint overflow marquee, typewriter, fadeIn, slideIn, controller disposal, reduced motion bypass. |
| **AdaptiveSidebar** | `adaptive_sidebar_test.dart` | 7 | Pass | Expanded (240dp) vs collapsed (72dp) modes, selection callbacks, long scrollable lists, auto-expand breakpoint, badges, safe overlay tooltips. |
| **AdaptiveBottomNavigationBar** | `adaptive_bottom_navigation_bar_test.dart` | 6 | Pass | Destination rendering, selection tap callback, label visibility modes (`alwaysShow`, `onlyShowSelected`, `neverShow`), touch target $\ge 48\text{dp}$, safe area padding. |
| **AdaptiveContainer Motion** | `adaptive_container_animation_test.dart` | 4 | Pass | Animated property transitions (decoration, radii, padding, opacity), state preservation of stateful children, tap/hover callbacks, reduced-motion bypass. |
| **AdaptiveShimmer & Skeletons** | `adaptive_shimmer_skeleton_test.dart` | 6 | Pass | GPU gradient sweep, conditional `AdaptiveSkeleton` switcher toggles, `AdaptiveSkeletonText` multi-line layout, `AdaptiveSkeletonList` item count, reduced-motion handling. |
| **Showcase Example App** | `example/test/widget_test.dart` | 9 | Pass | 5-tab navigation, Rebuild Lab state isolation, state switcher, token constraints, desktop chrome adaptation, extreme window shrink, snackbar listener, Phase 4 interactive Motion tab. |

---

## 5. Current Progress & Verification Matrix

- **Static Analysis**: `flutter analyze .` (package) passing with **0 issues**.
- **Example Analysis**: `flutter analyze .` (example) passing with **0 issues**.
- **Code Formatting**: `dart format .` passing 100% cleanly across all files.
- **Automated Tests**: **146 tests passing** across package and example suites:
  - Package Tests: **137 tests passing** (up from 106).
  - Example App Tests: **9 tests passing** (up from 8).

---

## 6. Conventions & Rules of Engagement

1. **Keep Public APIs Deliberate**: All exports are declared in `lib/adaptive_ui.dart`. Internal implementation details reside in `lib/src/`.
2. **Never Force Animations Unconditionally**: Static presentation is always the performant default. Motion is opt-in via explicit typed enums (`AdaptiveTextAnimation.marquee`) or boolean toggles (`animateChanges: true`).
3. **Respect Reduced Motion Everywhere**: `AdaptiveMotion.isReducedMotion(context)` checks `MediaQuery.disableAnimationsOf(context)` and immediately disables timers, marquees, and transitions for accessibility compliance.
4. **Guarded Infinite Constraints**: In marquees and skeleton loaders, measured bounds prevent unbounded RenderFlex or RenderConstrainedOverflowBox exceptions in scroll views.
5. **No Third-Party Responsive or Animation Dependencies**: Rely purely on native Flutter layout primitives (`LayoutBuilder`, `MediaQueryData`, `TextPainter`, `ShaderMask`, `AnimatedContainer`, `AnimatedCrossFade`, `SlideTransition`, `FadeTransition`) and existing `flutter_bloc`.
6. **Deterministic Testing**: Repeating animations schedule ongoing frames; tests use discrete `tester.pump(duration)` instead of open-ended `pumpAndSettle()`.
