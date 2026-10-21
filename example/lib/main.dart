import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const AdaptiveShowcaseApp());
}

// ---------------------------------------------------------------------------
// 1. Cubit & State Management
// ---------------------------------------------------------------------------

enum TelemetryStatus { loading, empty, error, populated }

class ShowcaseState {
  const ShowcaseState({
    this.studentCount = 142,
    this.department = 'Computer Science',
    this.notificationsCount = 5,
    this.status = TelemetryStatus.populated,
    this.isDarkMode = false,
  });

  final int studentCount;
  final String department;
  final int notificationsCount;
  final TelemetryStatus status;
  final bool isDarkMode;

  ShowcaseState copyWith({
    int? studentCount,
    String? department,
    int? notificationsCount,
    TelemetryStatus? status,
    bool? isDarkMode,
  }) {
    return ShowcaseState(
      studentCount: studentCount ?? this.studentCount,
      department: department ?? this.department,
      notificationsCount: notificationsCount ?? this.notificationsCount,
      status: status ?? this.status,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class ShowcaseCubit extends Cubit<ShowcaseState> {
  ShowcaseCubit() : super(const ShowcaseState());

  void incrementStudents() =>
      emit(state.copyWith(studentCount: state.studentCount + 1));

  void incrementNotifications() =>
      emit(state.copyWith(notificationsCount: state.notificationsCount + 1));

  void setDepartment(String dept) => emit(state.copyWith(department: dept));

  void setStatus(TelemetryStatus status) =>
      emit(state.copyWith(status: status));

  void toggleTheme() => emit(state.copyWith(isDarkMode: !state.isDarkMode));
}

// ---------------------------------------------------------------------------
// 2. Root Application
// ---------------------------------------------------------------------------

class AdaptiveShowcaseApp extends StatelessWidget {
  const AdaptiveShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveApp(
      config: const AdaptiveConfig(
        enableDiagnostics: true,
        designBaseWidth: 390.0,
      ),
      child: MaterialApp(
        title: 'Adaptive UI Framework Showcase',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E5BB0)),
        ),
        home: const ShowcaseHomeScreen(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Main Adaptive Stateful Screen with `setProvider()`
// ---------------------------------------------------------------------------

class ShowcaseHomeScreen extends AdaptiveStatefulWidget {
  const ShowcaseHomeScreen({super.key});

  @override
  List<AdaptiveProviderItem> setProvider() => [
        BlocProvider<ShowcaseCubit>(
          create: (_) => ShowcaseCubit(),
        ),
      ];

  @override
  AdaptiveState<ShowcaseHomeScreen> createAdaptiveState() =>
      _ShowcaseHomeScreenState();
}

class _ShowcaseHomeScreenState extends AdaptiveState<ShowcaseHomeScreen> {
  int _currentTabIndex = 0;

  // Rebuild trackers to visibly verify granular leaf isolation
  int _headerRebuilds = 0;
  int _studentRebuilds = 0;
  int _notificationsRebuilds = 0;

  @override
  Widget buildAdaptive(BuildContext context, AdaptiveLayoutData layout) {
    final cubit = context.read<ShowcaseCubit>();

    return Scaffold(
      appBar: AppBar(
        title: AdaptiveText(
          'Adaptive UI Studio (${layout.containerBreakpoint.name.toUpperCase()})',
          baseFontSize: 18.0,
          maxFontSize: 22.0,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Emit Unrelated Notification',
            onPressed: () => cubit.incrementNotifications(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildResponsiveDashboardTab(context, layout),
          _buildGranularRebuildLabTab(context, layout),
          _buildStateTransitionsTab(context, layout),
          _buildConstrainedBoxTab(context, layout),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: 'Rebuild Lab',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'States',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Tokens',
          ),
        ],
      ),
    );
  }

  // Tab 1: Responsive Layout & Multi-Tier Adaptation
  Widget _buildResponsiveDashboardTab(
      BuildContext context, AdaptiveLayoutData layout) {
    final cubit = context.read<ShowcaseCubit>();

    return AdaptiveScrollView(
      padding: const EdgeInsets.all(16.0),
      centerContent: true,
      maxContentWidth: 1080.0,
      child: AdaptiveColumn(
        spacing: const AdaptiveValue.fixed(16.0),
        children: [
          // Auto-collapsing action bar
          AdaptiveRow(
            autoCollapse: true,
            collapseBelowBreakpoint: Breakpoint.medium,
            spacing: const AdaptiveValue.fixed(12.0),
            children: [
              Expanded(
                child: AdaptiveTextField(
                  hintText: 'Search dashboard records...',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              AdaptiveButton(
                onPressed: () => cubit.incrementStudents(),
                icon: const Icon(Icons.add, size: 18),
                child: const Text('Add Student'),
              ),
            ],
          ),

          // Dynamic Responsive Grid
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
                    const AdaptiveText('Active Students', baseFontSize: 14.0),
                    const SizedBox(height: 8.0),
                    AdaptiveCubitSelector<ShowcaseCubit, ShowcaseState, int>(
                      selector: (s) => s.studentCount,
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
              AdaptiveCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AdaptiveText('Department', baseFontSize: 14.0),
                    const SizedBox(height: 8.0),
                    AdaptiveCubitSelector<ShowcaseCubit, ShowcaseState, String>(
                      selector: (s) => s.department,
                      builder: (ctx, dept) => AdaptiveAutoSizeText(
                        dept,
                        minFontSize: 14.0,
                        maxFontSize: 22.0,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    ),
                  ],
                ),
              ),
              AdaptiveCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AdaptiveText('Notifications', baseFontSize: 14.0),
                    const SizedBox(height: 8.0),
                    AdaptiveCubitSelector<ShowcaseCubit, ShowcaseState, int>(
                      selector: (s) => s.notificationsCount,
                      builder: (ctx, count) => AdaptiveAutoSizeText(
                        '$count Unread',
                        minFontSize: 16.0,
                        maxFontSize: 28.0,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Reading-width constrained text surface
          AdaptiveTextContainer(
            maxWidth: 720.0,
            child: AdaptiveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdaptiveText(
                    'Reading Width Clamping Policy',
                    baseFontSize: 18.0,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  const AdaptiveText(
                    'Even on wide 4K workstations, reading text lines are clamped to '
                    'a maximum of 720dp (approx 60-75 characters per line). '
                    'This follows WCAG ergonomics and prevents eye fatigue.',
                    baseFontSize: 14.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 2: Granular Rebuild Lab with Visible Counters
  Widget _buildGranularRebuildLabTab(
      BuildContext context, AdaptiveLayoutData layout) {
    final cubit = context.read<ShowcaseCubit>();

    return AdaptiveScrollView(
      padding: const EdgeInsets.all(16.0),
      centerContent: true,
      maxContentWidth: 720.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdaptiveText(
            'Granular Rebuild Verification Lab',
            baseFontSize: 20.0,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const AdaptiveText(
            'Click below to emit changes to specific state fields. '
            'Observe how only the targeted leaf rebuilds while siblings remain completely stable.',
            baseFontSize: 14.0,
          ),
          const SizedBox(height: 20.0),

          // Static Header (should remain 1 rebuild)
          Builder(
            builder: (ctx) {
              _headerRebuilds++;
              return AdaptiveCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Static Sibling Header:'),
                    Badge(
                      label: Text('$_headerRebuilds builds'),
                      backgroundColor: Colors.blueGrey,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12.0),

          // Student Count Leaf Selector
          AdaptiveCubitSelector<ShowcaseCubit, ShowcaseState, int>(
            selector: (s) => s.studentCount,
            builder: (ctx, count) {
              _studentRebuilds++;
              return AdaptiveCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Student Leaf: $count students'),
                    Badge(
                      label: Text('$_studentRebuilds builds'),
                      backgroundColor: Colors.green,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12.0),

          // Notification Count Leaf Selector
          AdaptiveCubitSelector<ShowcaseCubit, ShowcaseState, int>(
            selector: (s) => s.notificationsCount,
            builder: (ctx, notifications) {
              _notificationsRebuilds++;
              return AdaptiveCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notifications Leaf: $notifications unread'),
                    Badge(
                      label: Text('$_notificationsRebuilds builds'),
                      backgroundColor: Colors.orange,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24.0),

          // Action buttons triggering state changes
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              AdaptiveButton(
                onPressed: () => cubit.incrementStudents(),
                child: const Text('Update Students Only'),
              ),
              AdaptiveButton(
                onPressed: () => cubit.incrementNotifications(),
                child: const Text('Update Notifications Only'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tab 3: Loading, Empty, Error, and Populated States
  Widget _buildStateTransitionsTab(
      BuildContext context, AdaptiveLayoutData layout) {
    final cubit = context.read<ShowcaseCubit>();

    return Column(
      children: [
        // Status Switcher Bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TelemetryStatus.values.map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(status.name.toUpperCase()),
                    selected: cubit.state.status == status,
                    onSelected: (_) => setState(() => cubit.setStatus(status)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Divider(height: 1.0),

        // Reactive Body depending on Status
        Expanded(
          child: AdaptiveCubitSelector<ShowcaseCubit, ShowcaseState,
              TelemetryStatus>(
            selector: (s) => s.status,
            builder: (ctx, status) {
              switch (status) {
                case TelemetryStatus.loading:
                  return const AdaptiveLoading(
                    message: 'Synchronizing adaptive database...',
                  );
                case TelemetryStatus.empty:
                  return AdaptiveEmptyState(
                    title: 'No Active Enrollments',
                    description: 'No student records match your query.',
                    actionLabel: 'Enroll First Student',
                    onAction: () => cubit.setStatus(TelemetryStatus.populated),
                  );
                case TelemetryStatus.error:
                  return AdaptiveErrorView(
                    message: 'Connection timed out while fetching telemetry.',
                    onRetry: () => cubit.setStatus(TelemetryStatus.populated),
                  );
                case TelemetryStatus.populated:
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: 8,
                    itemBuilder: (ctx, idx) => AdaptiveCard(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${idx + 1}')),
                        title: Text('Student Record #${1000 + idx}'),
                        subtitle: const Text(
                            'Enrolled in Advanced Flutter Engineering'),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  );
              }
            },
          ),
        ),
      ],
    );
  }

  // Tab 4: Constrained Box, Local Theme Tokens & Diagnostics
  Widget _buildConstrainedBoxTab(
      BuildContext context, AdaptiveLayoutData layout) {
    return AdaptiveScrollView(
      padding: const EdgeInsets.all(16.0),
      centerContent: true,
      maxContentWidth: 720.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdaptiveText(
            'Tokens & Constrained Layouts',
            baseFontSize: 20.0,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),

          // AdaptiveConstrainedBox with fallback
          const AdaptiveConstrainedBox(
            compact: BoxConstraints(maxHeight: 120.0),
            medium: BoxConstraints(maxHeight: 200.0),
            child: AdaptiveCard(
              child: Center(
                child:
                    Text('AdaptiveConstrainedBox (Clamped to 120dp on mobile)'),
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Nested Local Theme Override
          AdaptiveTheme(
            data: const AdaptiveThemeData(
              spacing: AdaptiveSpacing(sm: 12.0, md: 24.0),
              radii: AdaptiveRadii(md: 20.0),
            ),
            child: Builder(
              builder: (ctx) {
                final localTheme = AdaptiveTheme.of(ctx);
                return AdaptiveCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nested AdaptiveTheme Scope',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      Text('Local Spacing SM: ${localTheme.spacing.sm} dp'),
                      Text('Local Radii MD: ${localTheme.radii.md} dp'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
