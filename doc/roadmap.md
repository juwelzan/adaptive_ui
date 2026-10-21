# Roadmap

## Phase 1: Core Foundation & Primitives (Released - v0.1.0)
- [x] Parent-constraint based Adaptive Engine (`LayoutBuilder` + `MediaQuery`).
- [x] Standard responsive breakpoints (`compact`, `medium`, `expanded`, `large`, `extraLarge`).
- [x] `AdaptiveValue<T>` system (auto, fixed, breakpoint, builder).
- [x] Base widget abstractions (`AdaptiveStatelessWidget`, `AdaptiveStatefulWidget`, `AdaptiveBuilder`, `AdaptiveScope`).
- [x] Foundational layout widgets (`AdaptiveContainer`, `AdaptiveRow`, `AdaptiveColumn`, `AdaptiveGrid`, `AdaptiveScrollView`, `AdaptiveSafeArea`).
- [x] Accessible typography (`AdaptiveText`, `AdaptiveAutoSizeText`, `AdaptiveRichText`).
- [x] Core controls & surfaces (`AdaptiveButton`, `AdaptiveCard`, `AdaptiveTextContainer`).
- [x] Comprehensive multi-viewport testing suite & example dashboard application.

## Phase 2: BLoC/Cubit Integration & Selective Rebuild Architecture (Released - v0.2.0)
- [x] Overridable `setProvider()` hook on `AdaptiveStatelessWidget` and `AdaptiveStatefulWidget` / `AdaptiveState`.
- [x] Automatic scoped dependency injection via `MultiBlocProvider` and `AdaptiveProviderItem`.
- [x] Full provider ownership & lifecycle management (auto-close for `create`, preservation for `.value`).
- [x] `AdaptiveBlocSelector` and `AdaptiveCubitSelector` with granular equality caching and sibling rebuild immunity.
- [x] `AdaptiveBlocBuilder`, `AdaptiveCubitBuilder`, `AdaptiveBlocConsumer`, `AdaptiveCubitConsumer`, `AdaptiveBlocListener`, `AdaptiveCubitListener`.
- [x] Diagnostic overlay (`AdaptiveDebugOverlay`) and feedback widgets (`AdaptiveEmptyState`, `AdaptiveErrorView`, `AdaptiveLoading`).
- [x] Real-world 4-tab interactive studio showcase in `example/lib/main.dart` (Dashboard, Rebuild Lab, States, Constrained Layouts).
- [x] Full test suite (55 automated tests covering layout, theme, accessibility, lifecycle, and rebuild isolation).

## Phase 3: Platform & Desktop Specialization (Upcoming - v0.3.0)
- [ ] Adaptive navigation scaffold (switching dynamically between `NavigationBar`, `NavigationRail`, and `NavigationDrawer`).
- [ ] Master-detail two-pane layout for tablets and foldables.
- [ ] Contextual floating action button positioning based on keyboard visibility and screen orientation.
- [ ] Native context menus and right-click popups on desktop.
- [ ] Keyboard shortcut binding integrations.
- [ ] Advanced window resizing animations and transition interpolations.
