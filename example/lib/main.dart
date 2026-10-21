import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const ExampleApp());
}

/// Simple state holding dashboard metrics.
class DashboardState {
  const DashboardState({
    this.studentCount = 142,
    this.searchQuery = '',
    this.isDarkMode = false,
  });

  final int studentCount;
  final String searchQuery;
  final bool isDarkMode;

  DashboardState copyWith({
    int? studentCount,
    String? searchQuery,
    bool? isDarkMode,
  }) {
    return DashboardState(
      studentCount: studentCount ?? this.studentCount,
      searchQuery: searchQuery ?? this.searchQuery,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

/// Cubit managing dashboard state changes.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState());

  void increment() =>
      emit(state.copyWith(studentCount: state.studentCount + 1));
  void setSearch(String query) => emit(state.copyWith(searchQuery: query));
  void toggleTheme() => emit(state.copyWith(isDarkMode: !state.isDarkMode));
}

/// Root Example App wrapping with [AdaptiveApp].
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveApp(
      config: const AdaptiveConfig(
        enableDiagnostics: true,
        designBaseWidth: 390.0,
      ),
      child: MaterialApp(
        title: 'Adaptive UI Showcase',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E5BB0)),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}

/// Stateful dashboard screen leveraging [AdaptiveStatefulWidget] and `setProvider()`.
class DashboardScreen extends AdaptiveStatefulWidget {
  const DashboardScreen({super.key});

  @override
  List<AdaptiveProviderItem> setProvider() => [
        BlocProvider<DashboardCubit>(
          create: (_) => DashboardCubit(),
        ),
      ];

  @override
  AdaptiveState<DashboardScreen> createAdaptiveState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends AdaptiveState<DashboardScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const AdaptiveText(
          'Adaptive UI Dashboard',
          baseFontSize: 20.0,
          maxFontSize: 24.0,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          AdaptiveIconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Student',
            onPressed: () => context.read<DashboardCubit>().increment(),
          ),
        ],
      ),
      body: AdaptiveScrollView(
        padding: const EdgeInsets.all(16.0),
        centerContent: true,
        maxContentWidth: 1024.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Responsive Search and Action Bar
            AdaptiveRow(
              autoCollapse: true,
              collapseBelowBreakpoint: Breakpoint.medium,
              spacing: const AdaptiveValue.fixed(12.0),
              children: [
                Expanded(
                  child: AdaptiveTextField(
                    controller: _searchController,
                    hintText: 'Search courses or students...',
                    onChanged: (val) =>
                        context.read<DashboardCubit>().setSearch(val),
                  ),
                ),
                AdaptiveButton(
                  onPressed: () => context.read<DashboardCubit>().increment(),
                  icon: const Icon(Icons.person_add, size: 18),
                  child: const Text('Enroll Student'),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Responsive Metrics Grid
            AdaptiveGrid(
              minItemWidth: 220.0,
              spacing: 16.0,
              childAspectRatio: 1.4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                AdaptiveCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AdaptiveText('Total Enrolled', baseFontSize: 14.0),
                      const SizedBox(height: 8.0),
                      AdaptiveBlocSelector<DashboardCubit, DashboardState, int>(
                        selector: (state) => state.studentCount,
                        builder: (ctx, count) => AdaptiveAutoSizeText(
                          '$count Students',
                          minFontSize: 16.0,
                          maxFontSize: 28.0,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const AdaptiveCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AdaptiveText('Active Cohorts', baseFontSize: 14.0),
                      SizedBox(height: 8.0),
                      AdaptiveAutoSizeText(
                        '12 Active',
                        minFontSize: 16.0,
                        maxFontSize: 28.0,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ],
                  ),
                ),
                const AdaptiveCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AdaptiveText('Completion Rate', baseFontSize: 14.0),
                      SizedBox(height: 8.0),
                      AdaptiveAutoSizeText(
                        '94.8%',
                        minFontSize: 16.0,
                        maxFontSize: 28.0,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Reading width constrained section
            AdaptiveTextContainer(
              maxWidth: 720.0,
              child: AdaptiveCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AdaptiveText(
                      'Responsive Architecture Notice',
                      baseFontSize: 18.0,
                      maxFontSize: 22.0,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    const AdaptiveText(
                      'Layout adjustments are driven directly by parent constraints rather than full-window MediaQuery. '
                      'This guarantees correct component rendering inside split-screens, sidebars, and dialog modals.',
                      baseFontSize: 14.0,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16.0),
                    AdaptiveRow(
                      autoCollapse: true,
                      spacing: const AdaptiveValue.fixed(12.0),
                      children: [
                        AdaptiveButton(
                          variant: AdaptiveButtonVariant.outline,
                          onPressed: () {},
                          child: const Text('View Guidelines'),
                        ),
                        AdaptiveButton(
                          variant: AdaptiveButtonVariant.primary,
                          onPressed: () {},
                          child: const Text('Acknowledge'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
