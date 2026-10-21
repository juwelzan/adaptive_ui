# Customization Guide

## Overview
Every automated behavior in `adaptive_ui` can be overridden locally on individual widgets or globally using configurations, themes, and scoped state providers.

---

## 1. Native BLoC & Cubit Provider Scoping (`setProvider`)

Define your state-management dependencies directly at the screen level without manual wrapping boilerplate.

### Stateless Screen with `AdaptiveStatelessWidget`
```dart
class StudentSummaryScreen extends AdaptiveStatelessWidget {
  const StudentSummaryScreen({super.key});

  @override
  List<AdaptiveProviderItem> setProvider() => [
    BlocProvider<StudentCubit>(
      create: (context) => StudentCubit(),
    ),
    RepositoryProvider<StudentRepository>(
      create: (context) => StudentRepository(),
    ),
  ];

  @override
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout) {
    return const StudentSummaryContent();
  }
}
```

### Stateful Screen with `AdaptiveStatefulWidget`
```dart
class StudentDashboardScreen extends AdaptiveStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  List<AdaptiveProviderItem> setProvider() => [
    BlocProvider<StudentCubit>(
      create: (context) => StudentCubit(),
    ),
  ];

  @override
  State<StudentDashboardScreen> createAdaptiveState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState
    extends AdaptiveState<StudentDashboardScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout) {
    return Column(
      children: [
        AdaptiveTextField(controller: _searchController),
        const StudentMetricsGrid(),
      ],
    );
  }
}
```

---

## 2. Granular Selective Rebuilds (`AdaptiveBlocSelector`)

To prevent full-screen re-renders on state emissions, use `AdaptiveBlocSelector` at the leaf level:

```dart
AdaptiveColumn(
  children: [
    // Static header: Never rebuilds when student state updates!
    const DashboardHeader(),

    // Dynamic field 1: Rebuilds ONLY when state.name changes
    AdaptiveBlocSelector<StudentCubit, StudentState, String>(
      selector: (state) => state.name,
      builder: (context, name) => AdaptiveText('Student: $name'),
    ),

    // Dynamic field 2: Rebuilds ONLY when state.totalCount changes
    AdaptiveBlocSelector<StudentCubit, StudentState, int>(
      selector: (state) => state.totalCount,
      builder: (context, total) => MetricCard(total: total),
    ),
  ],
)
```

### Accessing Layout Data Inside Selector
```dart
AdaptiveBlocSelector<StudentCubit, StudentState, String>.adaptive(
  selector: (state) => state.name,
  adaptiveBuilder: (context, name, layout) {
    return Text('$name on ${layout.containerBreakpoint.name}');
  },
)
```

---

## 3. Global Configuration
Configure custom breakpoints, base dimensions, and diagnostics at your application root:

```dart
AdaptiveApp(
  config: AdaptiveConfig(
    breakpoints: AdaptiveBreakpoints(
      compactMax: 600.0,
      mediumMax: 900.0,
      expandedMax: 1200.0,
      largeMax: 1600.0,
    ),
    designBaseWidth: 390.0,
    defaultOverflowPolicy: AdaptiveOverflowPolicy.wrap,
    enableDiagnostics: kDebugMode,
    readableTextMaxWidth: 720.0,
    minTouchTargetSize: 48.0,
  ),
  child: MaterialApp(...),
)
```

---

## 4. Using `AdaptiveValue`
`AdaptiveValue<T>` allows fine-grained value resolution:

### Automatic
```dart
AdaptiveContainer(
  padding: const AdaptiveInsets.auto(), // 16dp on compact, 24dp medium, 32dp expanded, 40dp large
  child: ...,
)
```

### Breakpoint-Specific
```dart
AdaptiveText(
  'Header Title',
  size: const AdaptiveValue.breakpoint(
    compact: 18.0,
    medium: 22.0,
    expanded: 28.0,
    large: 36.0,
    fallback: 16.0,
  ),
)
```

### Dynamic Builder
```dart
AdaptiveContainer(
  width: AdaptiveValue.builder(
    (layout) => layout.isCompact ? layout.availableWidth : 480.0,
  ),
  child: ...,
)
```

---

## 5. Custom Themes
Define an `AdaptiveThemeData` to customize spacing scales, colors, corner radii, and typography tokens:

```dart
AdaptiveTheme(
  data: AdaptiveThemeData(
    spacing: AdaptiveSpacing(
      xs: 4.0,
      sm: 8.0,
      md: 16.0,
      lg: 24.0,
      xl: 32.0,
    ),
    colors: AdaptiveColors.light.copyWith(
      primary: Colors.deepPurple,
    ),
  ),
  child: ...,
)
```

