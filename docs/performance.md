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

### 4. Zero External Dependencies
`adaptive_ui` has zero third-party dependencies, guaranteeing minimal binary size overhead and instantaneous startup times.
