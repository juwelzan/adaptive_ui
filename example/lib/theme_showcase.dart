import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';

/// Interactive showcase demonstrating Phase 5 Adaptive Design System & Unified Theme Engine.
class ThemeShowcaseTab extends StatefulWidget {
  const ThemeShowcaseTab({
    super.key,
    required this.layout,
  });

  final AdaptiveLayoutData layout;

  @override
  State<ThemeShowcaseTab> createState() => _ThemeShowcaseTabState();
}

class _ThemeShowcaseTabState extends State<ThemeShowcaseTab> {
  // Theme Configuration State
  bool _isDark = false;
  Color _seedColor = const Color(0xFF1E5BB0); // Royal Blue
  AdaptiveDensity _density = AdaptiveDensity.comfortable;
  bool _useComponentOverrides = false;
  bool _animateTransitions = true;
  double _transitionDurationMs = 300.0;
  int _bottomNavIndex = 0;

  static const List<NamedSeedColor> _availableSeeds = [
    NamedSeedColor('Royal Blue', Color(0xFF1E5BB0)),
    NamedSeedColor('Emerald', Color(0xFF0F9D58)),
    NamedSeedColor('Crimson', Color(0xFFD93025)),
    NamedSeedColor('Purple', Color(0xFF673AB7)),
    NamedSeedColor('Amber Gold', Color(0xFFF29900)),
    NamedSeedColor('Deep Teal', Color(0xFF00796B)),
  ];

  AdaptiveThemeData _buildCurrentTheme() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: _isDark ? Brightness.dark : Brightness.light,
    );

    AdaptiveThemeData data = _isDark
        ? AdaptiveThemeData.dark().copyWith(
            colors: AdaptiveColors.fromColorScheme(scheme),
          )
        : AdaptiveThemeData.light().copyWith(
            colors: AdaptiveColors.fromColorScheme(scheme),
          );

    data = data.copyWith(density: _density);

    if (_useComponentOverrides) {
      data = data.copyWith(
        componentThemes: AdaptiveComponentThemes(
          card: AdaptiveCardThemeData(
            borderRadius: BorderRadius.circular(24.0),
            elevation: 4.0,
          ),
          button: AdaptiveButtonThemeData(
            borderRadius: BorderRadius.circular(20.0),
            minHeightCompact: 48.0,
            minHeightRegular: 56.0,
          ),
          bottomNav: AdaptiveBottomNavThemeData(
            height: 84.0,
            indicatorColor: _seedColor.withValues(alpha: 0.25),
          ),
          shimmer: AdaptiveShimmerThemeData(
            baseColor: _isDark
                ? _seedColor.withValues(alpha: 0.15)
                : _seedColor.withValues(alpha: 0.08),
            highlightColor: _isDark
                ? _seedColor.withValues(alpha: 0.35)
                : _seedColor.withValues(alpha: 0.22),
          ),
        ),
      );
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = _buildCurrentTheme();

    final Widget content = AdaptiveScrollView(
      padding: const EdgeInsets.all(16.0),
      centerContent: true,
      maxContentWidth: 1080.0,
      child: AdaptiveColumn(
        spacing: const AdaptiveValue.fixed(24.0),
        children: [
          // Section 1: Interactive Theme Engine Controller
          _buildControlsCard(context, currentTheme),

          // Section 2: Live Semantic Color Palette
          _buildColorsSection(context, currentTheme),

          // Section 3: Adaptive Typography Scale
          _buildTypographySection(context, currentTheme),

          // Section 4: Spacing, Radii & Elevation Tokens
          _buildTokensSection(context, currentTheme),

          // Section 5: Themed Component Matrix
          _buildComponentsSection(context, currentTheme),

          // Section 6: Nested Theme Scope & Transitions
          _buildNestedThemeSection(context, currentTheme),
        ],
      ),
    );

    if (_animateTransitions) {
      return AnimatedAdaptiveTheme(
        data: currentTheme,
        duration: Duration(milliseconds: _transitionDurationMs.toInt()),
        curve: Curves.easeInOutCubic,
        child: content,
      );
    }

    return AdaptiveTheme(
      data: currentTheme,
      child: content,
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Theme Controller Card
  // ---------------------------------------------------------------------------
  Widget _buildControlsCard(BuildContext context, AdaptiveThemeData theme) {
    return AdaptiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined,
                    color: theme.colors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AdaptiveText(
                        'Unified Theme Engine & Studio',
                        variant: AdaptiveTextVariant.titleLarge,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      AdaptiveText(
                        'Customizable tokens, semantic color schemes, and seamless transitions.',
                        variant: AdaptiveTextVariant.caption,
                        style: TextStyle(color: theme.colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Mode & Options row
            Wrap(
              spacing: 16.0,
              runSpacing: 12.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Brightness Toggle
                FilterChip(
                  avatar: Icon(_isDark ? Icons.dark_mode : Icons.light_mode,
                      size: 18),
                  label: Text(_isDark ? 'Dark Theme' : 'Light Theme'),
                  selected: _isDark,
                  onSelected: (val) => setState(() => _isDark = val),
                ),

                // Component Themes Override Toggle
                FilterChip(
                  avatar: const Icon(Icons.tune, size: 18),
                  label: const Text('Component Overrides'),
                  selected: _useComponentOverrides,
                  onSelected: (val) =>
                      setState(() => _useComponentOverrides = val),
                ),

                // Animated Transitions Toggle
                FilterChip(
                  avatar: const Icon(Icons.animation, size: 18),
                  label: const Text('Animated Transitions'),
                  selected: _animateTransitions,
                  onSelected: (val) =>
                      setState(() => _animateTransitions = val),
                ),

                // Density Selector
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Density: ',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    DropdownButton<AdaptiveDensity>(
                      value: _density,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(
                          value: AdaptiveDensity.compact,
                          child: Text('Compact'),
                        ),
                        DropdownMenuItem(
                          value: AdaptiveDensity.comfortable,
                          child: Text('Comfortable'),
                        ),
                        DropdownMenuItem(
                          value: AdaptiveDensity.spacious,
                          child: Text('Spacious'),
                        ),
                      ],
                      onChanged: (d) {
                        if (d != null) setState(() => _density = d);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Color Palette Picker
            const Text('Seed Color Palette:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _availableSeeds.map((seed) {
                final isSelected = _seedColor == seed.color;
                return ChoiceChip(
                  avatar: CircleAvatar(backgroundColor: seed.color, radius: 8),
                  label: Text(seed.name),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _seedColor = seed.color),
                );
              }).toList(),
            ),

            if (_animateTransitions) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                      'Transition Duration: ${_transitionDurationMs.toInt()}ms'),
                  Expanded(
                    child: Slider(
                      value: _transitionDurationMs,
                      min: 100.0,
                      max: 1000.0,
                      divisions: 9,
                      label: '${_transitionDurationMs.toInt()}ms',
                      onChanged: (v) =>
                          setState(() => _transitionDurationMs = v),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Semantic Color Palette Section
  // ---------------------------------------------------------------------------
  Widget _buildColorsSection(BuildContext context, AdaptiveThemeData theme) {
    final colors = theme.colors;

    final roles = [
      _ColorChipData('Primary', colors.primary, colors.onPrimary),
      _ColorChipData('Secondary', colors.secondary, colors.onSecondary),
      _ColorChipData('Surface', colors.surface, colors.onSurface),
      _ColorChipData(
          'Elevated Surface', colors.surfaceElevated, colors.onSurfaceElevated),
      _ColorChipData('Background', colors.background, colors.onBackground),
      _ColorChipData('Success', colors.success, colors.onSuccess),
      _ColorChipData('Warning', colors.warning, colors.onWarning),
      _ColorChipData('Error', colors.error, colors.onError),
      _ColorChipData('Info', colors.info, colors.onInfo),
      _ColorChipData('Border/Divider', colors.border, colors.textPrimary),
      _ColorChipData('Disabled', colors.disabled, colors.onDisabled),
      _ColorChipData('Hover', colors.hover, colors.textPrimary),
    ];

    return AdaptiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdaptiveText(
              'Semantic Color Roles',
              variant: AdaptiveTextVariant.titleMedium,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (ctx, constraints) {
                final int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 2.8,
                  ),
                  itemCount: roles.length,
                  itemBuilder: (ctx, idx) {
                    final role = roles[idx];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: role.color,
                        borderRadius:
                            theme.radii.toBorderRadius(theme.radii.md),
                        border: Border.all(
                            color: theme.colors.border.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            role.label,
                            style: TextStyle(
                              color: role.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                            ),
                          ),
                          Text(
                            '#${role.color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}',
                            style: TextStyle(
                              color: role.textColor.withValues(alpha: 0.75),
                              fontSize: 10.0,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Adaptive Typography Section
  // ---------------------------------------------------------------------------
  Widget _buildTypographySection(
      BuildContext context, AdaptiveThemeData theme) {
    return AdaptiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdaptiveText(
              'Adaptive Typography Scale',
              variant: AdaptiveTextVariant.titleMedium,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const AdaptiveText(
              'Display Large (40sp / Bold)',
              variant: AdaptiveTextVariant.displayLarge,
            ),
            const SizedBox(height: 8),
            const AdaptiveText(
              'Headline Medium (24sp / Semi-Bold)',
              variant: AdaptiveTextVariant.headlineMedium,
            ),
            const SizedBox(height: 8),
            const AdaptiveText(
              'Title Large (20sp / Semi-Bold)',
              variant: AdaptiveTextVariant.titleLarge,
            ),
            const SizedBox(height: 8),
            const AdaptiveText(
              'Body Medium (14sp / Regular) — Automatic responsive font scaling with user accessibility settings preserved.',
              variant: AdaptiveTextVariant.bodyMedium,
            ),
            const SizedBox(height: 8),
            const AdaptiveText(
              'Caption (11sp / Regular) — Subtle footnote and metadata labeling token.',
              variant: AdaptiveTextVariant.caption,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Spacing, Radii & Elevation Tokens Section
  // ---------------------------------------------------------------------------
  Widget _buildTokensSection(BuildContext context, AdaptiveThemeData theme) {
    return AdaptiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdaptiveText(
              'Spacing, Radii & Elevation Tokens',
              variant: AdaptiveTextVariant.titleMedium,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spacing Tokens',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.colors.textPrimary)),
                      const SizedBox(height: 6),
                      Text(
                          'XS: ${theme.spacing.xs}dp | SM: ${theme.spacing.sm}dp | MD: ${theme.spacing.md}dp | LG: ${theme.spacing.lg}dp | XL: ${theme.spacing.xl}dp',
                          style: TextStyle(
                              fontSize: 12, color: theme.colors.textSecondary)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Radii Tokens',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.colors.textPrimary)),
                      const SizedBox(height: 6),
                      Text(
                          'SM: ${theme.radii.sm}dp | MD: ${theme.radii.md}dp | LG: ${theme.radii.lg}dp | XL: ${theme.radii.xl}dp',
                          style: TextStyle(
                              fontSize: 12, color: theme.colors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Elevation Shadows Preview:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildElevationBox('None (0dp)', theme.elevations.none, theme),
                _buildElevationBox('Low (1dp)', theme.elevations.low, theme),
                _buildElevationBox(
                    'Medium (3dp)', theme.elevations.medium, theme),
                _buildElevationBox('High (6dp)', theme.elevations.high, theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElevationBox(
      String label, double elevation, AdaptiveThemeData theme) {
    return Container(
      width: 70,
      height: 60,
      decoration: BoxDecoration(
        color: theme.colors.surfaceElevated,
        borderRadius: theme.radii.toBorderRadius(theme.radii.md),
        boxShadow: theme.elevations.shadowOf(elevation),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
            color: theme.colors.textPrimary),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Themed Component Matrix Section
  // ---------------------------------------------------------------------------
  Widget _buildComponentsSection(
      BuildContext context, AdaptiveThemeData theme) {
    return AdaptiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdaptiveText(
              'Unified Adaptive Component Matrix',
              variant: AdaptiveTextVariant.titleMedium,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Adaptive Buttons
            Wrap(
              spacing: 12.0,
              runSpacing: 10.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AdaptiveButton(
                  onPressed: () {},
                  child: const Text('Primary Button'),
                ),
                AdaptiveButton(
                  variant: AdaptiveButtonVariant.secondary,
                  onPressed: () {},
                  child: const Text('Secondary Button'),
                ),
                AdaptiveButton(
                  variant: AdaptiveButtonVariant.outline,
                  onPressed: () {},
                  child: const Text('Outline Button'),
                ),
                AdaptiveButton(
                  isLoading: true,
                  onPressed: () {},
                  child: const Text('Loading'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Adaptive Bottom Navigation Bar Preview
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colors.border),
                borderRadius: theme.radii.toBorderRadius(theme.radii.lg),
              ),
              clipBehavior: Clip.antiAlias,
              child: AdaptiveBottomNavigationBar(
                selectedIndex: _bottomNavIndex,
                onDestinationSelected: (idx) =>
                    setState(() => _bottomNavIndex = idx),
                destinations: const [
                  AdaptiveBottomNavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Explore',
                  ),
                  AdaptiveBottomNavigationDestination(
                    icon: Icon(Icons.palette_outlined),
                    selectedIcon: Icon(Icons.palette),
                    label: 'Tokens',
                  ),
                  AdaptiveBottomNavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: 'Config',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Adaptive Shimmer & Skeleton Preview
            Row(
              children: [
                const AdaptiveSkeleton.circle(size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AdaptiveSkeleton.text(width: 180, height: 14),
                      SizedBox(height: 6),
                      AdaptiveSkeleton.text(width: 120, height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Nested Theme Scope Section
  // ---------------------------------------------------------------------------
  Widget _buildNestedThemeSection(
      BuildContext context, AdaptiveThemeData parentTheme) {
    // Nested contrasting theme
    final nestedTheme = parentTheme.isDark
        ? AdaptiveThemeData.light().copyWith(
            colors: AdaptiveColors.fromColorScheme(
              ColorScheme.fromSeed(
                  seedColor: Colors.deepOrange, brightness: Brightness.light),
            ),
          )
        : AdaptiveThemeData.dark().copyWith(
            colors: AdaptiveColors.fromColorScheme(
              ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple, brightness: Brightness.dark),
            ),
          );

    return AdaptiveTheme(
      data: nestedTheme,
      child: Builder(
        builder: (ctx) {
          final localTheme = AdaptiveTheme.of(ctx);
          return AdaptiveCard(
            color: localTheme.colors.surfaceElevated,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.layers_outlined,
                          color: localTheme.colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Nested Theme Scope (${localTheme.isDark ? "Dark" : "Light"} Inverted)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: localTheme.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Demonstrating subtree isolation: Local tokens override parent without leaking back up the tree.',
                    style: TextStyle(
                        color: localTheme.colors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  AdaptiveButton(
                    onPressed: () {},
                    child: Text(
                        'Nested Button (${localTheme.isDark ? "Dark Mode" : "Light Mode"})'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class NamedSeedColor {
  const NamedSeedColor(this.name, this.color);
  final String name;
  final Color color;
}

class _ColorChipData {
  const _ColorChipData(this.label, this.color, this.textColor);
  final String label;
  final Color color;
  final Color textColor;
}
