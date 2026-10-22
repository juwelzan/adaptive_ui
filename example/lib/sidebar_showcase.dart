import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';

/// A rich, interactive showcase tab demonstrating AdaptiveSidebar.
///
/// Demonstrates the two primary visual models (Classic and Floating),
/// three floating modes (Elevated, Inset, Minimal), developer customization
/// via AdaptiveSidebarStyleData, animated submenus, and dropdown actions.
class SidebarShowcaseTab extends StatefulWidget {
  const SidebarShowcaseTab({super.key, required this.layout});

  final AdaptiveLayoutData layout;

  @override
  State<SidebarShowcaseTab> createState() => _SidebarShowcaseTabState();
}

class _SidebarShowcaseTabState extends State<SidebarShowcaseTab> {
  AdaptiveSidebarModel _currentModel = AdaptiveSidebarModel.classic;
  AdaptiveFloatingSidebarMode _floatingMode =
      AdaptiveFloatingSidebarMode.elevated;
  AdaptiveSubmenuAnimation _currentAnim = AdaptiveSubmenuAnimation.fadeSlide;
  AdaptiveSubmenuExpansionMode _expansionMode =
      AdaptiveSubmenuExpansionMode.independent;

  bool _enableCustomStyle = false;
  double _customWidth = 240.0;
  double _customRadius = 16.0;
  double _customElevation = 3.0;
  double _customItemSpacing = 6.0;

  bool _enableRailToggle = true;
  bool _forceExpanded = true;
  bool _darkPreview = false;
  int _selectedDestination = 0;
  String _lastAction = 'Ready';

  final List<String> _destinationLabels = [
    'Dashboard',
    'Analytics (Parent)',
    'Sales Telemetry',
    'User Traffic',
    'Conversion Funnel',
    'Academics (Parent)',
    'Enrolled Courses',
    'Curriculum & Syllabus',
    'Action Tools',
    'System Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = widget.layout.containerBreakpoint == Breakpoint.compact;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(theme),
          const SizedBox(height: 16.0),
          _buildConfigurationControls(theme, isCompact),
          const SizedBox(height: 20.0),
          _buildInteractivePreview(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.08),
            theme.colorScheme.tertiary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.view_sidebar_rounded,
              color: Colors.white,
              size: 26.0,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AdaptiveSidebar 2.0 Studio',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Classic and Floating models (Elevated, Inset, Minimal) with developer customization, animated submenus, and dropdowns.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationControls(ThemeData theme, bool isCompact) {
    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Primary Model Switcher
            Row(
              children: [
                const Icon(Icons.architecture_rounded, size: 20.0),
                const SizedBox(width: 8.0),
                Text(
                  'Primary Model',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            SegmentedButton<AdaptiveSidebarModel>(
              segments: const [
                ButtonSegment(
                  value: AdaptiveSidebarModel.classic,
                  label: Text('Classic'),
                  icon: Icon(Icons.dock_rounded),
                ),
                ButtonSegment(
                  value: AdaptiveSidebarModel.floating,
                  label: Text('Floating'),
                  icon: Icon(Icons.layers_rounded),
                ),
              ],
              selected: {_currentModel},
              onSelectionChanged: (val) {
                setState(() => _currentModel = val.first);
              },
            ),
            const SizedBox(height: 16.0),

            // 2. Floating Modes (Visible when model is Floating)
            if (_currentModel == AdaptiveSidebarModel.floating) ...[
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 20.0),
                  const SizedBox(width: 8.0),
                  Text(
                    'Floating Mode',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Wrap(
                spacing: 8.0,
                children: [
                  ChoiceChip(
                    label: const Text('Elevated (Default)'),
                    selected:
                        _floatingMode == AdaptiveFloatingSidebarMode.elevated,
                    onSelected: (v) {
                      if (v) {
                        setState(() => _floatingMode =
                            AdaptiveFloatingSidebarMode.elevated);
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Inset (Framed)'),
                    selected:
                        _floatingMode == AdaptiveFloatingSidebarMode.inset,
                    onSelected: (v) {
                      if (v) {
                        setState(() =>
                            _floatingMode = AdaptiveFloatingSidebarMode.inset);
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Minimal (Lightweight)'),
                    selected:
                        _floatingMode == AdaptiveFloatingSidebarMode.minimal,
                    onSelected: (v) {
                      if (v) {
                        setState(() => _floatingMode =
                            AdaptiveFloatingSidebarMode.minimal);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],

            // 3. Customization Sliders via AdaptiveSidebarStyleData
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tune_rounded, size: 18.0),
                          const SizedBox(width: 8.0),
                          Text(
                            'Custom Style Overrides (AdaptiveSidebarStyleData)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _enableCustomStyle,
                        onChanged: (v) =>
                            setState(() => _enableCustomStyle = v),
                      ),
                    ],
                  ),
                  if (_enableCustomStyle) ...[
                    const Divider(height: 20.0),
                    // Width slider
                    Row(
                      children: [
                        SizedBox(
                          width: 110.0,
                          child: Text(
                            'Width: ${_customWidth.toInt()}dp',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _customWidth,
                            min: 180.0,
                            max: 320.0,
                            divisions: 14,
                            onChanged: (v) => setState(() => _customWidth = v),
                          ),
                        ),
                      ],
                    ),
                    // Radius slider
                    Row(
                      children: [
                        SizedBox(
                          width: 110.0,
                          child: Text(
                            'Radius: ${_customRadius.toInt()}dp',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _customRadius,
                            min: 0.0,
                            max: 32.0,
                            divisions: 16,
                            onChanged: (v) => setState(() => _customRadius = v),
                          ),
                        ),
                      ],
                    ),
                    // Elevation slider
                    Row(
                      children: [
                        SizedBox(
                          width: 110.0,
                          child: Text(
                            'Elevation: ${_customElevation.toStringAsFixed(1)}dp',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _customElevation,
                            min: 0.0,
                            max: 12.0,
                            divisions: 12,
                            onChanged: (v) =>
                                setState(() => _customElevation = v),
                          ),
                        ),
                      ],
                    ),
                    // Item Spacing slider
                    Row(
                      children: [
                        SizedBox(
                          width: 110.0,
                          child: Text(
                            'Spacing: ${_customItemSpacing.toInt()}dp',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _customItemSpacing,
                            min: 0.0,
                            max: 16.0,
                            divisions: 8,
                            onChanged: (v) =>
                                setState(() => _customItemSpacing = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 28.0),

            // 4. Animation & Interaction Controls
            Wrap(
              spacing: 16.0,
              runSpacing: 12.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Animation style dropdown
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Submenu Motion: ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    DropdownButton<AdaptiveSubmenuAnimation>(
                      value: _currentAnim,
                      underline: const SizedBox(),
                      borderRadius: BorderRadius.circular(10.0),
                      items: AdaptiveSubmenuAnimation.values.map((anim) {
                        return DropdownMenuItem(
                          value: anim,
                          child: Text(anim.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _currentAnim = val);
                      },
                    ),
                  ],
                ),
                // Expansion mode
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Submenu Policy: ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SegmentedButton<AdaptiveSubmenuExpansionMode>(
                      segments: const [
                        ButtonSegment(
                          value: AdaptiveSubmenuExpansionMode.independent,
                          label: Text('Independent'),
                        ),
                        ButtonSegment(
                          value: AdaptiveSubmenuExpansionMode.accordion,
                          label: Text('Accordion'),
                        ),
                      ],
                      selected: {_expansionMode},
                      onSelectionChanged: (val) {
                        setState(() => _expansionMode = val.first);
                      },
                    ),
                  ],
                ),
                // Expand toggle
                FilterChip(
                  label: Text(_forceExpanded ? 'Expanded' : 'Collapsed Rail'),
                  selected: _forceExpanded,
                  avatar: Icon(
                    _forceExpanded
                        ? Icons.keyboard_double_arrow_left
                        : Icons.keyboard_double_arrow_right,
                    size: 16.0,
                  ),
                  onSelected: (v) => setState(() => _forceExpanded = v),
                ),
                // Rail Toggle Button Enabled
                FilterChip(
                  label: const Text('Interactive Rail Toggle'),
                  selected: _enableRailToggle,
                  onSelected: (v) => setState(() => _enableRailToggle = v),
                ),
                // Dark preview container
                FilterChip(
                  label: const Text('Dark Surface'),
                  selected: _darkPreview,
                  avatar: Icon(
                    _darkPreview ? Icons.dark_mode : Icons.light_mode,
                    size: 16.0,
                  ),
                  onSelected: (v) => setState(() => _darkPreview = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractivePreview(ThemeData theme) {
    final previewTheme = _darkPreview
        ? ThemeData.dark(useMaterial3: true).copyWith(
            scaffoldBackgroundColor: const Color(0xFF0F1117),
            cardColor: const Color(0xFF161922),
          )
        : ThemeData.light(useMaterial3: true).copyWith(
            scaffoldBackgroundColor: const Color(0xFFF8F9FD),
            cardColor: Colors.white,
          );

    final AdaptiveSidebarStyleData? customStyle = _enableCustomStyle
        ? AdaptiveSidebarStyleData(
            width: _customWidth,
            borderRadius: BorderRadius.circular(_customRadius),
            elevation: _customElevation,
            itemSpacing: _customItemSpacing,
          )
        : null;

    return Container(
      height: 600.0,
      decoration: BoxDecoration(
        color: _darkPreview ? const Color(0xFF0B0D13) : const Color(0xFFF1F3F9),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Theme(
          data: previewTheme,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // AdaptiveSidebar Instance
              AdaptiveSidebar(
                model: _currentModel,
                floatingMode: _floatingMode,
                style: customStyle,
                submenuAnimation: _currentAnim,
                expansionMode: _expansionMode,
                isExpanded: _forceExpanded,
                enableRailToggle: _enableRailToggle,
                selectedIndex: _selectedDestination,
                onItemSelected: (idx) {
                  setState(() {
                    _selectedDestination = idx;
                    final name = idx < _destinationLabels.length
                        ? _destinationLabels[idx]
                        : 'Item #$idx';
                    _lastAction = 'Selected destination: $name (index $idx)';
                  });
                },
                onSubmenuExpansionChanged: (index, expanded) {
                  setState(() {
                    _lastAction =
                        'Submenu at index $index ${expanded ? 'expanded' : 'collapsed'}';
                  });
                },
                header: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(
                          Icons.blur_on_rounded,
                          color: Colors.white,
                          size: 20.0,
                        ),
                      ),
                      if (_forceExpanded) ...[
                        const SizedBox(width: 10.0),
                        const Expanded(
                          child: Text(
                            'Acme Cloud',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                footer: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16.0,
                        backgroundColor: Color(0xFF3B82F6),
                        child: Text(
                          'JD',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (_forceExpanded) ...[
                        const SizedBox(width: 10.0),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Jane Doe',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Admin Pro',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                items: [
                  // 0. Dashboard
                  const AdaptiveSidebarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard_rounded),
                    label: Text('Dashboard'),
                    tooltip: 'System Overview',
                  ),

                  // 1. Analytics with nested children (2, 3, 4)
                  const AdaptiveSidebarItem(
                    icon: Icon(Icons.analytics_outlined),
                    selectedIcon: Icon(Icons.analytics_rounded),
                    label: Text('Analytics'),
                    badge: Text('3'),
                    initiallyExpanded: true,
                    children: [
                      AdaptiveSidebarItem(
                        icon: Icon(Icons.trending_up_rounded),
                        label: Text('Sales Telemetry'),
                      ),
                      AdaptiveSidebarItem(
                        icon: Icon(Icons.people_outline_rounded),
                        label: Text('User Traffic'),
                      ),
                      AdaptiveSidebarItem(
                        icon: Icon(Icons.filter_alt_outlined),
                        label: Text('Conversion Funnel'),
                      ),
                    ],
                  ),

                  // 5. Academics with nested children (6, 7)
                  const AdaptiveSidebarItem(
                    icon: Icon(Icons.school_outlined),
                    selectedIcon: Icon(Icons.school_rounded),
                    label: Text('Academics'),
                    children: [
                      AdaptiveSidebarItem(
                        icon: Icon(Icons.class_outlined),
                        label: Text('Enrolled Courses'),
                      ),
                      AdaptiveSidebarItem(
                        icon: Icon(Icons.menu_book_outlined),
                        label: Text('Curriculum & Syllabus'),
                      ),
                    ],
                  ),

                  // 8. Custom Dropdown Trigger
                  AdaptiveSidebarItem(
                    icon: const Icon(Icons.auto_fix_high_rounded),
                    label: const Text('Action Tools'),
                    dropdownItems: [
                      AdaptiveDropdownItem(
                        value: 'new_workspace',
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('New Workspace'),
                        trailing: const Text(
                          '⌘N',
                          style: TextStyle(fontSize: 11.0),
                        ),
                        onTap: () {
                          setState(
                            () => _lastAction = 'Executed: New Workspace',
                          );
                        },
                      ),
                      AdaptiveDropdownItem(
                        value: 'export_csv',
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Export Telemetry (CSV)'),
                        onTap: () {
                          setState(
                            () => _lastAction = 'Executed: Export CSV',
                          );
                        },
                      ),
                      const AdaptiveDropdownItem.divider(),
                      AdaptiveDropdownItem(
                        value: 'danger_purge',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Purge Cache',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          setState(
                            () => _lastAction = 'Executed: Purge Cache',
                          );
                        },
                      ),
                    ],
                    onDropdownSelected: (val) {
                      setState(() => _lastAction = 'Dropdown selection: $val');
                    },
                  ),

                  // 9. Settings
                  const AdaptiveSidebarItem(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings_rounded),
                    label: Text('System Settings'),
                  ),
                ],
              ),

              // Main Content Details Pane
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              _currentModel == AdaptiveSidebarModel.classic
                                  ? 'MODEL: CLASSIC'
                                  : 'FLOATING: ${_floatingMode.name.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              'ANIMATION: ${_currentAnim.name.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        _selectedDestination < _destinationLabels.length
                            ? _destinationLabels[_selectedDestination]
                            : 'Destination #$_selectedDestination',
                        style: previewTheme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Active destination index: $_selectedDestination. Nested child items highlight both their parent and selected destination smoothly.',
                        style: previewTheme.textTheme.bodyMedium?.copyWith(
                          color: previewTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      // Status card
                      Card(
                        elevation: 0.0,
                        color: previewTheme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          side: BorderSide(
                            color: previewTheme.dividerColor
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    size: 18.0,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    'Event Telemetry & Actions',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: previewTheme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                _lastAction,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13.0,
                                  color: previewTheme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Style specifications summary
                      Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: previewTheme
                              .colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildMetricChip(
                                'Primary Model',
                                _currentModel == AdaptiveSidebarModel.classic
                                    ? 'Classic'
                                    : 'Floating',
                              ),
                              const SizedBox(width: 16.0),
                              _buildMetricChip(
                                'Floating Mode',
                                _currentModel == AdaptiveSidebarModel.classic
                                    ? 'N/A'
                                    : _floatingMode.name,
                              ),
                              const SizedBox(width: 16.0),
                              _buildMetricChip(
                                'Custom Overrides',
                                _enableCustomStyle ? 'Active' : 'Defaults',
                              ),
                              const SizedBox(width: 16.0),
                              _buildMetricChip(
                                'Target Width',
                                '${_enableCustomStyle ? _customWidth.toInt() : 240}dp',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.0, color: Colors.grey),
        ),
        const SizedBox(height: 2.0),
        Text(
          value,
          style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
