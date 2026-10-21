# Changelog

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.2.0] - BLoC/Cubit Integration & Granular Rebuild Optimization

### Added
- Overridable `setProvider()` hook on `AdaptiveStatelessWidget` and `AdaptiveStatefulWidget` / `AdaptiveState`.
- Automatic scoped dependency injection via `MultiBlocProvider`.
- `AdaptiveBlocSelector` for selective widget rebuilding using equality checks, isolating state changes from parent and sibling widgets.
- `AdaptiveBlocBuilder` with conditional `buildWhen` filtering and layout-aware adaptive builders.
- `AdaptiveBlocConsumer` and `AdaptiveBlocListener` for side-effect dispatch and reactive building.
- Full provider ownership management: automatic `.close()` on framework-owned instances created via `create`; preservation of externally owned instances supplied via `.value`.
- Type alias `AdaptiveProviderItem` (`SingleChildWidget`) supporting `BlocProvider`, `RepositoryProvider`, and custom provider implementations.
- Comprehensive test suites in `test/bloc/` covering provider lifecycles, memory safety, instance preservation, and deterministic granular rebuild counts.

## [0.1.0] - Initial Release

### Features
- Core adaptive layout engine based on `LayoutBuilder` parent constraints and `MediaQuery` environment data.
- Flexible `AdaptiveValue<T>` system supporting auto, fixed, breakpoint-based, and builder resolutions.
- Adaptive breakpoints: `compact`, `medium`, `expanded`, `large`, `extraLarge`.
- Base abstractions: `AdaptiveStatelessWidget`, `AdaptiveStatefulWidget`, `AdaptiveBuilder`, `AdaptiveScope`, `AdaptiveApp`.
- Foundation layout widgets:
  - `AdaptiveContainer`, `AdaptivePadding`, `AdaptiveSizedBox`, `AdaptiveGap`
  - `AdaptiveRow`, `AdaptiveColumn`, `AdaptiveWrap`, `AdaptiveGrid`
  - `AdaptiveExpanded`, `AdaptiveCenter`, `AdaptiveSafeArea`, `AdaptiveScrollView`
  - `AdaptiveVisibility`, `AdaptiveConstrainedBox`
- Typography system:
  - `AdaptiveText`, `AdaptiveRichText`, `AdaptiveTextStyle`, `AdaptiveAutoSizeText`
  - Text scaling compliance with accessibility `TextScaler`
- Controls:
  - `AdaptiveButton`, `AdaptiveIconButton`, `AdaptiveTextField`, `AdaptiveSwitch`, `AdaptiveCheckbox`, `AdaptiveSlider`
- Surfaces & Feedback:
  - `AdaptiveCard`, `AdaptiveSurface`, `AdaptiveTextContainer`
  - `AdaptiveLoading`, `AdaptiveEmptyState`, `AdaptiveErrorView`
- Adaptive theming system:
  - `AdaptiveTheme`, `AdaptiveThemeData`, `AdaptiveTokens`, `AdaptiveSpacing`, `AdaptiveSizing`, `AdaptiveTypography`, `AdaptiveRadii`, `AdaptiveColors`
- Diagnostics:
  - `AdaptiveDiagnostics`, `AdaptiveDebugOverlay`
- Extensions:
  - `AdaptiveContextExtensions`, `AdaptiveNumExtensions`
