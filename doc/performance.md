# Performance Guide

## Principles for High-Performance Responsive Layouts

### 1. Minimal Rebuilds with Scoped LayoutBuilders
Do not place a single `LayoutBuilder` at the top of the app to rebuild the entire application tree upon resize.
Instead, use scoped adaptive widgets (`AdaptiveContainer`, `AdaptiveRow`, `AdaptiveBuilder`) near the leaf widgets that actually need to adjust their internal layout.

### 2. Avoid Intrinsic Measurements
Flutter's `IntrinsicWidth` and `IntrinsicHeight` pass multiple layout passes down the element tree, leading to $O(N^2)$ layout performance.
`adaptive_ui` avoids intrinsic measurements completely by:
- Deriving dimensions strictly from parent `BoxConstraints`.
- Using off-screen `TextPainter` binary searches with explicit `maxWidth` bounds in `AdaptiveAutoSizeText`.
- Using mathematical scalars (`AdaptiveMath.scaleWithDamping`) for continuous transitions.

### 3. Lazy Rendering for Large Grids and Lists
When rendering grids with many items, always prefer `AdaptiveGrid.builder` over static children arrays:

```dart
// RECOMMENDED for large lists:
AdaptiveGrid.builder(
  itemCount: items.length,
  minItemWidth: 240.0,
  itemBuilder: (context, index) => ItemCard(items[index]),
)
```

### 4. Selective State Subscriptions & Granular Rebuilds
State emissions must not cause full-screen redraws or recompute parent layout constraints. Using `AdaptiveBlocSelector` at the leaf level ensures that:
- Rebuilds occur only when the selected state slice changes value (`!=`).
- Sibling widgets and parent containers experience zero rebuilds.
- Continuous layout animations or input focus are preserved without interruption.

### 5. Minimal, Focused Dependencies
`adaptive_ui` relies only on the standard `flutter_bloc` package for provider and state-management integration and the lightweight `nested` package for efficient multi-provider composition, guaranteeing minimal binary size overhead and fast startup times.
