# Responsive Rules & Layout Guidelines

## Core Principles

### 1. Constraints Go Down, Sizes Go Up, Parent Sets Position
- Layout decisions must always be guided by the parent's constraints (`BoxConstraints.maxWidth`), not `MediaQuery.sizeOf(context).width`.
- Never force fixed pixel widths that exceed parent bounds.

### 2. Standard Breakpoint Tiers
| Breakpoint | Width (dp) | Representative Devices & Environments | Typical Layout Behavior |
| :--- | :--- | :--- | :--- |
| **`compact`** | `< 600` | Smartphones in portrait, split views | 1-column layouts, collapsed rows, full-width actions, 16dp margins |
| **`medium`** | `600 - 839` | Tablets in portrait, foldables, phones in landscape | 2-column layouts, expanded sidebars, 24dp margins |
| **`expanded`** | `840 - 1199` | Tablets in landscape, small laptops | 2 to 3-column layouts, persistent navigation rails, 32dp margins |
| **`large`** | `1200 - 1599` | Desktop displays, large laptops | 3 to 4-column layouts, centered reading containers (max 720-1024dp) |
| **`extraLarge`**| `>= 1600` | Ultra-wide displays, multi-monitor workstations | Max-width content clamping, 4+ column layouts, 40dp margins |

### 3. Layout Best Practices

#### Preventing Horizontal Stretching
Large screens can make text difficult to read if allowed to stretch across the full width of the monitor.
- Wrap content in `AdaptiveCenter(maxWidth: 720)` or `AdaptiveTextContainer`.
- Convert linear lists to `AdaptiveGrid` using `minItemWidth: 240.0`.

#### Auto-Collapsing Rows
When presenting items side-by-side:
```dart
AdaptiveRow(
  autoCollapse: true,
  collapseBelowBreakpoint: Breakpoint.medium,
  spacing: AdaptiveValue.fixed(16.0),
  children: [
    AdaptiveButton(onPressed: () {}, child: const Text('Confirm')),
    OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
  ],
)
```
On wide displays, buttons display side-by-side. On compact viewports, they stack vertically and stretch to full width for comfortable touch interaction.
