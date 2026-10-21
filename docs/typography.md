# Adaptive Typography & Accessibility

## Philosophy
Typography should scale smoothly between mobile and desktop displays without breaking accessibility settings or causing overflow.

### The Accessibility TextScaler Rule
Standard Flutter accessibility enables users with visual impairments to scale fonts up to 2.0x or higher via system settings (`MediaQueryData.textScaler`).

**Never do this:**
```dart
// ANTI-PATTERN: Forcing no scaling undermines user accessibility!
MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling), ...)
```

**Instead, do this:**
```dart
// RECOMMENDED: AdaptiveText automatically adapts to available parent width
// while strictly respecting system TextScaler and clamping to safe bounds.
AdaptiveText(
  'Student Dashboard',
  baseFontSize: 18.0,
  minFontSize: 14.0, // Guaranteed minimum legible size
  maxFontSize: 28.0, // Maximum cap preventing clipping
  maxLines: 2,
  overflowPolicy: AdaptiveOverflowPolicy.ellipsis,
)
```

## `AdaptiveAutoSizeText`
When rendering headlines inside bounded height and width containers (such as metric cards or badges), `AdaptiveAutoSizeText` dynamically scales down text using an optimized binary-search algorithm down to `minFontSize`.

```dart
AdaptiveAutoSizeText(
  '\$182,400.00',
  minFontSize: 16.0,
  maxFontSize: 32.0,
  maxLines: 1,
)
```
- If the text fits at `maxFontSize`, it uses `maxFontSize`.
- If the space is tight, it scales down smoothly without dropping below `minFontSize`.
- If even `minFontSize` cannot fit, it falls back to explicit overflow handling (`TextOverflow.ellipsis`).

## Optimal Line Length for Long-Form Reading
Studies indicate that readable text should span between 60 and 75 characters per line (approximately 600 to 720 logical pixels). Use `AdaptiveTextContainer` to ensure articles and body copy never stretch to unreadable widths on large screens:

```dart
AdaptiveTextContainer(
  maxWidth: 720.0,
  child: Column(
    children: [
      AdaptiveText('Article Title', style: TextStyle(fontWeight: FontWeight.bold)),
      AdaptiveText('Long reading copy...'),
    ],
  ),
)
```
