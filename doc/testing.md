# Testing Adaptive Layouts

## Overview
Responsive Flutter testing requires validating behavior across multiple viewports, parent constraints, orientations, and accessibility text scaling settings.

## Recommended Test Strategy

### 1. Viewport Matrix
Test components across standardized device viewports:
- **Compact Phone**: 320 x 568 (e.g. iPhone SE)
- **Standard Phone**: 390 x 844 (e.g. iPhone 14)
- **Tablet (Portrait)**: 768 x 1024 (e.g. iPad)
- **Tablet (Landscape)**: 1024 x 768 (e.g. iPad landscape)
- **Desktop**: 1440 x 900 (e.g. MacBook / PC)
- **Ultra-Wide**: 1920 x 1080 (e.g. Desktop monitor)

### 2. Setting Viewport Sizes in Widget Tests
In Flutter test environments, configure `tester.view.physicalSize` and `tester.view.devicePixelRatio`:

```dart
testWidgets('AdaptiveRow renders row on wide and collapses on compact', (tester) async {
  // Test compact phone
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    wrapWithAdaptive(
      size: const Size(320, 568),
      child: const AdaptiveRow(
        autoCollapse: true,
        children: [Text('A'), Text('B')],
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.byType(Column), findsWidgets);
});
```

### 3. Accessibility Text Scaling Tests
Verify that layouts remain stable and do not crash when accessibility text scaling is enlarged:

```dart
testWidgets('AdaptiveText scales with accessibility TextScaler (1.5x and 2.0x)', (tester) async {
  await tester.pumpWidget(
    wrapWithAdaptive(
      textScaler: const TextScaler.linear(2.0),
      child: const AdaptiveText(
        'Accessible Heading',
        minFontSize: 14.0,
        maxFontSize: 28.0,
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(tester.takeException(), isNull);
});
```

### 4. WCAG Touch Target Verification
Verify that interactive elements maintain minimum 48x48dp dimensions on touchscreens:

```dart
testWidgets('Button provides >= 48dp height on mobile', (tester) async {
  await tester.pumpWidget(
    wrapWithAdaptive(
      size: const Size(320, 568),
      child: AdaptiveButton(onPressed: () {}, child: const Text('Action')),
    ),
  );
  await tester.pumpAndSettle();

  final size = tester.getSize(find.byType(AdaptiveButton));
  expect(size.height, greaterThanOrEqualTo(48.0));
});
```

### 5. Testing BLoC/Cubit Lifecycle & Rebuild Counts
Use rebuild tracking wrappers and equality checks to assert zero-rebuild isolation:

```dart
testWidgets('AdaptiveBlocSelector triggers rebuild ONLY for targeted field', (tester) async {
  final cubit = DashboardCubit();
  int nameRebuilds = 0;
  int countRebuilds = 0;

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider.value(
        value: cubit,
        child: Column(
          children: [
            AdaptiveBlocSelector<DashboardCubit, DashboardState, String>(
              selector: (s) => s.name,
              builder: (ctx, name) {
                nameRebuilds++;
                return Text('Name: $name');
              },
            ),
            AdaptiveBlocSelector<DashboardCubit, DashboardState, int>(
              selector: (s) => s.count,
              builder: (ctx, count) {
                countRebuilds++;
                return Text('Count: $count');
              },
            ),
          ],
        ),
      ),
    ),
  );

  expect(nameRebuilds, equals(1));
  expect(countRebuilds, equals(1));

  // Update only count: nameRebuilds MUST remain 1
  cubit.incrementCount();
  await tester.pump();

  expect(nameRebuilds, equals(1));
  expect(countRebuilds, equals(2));
});
```
