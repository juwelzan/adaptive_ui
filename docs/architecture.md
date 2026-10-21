# Adaptive UI Architecture

## Architectural Philosophy
`adaptive_ui` is architected upon two foundational principles:

1. **Parent Constraints First, Window Environment Second.**
   Layout decisions are driven by `LayoutBuilder` parent constraints, ensuring stability inside split-views, dialogs, and sidebars, while `MediaQuery` is reserved for window-level environment properties (`TextScaler`, `viewInsets`, `viewPadding`).

2. **Decoupled State Propagation & Granular Selective Rebuilds.**
   State changes must never trigger full-screen redraws or recompute responsive layouts. Business logic state subscriptions are isolated to targeted leaf widgets via `AdaptiveBlocSelector`.

```
       +-----------------------------------------+
       |               MediaQuery                |
       |  (Screen size, TextScaler, ViewInsets)  |
       +--------------------+--------------------+
                            |
                            v
       +--------------------+--------------------+
       |   MultiBlocProvider (setProvider)       |
       |  (Scoped BLoC / Cubit / Repository)     |
       +--------------------+--------------------+
                            |
                            v
       +--------------------+--------------------+
       |              LayoutBuilder              |
       |       (Parent BoxConstraints)           |
       +--------------------+--------------------+
                            |
                            v
       +--------------------+--------------------+
       |         AdaptiveLayoutData              |
       |  - containerBreakpoint                  |
       |  - windowBreakpoint                     |
       |  - availableWidth / availableHeight     |
       |  - textScaler, orientation, deviceType  |
       +--------------------+--------------------+
                            |
            +---------------+---------------+
            v                               v
    Static UI / Shell             Selective State Subscriptions
(AdaptiveColumn, Row, Container)   (AdaptiveBlocSelector, Consumer)
```

## Layered Design

### 1. BLoC & State Management Scope (`src/widgets/bloc/` & `src/core/adaptive_provider.dart`)
- **`setProvider()` Hook**: Overridable on both `AdaptiveStatelessWidget` and `AdaptiveStatefulWidget` / `AdaptiveState`.
- **`AdaptiveProviderItem`**: Alias for `SingleChildWidget`, accepting `BlocProvider`, `RepositoryProvider`, and custom providers.
- **Provider Ownership**:
  - Blocs/Cubits created using `BlocProvider(create: (context) => ...)` are owned by the widget's subtree and automatically closed when the widget is unmounted.
  - Existing instances supplied using `BlocProvider.value(value: ...)` are externally owned and will NOT be closed upon unmount.
  - Instances are retained across parent rebuilds through Flutter's `InheritedProviderElement` state preservation.
- **`AdaptiveBlocSelector`**: Subscribes to targeted state slices. Only rebuilds when `selector(state)` yields a value that does not equal (`!=`) the previous value.
- **`AdaptiveBlocBuilder` & `AdaptiveBlocConsumer`**: Reactive builders supporting conditional filtering (`buildWhen`, `listenWhen`) and adaptive layout data.

### 2. Core Engine (`src/core/`)
- **`AdaptiveLayoutData`**: An immutable snapshot containing resolved parent constraints (`BoxConstraints`), window dimensions, container and window breakpoints, orientation, accessibility `TextScaler`, and software keyboard `viewInsets`.
- **`AdaptiveBreakpoints`**: Threshold boundaries categorizing widths into `compact`, `medium`, `expanded`, `large`, and `extraLarge`.
- **`AdaptiveEngine`**: Pure algorithms calculating proportional font scaling, grid column distributions, and row collapse logic.
- **`AdaptiveValue<T>`**: Polymorphic value carrier enabling `.auto()`, `.fixed(value)`, `.breakpoint(...)`, and `.builder(...)` value resolutions.
- **`AdaptiveScope`**: Inherited widget managing configuration cascade down the tree.

### 3. Widget Abstractions (`src/widgets/`)
- **`AdaptiveStatelessWidget`**: Stateless base class offering `setProvider()` and `buildAdaptive(context, layout)`.
- **`AdaptiveStatefulWidget` & `AdaptiveState`**: Stateful base class preserving `initState`, `didChangeDependencies`, `didUpdateWidget`, `dispose`, and controllers while offering `setProvider()` and `buildAdaptive(context, layout)`.
- **`AdaptiveBuilder`**: Evaluates parent constraints via `LayoutBuilder` and yields `AdaptiveLayoutData`.

### 4. Layout Primitives (`src/widgets/layout/`)
- **`AdaptiveContainer`**: Container with responsive padding, margin, and constraints.
- **`AdaptiveRow` & `AdaptiveColumn`**: Flex layouts with automatic collapse and spacing.
- **`AdaptiveGrid`**: Dynamic column count generation based on cell `minItemWidth`.
- **`AdaptiveScrollView`**: Keyboard avoidance with readable text centering.
- **`AdaptiveCenter`**: Centering with maximum content width constraints.

### 5. Typography (`src/widgets/typography/`)
- **`AdaptiveText`**: Auto-scaling text clamped within accessibility-safe bounds.
- **`AdaptiveAutoSizeText`**: Binary-search font sizing fitting bounded boxes without dropping below `minFontSize`.
- **`AdaptiveTextStyle`**: Responsive style definition.

### 6. Theming & Tokens (`src/theme/`)
- Cohesive token-driven system for spacing (`AdaptiveSpacing`), sizing (`AdaptiveSizing`), corner radii (`AdaptiveRadii`), typography (`AdaptiveTypography`), and colors (`AdaptiveColors`).

### 7. Diagnostics (`src/diagnostics/`)
- **`AdaptiveDiagnostics`**: Analyzes constraints and reports dangerous allocations or unbounded flex boxes.
- **`AdaptiveDebugOverlay`**: Live visual overlay displaying current container breakpoint, window size, and text scaling factor.

